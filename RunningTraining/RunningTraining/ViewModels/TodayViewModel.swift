//
//  TodayViewModel.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import Foundation
import SwiftData

@Observable
class TodayViewModel {
    var trainingPlan: TrainingPlan?
    private let trainingPlanService = TrainingPlanService()

    // MARK: - Computed Properties

    var todayWorkout: Workout? {
        trainingPlan?.allWorkouts.first { $0.isToday }
    }

    var currentWeek: TrainingWeek? {
        trainingPlan?.currentWeek
    }

    var nextWorkout: Workout? {
        guard let plan = trainingPlan else { return nil }
        return plan.allWorkouts
            .filter { !$0.isCompleted && ($0.isUpcoming || $0.isToday) }
            .sorted { $0.scheduledDate < $1.scheduledDate }
            .first
    }

    var upcomingWorkouts: [Workout] {
        guard let plan = trainingPlan else { return [] }
        return plan.allWorkouts
            .filter { !$0.isCompleted && $0.isUpcoming }
            .sorted { $0.scheduledDate < $1.scheduledDate }
            .prefix(3)
            .map { $0 }
    }

    var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Buenos días"
        case 12..<20: return "Buenas tardes"
        default: return "Buenas noches"
        }
    }

    var weekProgress: String {
        guard let week = currentWeek else { return "0/0" }
        return "\(week.completedWorkoutsCount)/\(week.totalWorkoutsCount)"
    }

    var weekDistance: String {
        guard let week = currentWeek else { return "0 km" }
        let completed = week.workouts
            .filter { $0.isCompleted }
            .compactMap { $0.distanceKm }
            .reduce(0, +)
        let planned = week.plannedDistance
        return String(format: "%.1f / %.1f km", completed, planned)
    }

    var weekCompletionPercentage: Double {
        currentWeek?.completionPercentage ?? 0
    }

    var daysUntilRace: Int {
        trainingPlan?.daysUntilRace ?? 0
    }

    // MARK: - Methods

    func loadData(for user: User) {
        trainingPlan = user.activeTrainingPlan
    }

    func completeWorkout(_ workout: Workout, modelContext: ModelContext) {
        do {
            try trainingPlanService.markWorkoutCompleted(workout, modelContext: modelContext)
        } catch {
            print("❌ Error completing workout: \(error)")
        }
    }
}
