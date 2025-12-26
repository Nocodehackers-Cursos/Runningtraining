//
//  WorkoutMatcher.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import Foundation
import HealthKit

/// Servicio para emparejar workouts de HealthKit con workouts planificados
class WorkoutMatcher {

    // MARK: - Public Methods

    /// Encuentra el workout planificado que mejor coincide con un workout de HealthKit
    /// - Parameters:
    ///   - hkWorkout: Workout de HealthKit a emparejar
    ///   - plannedWorkouts: Array de workouts planificados
    /// - Returns: Workout planificado que coincide, o nil si no hay match
    static func findMatch(
        hkWorkout: HKWorkout,
        in plannedWorkouts: [Workout]
    ) -> Workout? {
        let calendar = Calendar.current

        // 1. Filtrar candidatos por mismo día y no sincronizados previamente
        let candidates = plannedWorkouts.filter { workout in
            let isSameDay = calendar.isDate(workout.scheduledDate, inSameDayAs: hkWorkout.startDate)
            let notSynced = !workout.syncedFromHealthKit
            let isRunningWorkout = isRunningCompatible(workout.workoutType)

            return isSameDay && notSynced && isRunningWorkout
        }

        // 2. Si no hay candidatos, retornar nil
        if candidates.isEmpty {
            return nil
        }

        // 3. Si solo hay un candidato, retornarlo directamente
        if candidates.count == 1 {
            print("✅ Match único encontrado para workout de HealthKit")
            return candidates.first
        }

        // 4. Si hay múltiples candidatos, usar sistema de scoring
        print("⚠️ Múltiples candidatos encontrados (\(candidates.count)), usando scoring")
        return findBestMatch(hkWorkout: hkWorkout, in: candidates)
    }

    // MARK: - Private Methods

    /// Encuentra el mejor match entre múltiples candidatos usando un sistema de scoring
    /// - Parameters:
    ///   - hkWorkout: Workout de HealthKit
    ///   - candidates: Array de workouts candidatos
    /// - Returns: Mejor match, o nil si ninguno supera el umbral
    private static func findBestMatch(
        hkWorkout: HKWorkout,
        in candidates: [Workout]
    ) -> Workout? {
        var bestMatch: Workout?
        var bestScore: Double = 0.0

        for candidate in candidates {
            let score = calculateMatchScore(hkWorkout: hkWorkout, planned: candidate)

            print("  - Candidato '\(candidate.title)': score = \(String(format: "%.2f", score))")

            if score > bestScore {
                bestScore = score
                bestMatch = candidate
            }
        }

        // Solo retornar match si el score supera el umbral del 50%
        let threshold = 0.5
        if bestScore >= threshold {
            print("✅ Mejor match: '\(bestMatch?.title ?? "")' con score \(String(format: "%.2f", bestScore))")
            return bestMatch
        } else {
            print("❌ Ningún candidato supera el umbral (mejor score: \(String(format: "%.2f", bestScore)))")
            return nil
        }
    }

    /// Calcula un score de similitud entre un workout de HealthKit y uno planificado
    /// - Parameters:
    ///   - hkWorkout: Workout de HealthKit
    ///   - planned: Workout planificado
    /// - Returns: Score de 0.0 a 1.0 (1.0 = match perfecto)
    private static func calculateMatchScore(
        hkWorkout: HKWorkout,
        planned: Workout
    ) -> Double {
        var score: Double = 0.0

        // 1. Similitud de distancia (peso: 40%)
        if let plannedDistance = planned.distanceKm,
           let actualDistance = hkWorkout.totalDistance?.doubleValue(for: .meterUnit(with: .kilo)) {

            let distanceDifference = abs(plannedDistance - actualDistance)
            let distanceVariance = distanceDifference / plannedDistance

            // Score inverso: 0% diferencia = 1.0, 100% diferencia = 0.0
            let distanceScore = max(0, 1.0 - distanceVariance)
            score += distanceScore * 0.4

            print("    Distancia: planificada=\(String(format: "%.2f", plannedDistance))km, real=\(String(format: "%.2f", actualDistance))km, score=\(String(format: "%.2f", distanceScore))")
        }

        // 2. Similitud de duración (peso: 30%)
        if let plannedDuration = planned.durationMinutes {
            let actualDurationMinutes = hkWorkout.duration / 60.0
            let durationDifference = abs(Double(plannedDuration) - actualDurationMinutes)
            let durationVariance = durationDifference / Double(plannedDuration)

            let durationScore = max(0, 1.0 - durationVariance)
            score += durationScore * 0.3

            print("    Duración: planificada=\(plannedDuration)min, real=\(String(format: "%.1f", actualDurationMinutes))min, score=\(String(format: "%.2f", durationScore))")
        }

        // 3. Compatibilidad de tipo de workout (peso: 30%)
        let typeCompatible = isWorkoutTypeCompatible(planned.workoutType, with: hkWorkout.workoutActivityType)
        if typeCompatible {
            score += 0.3
            print("    Tipo: compatible ✓")
        } else {
            print("    Tipo: no compatible ✗")
        }

        return score
    }

    /// Verifica si un tipo de workout planificado es compatible con un tipo de HealthKit
    /// - Parameters:
    ///   - planned: Tipo de workout planificado
    ///   - actual: Tipo de actividad de HealthKit
    /// - Returns: true si son compatibles
    private static func isWorkoutTypeCompatible(
        _ planned: WorkoutType,
        with actual: HKWorkoutActivityType
    ) -> Bool {
        // La mayoría de nuestros workouts son de running
        switch planned {
        case .rest, .crossTraining:
            // Rest y cross-training no son compatibles con running
            return false
        default:
            // Todos los demás tipos (longRun, tempoRun, intervals, etc.) son running
            return actual == .running ||
                   actual == .traditionalStrengthTraining || // Por si hay algo de fuerza
                   actual == .other // Fallback
        }
    }

    /// Verifica si un tipo de workout planificado es de tipo running
    /// - Parameter workoutType: Tipo de workout
    /// - Returns: true si es compatible con running
    private static func isRunningCompatible(_ workoutType: WorkoutType) -> Bool {
        switch workoutType {
        case .rest, .crossTraining:
            return false
        default:
            return true
        }
    }

    // MARK: - Advanced Matching (Future Enhancement)

    /// Encuentra múltiples matches cuando hay varios workouts de HealthKit y planificados el mismo día
    /// - Parameters:
    ///   - hkWorkouts: Array de workouts de HealthKit
    ///   - plannedWorkouts: Array de workouts planificados
    /// - Returns: Diccionario de matches [HKWorkout: Workout]
    static func findMultipleMatches(
        hkWorkouts: [HKWorkout],
        plannedWorkouts: [Workout]
    ) -> [UUID: Workout] {
        var matches: [UUID: Workout] = [:]
        var remainingPlanned = plannedWorkouts

        // Ordenar HealthKit workouts por duración (más largos primero)
        let sortedHK = hkWorkouts.sorted { $0.duration > $1.duration }

        for hkWorkout in sortedHK {
            if let match = findMatch(hkWorkout: hkWorkout, in: remainingPlanned) {
                matches[hkWorkout.uuid] = match

                // Remover el match de la lista para evitar duplicados
                remainingPlanned.removeAll { $0.id == match.id }
            }
        }

        return matches
    }

    // MARK: - Statistics

    /// Calcula estadísticas de matching para debugging
    /// - Parameters:
    ///   - hkWorkouts: Workouts de HealthKit
    ///   - plannedWorkouts: Workouts planificados
    /// - Returns: Diccionario con estadísticas
    static func calculateMatchingStats(
        hkWorkouts: [HKWorkout],
        plannedWorkouts: [Workout]
    ) -> [String: Any] {
        let totalHK = hkWorkouts.count
        let totalPlanned = plannedWorkouts.count
        let matches = findMultipleMatches(hkWorkouts: hkWorkouts, plannedWorkouts: plannedWorkouts)
        let matchedCount = matches.count

        let matchRate = totalHK > 0 ? Double(matchedCount) / Double(totalHK) : 0.0

        return [
            "totalHealthKitWorkouts": totalHK,
            "totalPlannedWorkouts": totalPlanned,
            "matchedCount": matchedCount,
            "matchRate": matchRate,
            "unmatchedHealthKit": totalHK - matchedCount,
            "unmatchedPlanned": totalPlanned - matchedCount
        ]
    }
}
