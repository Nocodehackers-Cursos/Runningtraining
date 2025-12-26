//
//  WorkoutViewModel.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation
import SwiftData

/// ViewModel para detalle de workout
@Observable
class WorkoutViewModel {
    let workout: Workout
    private let trainingPlanService = TrainingPlanService()

    init(workout: Workout) {
        self.workout = workout
    }

    /// Toggle completitud del workout
    func toggleCompletion(modelContext: ModelContext) {
        do {
            if workout.isCompleted {
                try trainingPlanService.markWorkoutIncomplete(workout, modelContext: modelContext)
            } else {
                try trainingPlanService.markWorkoutCompleted(workout, modelContext: modelContext)
            }
        } catch {
            print("❌ Error toggling completion: \(error)")
        }
    }

    /// Formatea la distancia
    func formattedDistance(useMetric: Bool) -> String? {
        guard let distance = workout.distanceKm else { return nil }
        return PaceFormatter.formatDistance(distance, useMetric: useMetric)
    }

    /// Formatea la duración
    func formattedDuration() -> String? {
        guard let duration = workout.durationMinutes else { return nil }
        return PaceFormatter.formatDuration(duration)
    }

    /// Formatea el ritmo
    func formattedPace(useMetric: Bool) -> String? {
        guard let pace = workout.targetPaceMinPerKm else { return nil }
        return PaceFormatter.format(paceMinPerKm: pace, useMetric: useMetric)
    }

    /// Formatea la fecha
    var formattedDate: String {
        return workout.scheduledDate.formattedLong()
    }
}
