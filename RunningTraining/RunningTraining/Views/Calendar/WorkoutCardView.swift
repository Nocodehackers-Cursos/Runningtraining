//
//  WorkoutCardView.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import SwiftUI

/// Card para preview de un workout
struct WorkoutCardView: View {
    let workout: Workout
    let maxHR: Int
    let useMetric: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Icono del tipo de workout
            Image(systemName: workout.workoutType.systemImageName)
                .font(.title2)
                .foregroundColor(workout.isCompleted ? .green : .blue)
                .frame(width: 44, height: 44)
                .background(workout.isCompleted ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 6) {
                // Título y fecha
                HStack {
                    Text(workout.title)
                        .font(.headline)

                    Spacer()

                    if workout.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }

                // Distancia o duración
                if let distance = workout.distanceKm {
                    Text(PaceFormatter.formatDistance(distance, useMetric: useMetric))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else if let duration = workout.durationMinutes {
                    Text(PaceFormatter.formatDuration(duration))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Ritmo objetivo
                if let pace = workout.targetPaceMinPerKm {
                    Text("Ritmo: \(PaceFormatter.format(paceMinPerKm: pace, useMetric: useMetric))")
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                // Zona FC
                if let zone = workout.getHeartRateZone(maxHR: maxHR) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(zone.zone.color)
                            .frame(width: 8, height: 8)

                        Text("\(zone.zone.description) (\(zone.bpmRange))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    let workout = Workout(
        scheduledDate: Date(),
        workoutType: .easyRun,
        title: "Carrera Fácil",
        description: "Carrera suave"
    )
    workout.distanceKm = 8.0
    workout.targetPaceMinPerKm = 6.0
    workout.primaryHeartRateZone = "zone2"
    workout.heartRateZonePercentageMin = 60
    workout.heartRateZonePercentageMax = 70

    return WorkoutCardView(workout: workout, maxHR: 180, useMetric: true)
        .padding()
}
