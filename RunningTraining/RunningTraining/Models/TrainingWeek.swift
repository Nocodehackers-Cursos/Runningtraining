//
//  TrainingWeek.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation
import SwiftData

/// Modelo que representa una semana de entrenamiento
@Model
final class TrainingWeek {
    @Attribute(.unique) var id: UUID
    var weekNumber: Int
    var startDate: Date
    var focus: String // ej: "Base Building", "Speed Work", "Taper"
    var totalDistanceKm: Double?

    // Relaciones
    @Relationship(deleteRule: .cascade) var workouts: [Workout]
    var trainingPlan: TrainingPlan?

    init(weekNumber: Int, startDate: Date, focus: String) {
        self.id = UUID()
        self.weekNumber = weekNumber
        self.startDate = startDate
        self.focus = focus
        self.workouts = []
    }

    /// Fecha de fin de la semana (computed)
    var endDate: Date {
        return startDate.addingDays(6)
    }

    /// Número de entrenamientos completados
    var completedWorkoutsCount: Int {
        return workouts.filter { $0.isCompleted }.count
    }

    /// Número total de entrenamientos
    var totalWorkoutsCount: Int {
        return workouts.count
    }

    /// Porcentaje de completitud de la semana
    var completionPercentage: Double {
        guard totalWorkoutsCount > 0 else { return 0 }
        return Double(completedWorkoutsCount) / Double(totalWorkoutsCount)
    }

    /// Distancia total planificada para la semana
    var plannedDistance: Double {
        return workouts.compactMap { $0.distanceKm }.reduce(0, +)
    }

    /// Verifica si la semana es la semana actual
    var isCurrentWeek: Bool {
        let today = Date()
        return today >= startDate && today <= endDate
    }

    /// Verifica si la semana está en el futuro
    var isUpcoming: Bool {
        return startDate.isInFuture
    }

    /// Verifica si la semana está en el pasado
    var isPast: Bool {
        return endDate.isInPast
    }

    /// Devuelve los entrenamientos ordenados por fecha
    var sortedWorkouts: [Workout] {
        return workouts.sorted { $0.scheduledDate < $1.scheduledDate }
    }
}
