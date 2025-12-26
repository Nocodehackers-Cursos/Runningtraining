//
//  TodayWorkoutCard.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

struct TodayWorkoutCard: View {
    let workout: Workout
    let maxHR: Int
    let useMetric: Bool
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("ENTRENAMIENTO DE HOY")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()

                HStack(spacing: 8) {
                    // HealthKit badge
                    if workout.hasHealthKitData {
                        HealthKitBadge(synced: true)
                    }

                    // Completado badge
                    if workout.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                }
            }

            // Título y tipo
            VStack(alignment: .leading, spacing: 8) {
                Text(workout.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.colorForWorkoutType(workout.workoutType))
                        .frame(width: 4, height: 20)

                    Text(workout.workoutType.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.colorForWorkoutType(workout.workoutType))
                }
            }

            // Stats Grid 2x2 (solo resumen rápido)
            HStack(spacing: 12) {
                if let distance = workout.distanceKm {
                    QuickStatView(
                        icon: "figure.run",
                        value: PaceFormatter.formatDistance(distance, useMetric: useMetric)
                    )
                }

                if let pace = workout.targetPaceMinPerKm {
                    QuickStatView(
                        icon: "speedometer",
                        value: PaceFormatter.format(paceMinPerKm: pace, useMetric: useMetric)
                    )
                }
            }

            // Botón de completar (solo si no está completado)
            if !workout.isCompleted {
                Button(action: onComplete) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("Marcar como Completado")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.colorForWorkoutType(workout.workoutType))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    AppTheme.cardBackground,
                    AppTheme.cardBackground.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.colorForWorkoutType(workout.workoutType).opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

struct QuickStatView: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}
