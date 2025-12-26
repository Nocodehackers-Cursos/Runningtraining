//
//  TrainingPlan.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation
import SwiftData

/// Modelo que representa un plan de entrenamiento completo
@Model
final class TrainingPlan {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var startDate: Date
    var raceDate: Date
    var generatedByAI: Bool
    var promptUsed: String? // Guarda el prompt usado para referencia

    // Análisis del plan (generado por IA)
    var runnerLevel: String? // "principiante", "intermedio", "avanzado"
    var weeklyVolumeKm: Double? // Volumen semanal promedio
    var planReasoning: String? // Explicación del enfoque del plan

    // Relaciones
    @Relationship(deleteRule: .cascade) var weeks: [TrainingWeek]
    var user: User?

    init(startDate: Date, raceDate: Date, generatedByAI: Bool = true) {
        self.id = UUID()
        self.createdAt = Date()
        self.startDate = startDate
        self.raceDate = raceDate
        self.generatedByAI = generatedByAI
        self.weeks = []
    }

    /// Número total de semanas en el plan
    var totalWeeks: Int {
        return weeks.count
    }

    /// Todos los entrenamientos del plan
    var allWorkouts: [Workout] {
        return weeks.flatMap { $0.workouts }
    }

    /// Número total de entrenamientos
    var totalWorkouts: Int {
        return allWorkouts.count
    }

    /// Entrenamientos completados
    var completedWorkouts: Int {
        return allWorkouts.filter { $0.isCompleted }.count
    }

    /// Porcentaje de completitud del plan
    var completionPercentage: Double {
        guard totalWorkouts > 0 else { return 0 }
        return Double(completedWorkouts) / Double(totalWorkouts)
    }

    /// Semana actual del plan (basada en la fecha actual)
    var currentWeek: TrainingWeek? {
        return weeks.first { $0.isCurrentWeek }
    }

    /// Número de la semana actual (1-indexed)
    var currentWeekNumber: Int? {
        return currentWeek?.weekNumber
    }

    /// Próximo entrenamiento sin completar
    var nextWorkout: Workout? {
        return allWorkouts
            .filter { !$0.isCompleted }
            .sorted { $0.scheduledDate < $1.scheduledDate }
            .first
    }

    /// Días hasta la carrera
    var daysUntilRace: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: raceDate)
        return max(0, components.day ?? 0)
    }

    /// Semanas hasta la carrera
    var weeksUntilRace: Int {
        return Date().weeksUntil(raceDate)
    }

    /// Verifica si el plan está activo (fecha actual entre inicio y carrera)
    var isActive: Bool {
        let today = Date()
        return today >= startDate && today <= raceDate
    }

    /// Verifica si el plan está completado (fecha de carrera pasada)
    var isCompleted: Bool {
        return raceDate.isInPast
    }

    /// Semanas ordenadas por número
    var sortedWeeks: [TrainingWeek] {
        return weeks.sorted { $0.weekNumber < $1.weekNumber }
    }

    /// Distancia total planificada del plan
    var totalPlannedDistance: Double {
        return allWorkouts.compactMap { $0.distanceKm }.reduce(0, +)
    }
}
