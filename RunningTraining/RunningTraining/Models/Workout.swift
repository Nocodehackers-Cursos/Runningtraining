//
//  Workout.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation
import SwiftData

/// Modelo que representa un entrenamiento individual
@Model
final class Workout {
    @Attribute(.unique) var id: UUID
    var scheduledDate: Date
    var workoutType: WorkoutType

    // Parámetros del entrenamiento
    var title: String
    var workoutDescription: String
    var distanceKm: Double?
    var durationMinutes: Int?
    var targetPaceMinPerKm: Double?
    var targetPaceRangeMin: Double? // Rango inferior de ritmo
    var targetPaceRangeMax: Double? // Rango superior de ritmo

    // Zona de frecuencia cardíaca principal
    var primaryHeartRateZone: String? // "zone1", "zone2", etc.
    var heartRateZonePercentageMin: Int? // % de FC máxima
    var heartRateZonePercentageMax: Int?

    // Objetivos del entrenamiento
    var goals: [String]

    // Estado de completitud
    var isCompleted: Bool
    var completedAt: Date?

    // MARK: - HealthKit Integration
    var healthKitWorkoutUUID: UUID?
    var syncedFromHealthKit: Bool
    var healthKitSyncDate: Date?

    // MARK: - Datos Reales (de HealthKit)
    var actualDistanceKm: Double?
    var actualDurationMinutes: Int?
    var actualPaceMinPerKm: Double?
    var actualAverageHeartRate: Int?
    var actualMaxHeartRate: Int?
    var actualHeartRateZone: String? // "zone1", "zone2", etc.

    // MARK: - Métricas de Rendimiento
    var paceVariance: Double? // % diferencia entre planificado y real
    var heartRateZoneAccuracy: Double? // % tiempo en zona objetivo

    // Relación inversa con TrainingWeek
    var trainingWeek: TrainingWeek?

    init(
        scheduledDate: Date,
        workoutType: WorkoutType,
        title: String,
        description: String
    ) {
        self.id = UUID()
        self.scheduledDate = scheduledDate
        self.workoutType = workoutType
        self.title = title
        self.workoutDescription = description
        self.goals = []
        self.isCompleted = false
        self.syncedFromHealthKit = false
    }

    /// Obtiene la zona de FC como objeto HeartRateZone
    func getHeartRateZone(maxHR: Int) -> HeartRateZone? {
        guard let zoneString = primaryHeartRateZone,
              let percentMin = heartRateZonePercentageMin,
              let percentMax = heartRateZonePercentageMax else {
            return nil
        }

        // Mapear el string a Zone enum
        let zone: HeartRateZone.Zone
        switch zoneString {
        case "zone1": zone = .zone1
        case "zone2": zone = .zone2
        case "zone3": zone = .zone3
        case "zone4": zone = .zone4
        case "zone5": zone = .zone5
        default: return nil
        }

        let minBPM = Int(Double(maxHR) * Double(percentMin) / 100.0)
        let maxBPM = Int(Double(maxHR) * Double(percentMax) / 100.0)

        return HeartRateZone(
            zone: zone,
            minBPM: minBPM,
            maxBPM: maxBPM,
            percentageMin: percentMin,
            percentageMax: percentMax
        )
    }

    /// Marca el entrenamiento como completado
    func markAsCompleted() {
        self.isCompleted = true
        self.completedAt = Date()
    }

    /// Marca el entrenamiento como no completado
    func markAsIncomplete() {
        self.isCompleted = false
        self.completedAt = nil
    }

    /// Devuelve si el entreno es hoy
    var isToday: Bool {
        return scheduledDate.isToday
    }

    /// Devuelve si el entreno está en el futuro
    var isUpcoming: Bool {
        return scheduledDate.isInFuture
    }

    /// Devuelve si el entreno está en el pasado
    var isPast: Bool {
        return scheduledDate.isInPast
    }
}

// MARK: - HealthKit Computed Properties

extension Workout {
    /// Indica si el workout tiene datos de HealthKit asociados
    var hasHealthKitData: Bool {
        return healthKitWorkoutUUID != nil && syncedFromHealthKit
    }

    /// Indica si el workout tiene datos reales (de cualquier fuente)
    var hasActualData: Bool {
        return actualDistanceKm != nil || actualDurationMinutes != nil
    }

    /// Calcula la varianza de ritmo (positivo = más rápido que lo planificado)
    var calculatedPaceVariance: Double? {
        guard let planned = targetPaceMinPerKm,
              let actual = actualPaceMinPerKm else {
            return nil
        }
        return ((planned - actual) / planned) * 100.0
    }

    /// Estado de rendimiento basado en la varianza de ritmo
    var performanceStatus: PerformanceStatus {
        return PerformanceStatus.from(paceVariance: calculatedPaceVariance)
    }

    /// Indica si la zona de FC real coincide con la planificada
    var heartRateCompliance: Bool? {
        guard let targetZone = primaryHeartRateZone,
              let actualZone = actualHeartRateZone else {
            return nil
        }
        return targetZone == actualZone
    }

    /// Formatea la distancia real
    var formattedActualDistance: String? {
        guard let distance = actualDistanceKm else { return nil }
        return String(format: "%.2f km", distance)
    }

    /// Formatea la duración real
    var formattedActualDuration: String? {
        guard let duration = actualDurationMinutes else { return nil }
        let hours = duration / 60
        let minutes = duration % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }

    /// Formatea el ritmo real
    var formattedActualPace: String? {
        guard let pace = actualPaceMinPerKm else { return nil }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d /km", minutes, seconds)
    }
}
