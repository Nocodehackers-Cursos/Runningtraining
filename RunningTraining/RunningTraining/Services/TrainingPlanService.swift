//
//  TrainingPlanService.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation
import SwiftData
import HealthKit

/// Servicio principal para generar y gestionar planes de entrenamiento
class TrainingPlanService {
    private let openAIService: OpenAIService

    init() {
        self.openAIService = OpenAIService()
    }

    /// Genera un plan de entrenamiento completo para un usuario
    /// - Parameters:
    ///   - user: Usuario con sus parámetros de entrenamiento
    ///   - modelContext: Contexto de SwiftData para guardar el plan
    /// - Returns: TrainingPlan generado y guardado
    func generatePlan(for user: User, modelContext: ModelContext) async throws -> TrainingPlan {
        // 1. Construir prompt
        let prompt = PromptBuilder.buildTrainingPlanPrompt(for: user)

        print("📝 Generando plan de entrenamiento...")
        print("Semanas hasta carrera: \(Date().weeksUntil(user.raceDate))")
        print("Sesiones por semana: \(user.sessionsPerWeek)")

        // 2. Llamar a OpenAI para generar el plan
        let jsonResponse: String
        do {
            jsonResponse = try await openAIService.generateTrainingPlan(prompt: prompt)
            print("✅ Plan generado exitosamente por OpenAI")
        } catch {
            print("❌ Error generando plan: \(error.localizedDescription)")
            throw error
        }

        // 3. Parsear respuesta JSON a modelos SwiftData
        let trainingPlan: TrainingPlan
        do {
            trainingPlan = try TrainingPlanParser.parse(jsonString: jsonResponse, for: user)
            print("✅ Plan parseado exitosamente")
            print("Total semanas: \(trainingPlan.totalWeeks)")
            print("Total entrenamientos: \(trainingPlan.totalWorkouts)")
        } catch {
            print("❌ Error parseando plan: \(error.localizedDescription)")
            throw error
        }

        // 4. Guardar prompt usado para referencia
        trainingPlan.promptUsed = prompt

        // 5. Asociar plan al usuario
        trainingPlan.user = user
        user.trainingPlans.append(trainingPlan)
        user.setActivePlan(trainingPlan)

        // 6. Guardar en SwiftData
        modelContext.insert(trainingPlan)
        do {
            try modelContext.save()
            print("✅ Plan guardado en SwiftData")
        } catch {
            print("❌ Error guardando en SwiftData: \(error.localizedDescription)")
            throw error
        }

        return trainingPlan
    }

    /// Elimina un plan de entrenamiento
    /// - Parameters:
    ///   - plan: Plan a eliminar
    ///   - modelContext: Contexto de SwiftData
    func deletePlan(_ plan: TrainingPlan, modelContext: ModelContext) throws {
        modelContext.delete(plan)
        try modelContext.save()
    }

    /// Obtiene el plan activo de un usuario
    /// - Parameters:
    ///   - user: Usuario
    ///   - modelContext: Contexto de SwiftData
    /// - Returns: Plan activo si existe
    func getActivePlan(for user: User, modelContext: ModelContext) -> TrainingPlan? {
        return user.activeTrainingPlan
    }

    /// Marca un workout como completado
    /// - Parameters:
    ///   - workout: Workout a marcar
    ///   - modelContext: Contexto de SwiftData
    func markWorkoutCompleted(_ workout: Workout, modelContext: ModelContext) throws {
        workout.markAsCompleted()
        try modelContext.save()
    }

    /// Marca un workout como no completado
    /// - Parameters:
    ///   - workout: Workout a desmarcar
    ///   - modelContext: Contexto de SwiftData
    func markWorkoutIncomplete(_ workout: Workout, modelContext: ModelContext) throws {
        workout.markAsIncomplete()
        try modelContext.save()
    }

    // MARK: - HealthKit Synchronization

    private let healthKitService = HealthKitService.shared

    /// Sincroniza workouts de HealthKit con workouts planificados en un rango de fechas
    /// - Parameters:
    ///   - startDate: Fecha de inicio del rango
    ///   - endDate: Fecha de fin del rango
    ///   - modelContext: Contexto de SwiftData
    func syncHealthKitWorkouts(
        from startDate: Date,
        to endDate: Date,
        modelContext: ModelContext
    ) async throws {
        print("🔄 Sincronizando workouts de HealthKit desde \(startDate) hasta \(endDate)")

        // 1. Fetch workouts de HealthKit
        let hkWorkouts = try await healthKitService.fetchWorkouts(from: startDate, to: endDate)
        print("  📱 Encontrados \(hkWorkouts.count) workouts en HealthKit")

        guard !hkWorkouts.isEmpty else {
            print("  ℹ️ No hay workouts de HealthKit para sincronizar")
            return
        }

        // 2. Fetch workouts planificados en mismo rango
        let plannedWorkouts = try fetchPlannedWorkouts(
            from: startDate,
            to: endDate,
            modelContext: modelContext
        )
        print("  📅 Encontrados \(plannedWorkouts.count) workouts planificados")

        guard !plannedWorkouts.isEmpty else {
            print("  ℹ️ No hay workouts planificados para emparejar")
            return
        }

        // 3. Emparejar y actualizar
        var matchedCount = 0
        for hkWorkout in hkWorkouts {
            if let match = WorkoutMatcher.findMatch(hkWorkout: hkWorkout, in: plannedWorkouts) {
                try await updateWorkoutWithHealthKitData(match, hkWorkout: hkWorkout, modelContext: modelContext)
                matchedCount += 1
            }
        }

        print("  ✅ Sincronizados \(matchedCount) de \(hkWorkouts.count) workouts")
    }

    /// Obtiene workouts planificados en un rango de fechas
    /// - Parameters:
    ///   - startDate: Fecha de inicio
    ///   - endDate: Fecha de fin
    ///   - modelContext: Contexto de SwiftData
    /// - Returns: Array de workouts planificados en el rango
    private func fetchPlannedWorkouts(
        from startDate: Date,
        to endDate: Date,
        modelContext: ModelContext
    ) throws -> [Workout] {
        let predicate = #Predicate<Workout> { workout in
            workout.scheduledDate >= startDate && workout.scheduledDate <= endDate
        }

        let descriptor = FetchDescriptor<Workout>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    /// Actualiza un workout con datos de HealthKit
    /// - Parameters:
    ///   - workout: Workout planificado a actualizar
    ///   - hkWorkout: Workout de HealthKit con los datos reales
    ///   - modelContext: Contexto de SwiftData
    private func updateWorkoutWithHealthKitData(
        _ workout: Workout,
        hkWorkout: HKWorkout,
        modelContext: ModelContext
    ) async throws {
        print("  🔗 Emparejando '\(workout.title)' con workout de HealthKit")

        // Extraer métricas del workout de HealthKit
        let metrics = try await healthKitService.extractMetrics(from: hkWorkout)

        // Actualizar workout con datos de HealthKit
        workout.healthKitWorkoutUUID = metrics.healthKitUUID
        workout.syncedFromHealthKit = true
        workout.healthKitSyncDate = Date()

        // Datos de distancia y tiempo
        workout.actualDistanceKm = metrics.distanceInKm
        workout.actualDurationMinutes = Int(metrics.durationInMinutes)
        workout.actualPaceMinPerKm = metrics.averagePace

        // Datos de frecuencia cardíaca
        workout.actualAverageHeartRate = metrics.averageHeartRate
        workout.actualMaxHeartRate = metrics.maxHeartRate

        // Calcular varianza de ritmo si hay datos planificados
        if let plannedPace = workout.targetPaceMinPerKm {
            let actualPace = metrics.averagePace
            workout.paceVariance = ((plannedPace - actualPace) / plannedPace) * 100.0
        }

        // Auto-completar el workout
        workout.markAsCompleted()

        // Guardar cambios
        try modelContext.save()

        print("    ✅ Workout actualizado: \(metrics.distanceInKm)km en \(metrics.durationInMinutes)min")
    }

    /// Intenta sincronizar un workout específico con HealthKit antes de marcarlo como completado
    /// - Parameters:
    ///   - workout: Workout a completar
    ///   - modelContext: Contexto de SwiftData
    func markWorkoutCompletedWithHealthKitSync(
        _ workout: Workout,
        modelContext: ModelContext
    ) async throws {
        // Si ya está sincronizado con HealthKit, solo guardamos
        if workout.syncedFromHealthKit {
            workout.markAsCompleted()
            try modelContext.save()
            return
        }

        // Intentar buscar workout de HealthKit del mismo día
        do {
            let hkWorkouts = try await healthKitService.fetchWorkoutsForDay(workout.scheduledDate)

            if let hkWorkout = hkWorkouts.first {
                // Encontramos un workout, sincronizar datos
                try await updateWorkoutWithHealthKitData(workout, hkWorkout: hkWorkout, modelContext: modelContext)
                print("✅ Workout completado con datos de HealthKit")
            } else {
                // No hay workout de HealthKit, completar manualmente
                workout.markAsCompleted()
                try modelContext.save()
                print("✅ Workout completado manualmente (sin datos de HealthKit)")
            }
        } catch {
            // Error al consultar HealthKit, completar manualmente
            print("⚠️ Error al consultar HealthKit: \(error.localizedDescription)")
            workout.markAsCompleted()
            try modelContext.save()
        }
    }
}
