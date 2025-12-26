//
//  CalendarViewModel.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation
import SwiftData

/// ViewModel para la vista de calendario
@Observable
class CalendarViewModel {
    var selectedWeekIndex: Int = 0
    var trainingPlan: TrainingPlan?

    private let trainingPlanService = TrainingPlanService()

    /// Obtiene el plan activo del usuario
    func loadActivePlan(for user: User) {
        trainingPlan = user.activeTrainingPlan

        // Seleccionar la semana actual por defecto
        if let plan = trainingPlan, let currentWeek = plan.currentWeek {
            selectedWeekIndex = currentWeek.weekNumber - 1
        }
    }

    /// Semana actualmente seleccionada
    var selectedWeek: TrainingWeek? {
        guard let plan = trainingPlan,
              selectedWeekIndex < plan.sortedWeeks.count else {
            return nil
        }
        return plan.sortedWeeks[selectedWeekIndex]
    }

    /// Entrenamientos de la semana seleccionada
    var workoutsForSelectedWeek: [Workout] {
        return selectedWeek?.sortedWorkouts ?? []
    }

    /// Marca un workout como completado/no completado
    func toggleWorkoutCompletion(_ workout: Workout, modelContext: ModelContext) {
        do {
            if workout.isCompleted {
                try trainingPlanService.markWorkoutIncomplete(workout, modelContext: modelContext)
            } else {
                try trainingPlanService.markWorkoutCompleted(workout, modelContext: modelContext)
            }
        } catch {
            print("❌ Error toggling workout completion: \(error)")
        }
    }

    /// Navega a la semana anterior
    func previousWeek() {
        if selectedWeekIndex > 0 {
            selectedWeekIndex -= 1
        }
    }

    /// Navega a la semana siguiente
    func nextWeek() {
        if let plan = trainingPlan, selectedWeekIndex < plan.totalWeeks - 1 {
            selectedWeekIndex += 1
        }
    }

    /// Verifica si hay una semana anterior
    var hasPreviousWeek: Bool {
        return selectedWeekIndex > 0
    }

    /// Verifica si hay una semana siguiente
    var hasNextWeek: Bool {
        guard let plan = trainingPlan else { return false }
        return selectedWeekIndex < plan.totalWeeks - 1
    }
}
