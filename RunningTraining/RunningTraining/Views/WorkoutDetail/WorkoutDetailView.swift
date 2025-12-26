//
//  WorkoutDetailView.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//  Redesigned with Runna-inspired UI
//

import SwiftUI
import SwiftData

/// Vista de detalle de workout estilo Runna
struct WorkoutDetailView: View {
    let workout: Workout
    let maxHR: Int
    let useMetric: Bool

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: WorkoutViewModel

    init(workout: Workout, maxHR: Int, useMetric: Bool) {
        self.workout = workout
        self.maxHR = maxHR
        self.useMetric = useMetric
        _viewModel = State(initialValue: WorkoutViewModel(workout: workout))
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header con icono grande
                    VStack(spacing: 16) {
                        // Barra de color
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.colorForWorkoutType(workout.workoutType))
                            .frame(height: 4)

                        // Icono
                        Image(systemName: workout.workoutType.systemImageName)
                            .font(.system(size: 50))
                            .foregroundColor(AppTheme.colorForWorkoutType(workout.workoutType))

                        // Título
                        Text(workout.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)

                        // Tipo y fecha
                        VStack(spacing: 4) {
                            Text(workout.workoutType.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppTheme.colorForWorkoutType(workout.workoutType))

                            Text(viewModel.formattedDate)
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Stats Grid 2x2
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            // Distancia
                            if let distance = viewModel.formattedDistance(useMetric: useMetric) {
                                StatCard(icon: "figure.run", title: "Distancia", value: distance, fullWidth: false)
                            }

                            // Duración
                            if let duration = viewModel.formattedDuration() {
                                StatCard(icon: "clock", title: "Duración", value: duration, fullWidth: false)
                            }
                        }

                        HStack(spacing: 12) {
                            // Ritmo
                            if let pace = viewModel.formattedPace(useMetric: useMetric) {
                                StatCard(icon: "speedometer", title: "Ritmo Objetivo", value: pace, fullWidth: false)
                            }

                            // Zona FC (mismo formato que otras stats)
                            if let zone = workout.getHeartRateZone(maxHR: maxHR) {
                                StatCard(
                                    icon: "heart.fill",
                                    title: "Zona FC",
                                    value: zone.bpmRange,
                                    fullWidth: false,
                                    customColor: zone.zone.color
                                )
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Barra Visual de Intensidad FC
                    if let zone = workout.getHeartRateZone(maxHR: maxHR) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Intensidad del Entrenamiento")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)

                            // Barra de intensidad visual
                            ZStack(alignment: .leading) {
                                // Fondo con todas las zonas
                                HStack(spacing: 2) {
                                    ForEach([HeartRateZone.Zone.zone1, .zone2, .zone3, .zone4, .zone5], id: \.self) { z in
                                        Rectangle()
                                            .fill(z.color.opacity(z == zone.zone ? 1.0 : 0.3))
                                            .frame(height: 40)
                                    }
                                }
                                .cornerRadius(8)

                                // Indicador de zona actual
                                GeometryReader { geometry in
                                    let zoneIndex = getZoneIndex(zone.zone)
                                    let zoneWidth = geometry.size.width / 5

                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.white, lineWidth: 3)
                                        .frame(width: zoneWidth, height: 40)
                                        .offset(x: CGFloat(zoneIndex) * zoneWidth)
                                }
                            }
                            .frame(height: 40)

                            // Labels de zonas
                            HStack(spacing: 0) {
                                ForEach([1, 2, 3, 4, 5], id: \.self) { z in
                                    Text("Z\(z)")
                                        .font(.caption2)
                                        .fontWeight(z == (getZoneIndex(zone.zone) + 1) ? .bold : .regular)
                                        .foregroundColor(z == (getZoneIndex(zone.zone) + 1) ? .white : AppTheme.textSecondary)
                                        .frame(maxWidth: .infinity)
                                }
                            }

                            // Info adicional de la zona
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(zone.zone.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text(zone.zone.description)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }

                                Spacer()

                                Text(zone.percentageRange)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(zone.zone.color)
                            }
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // Descripción
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Descripción")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)

                        Text(workout.workoutDescription)
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Objetivos
                    if !workout.goals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Objetivos del Entrenamiento")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)

                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(workout.goals, id: \.self) { goal in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppTheme.colorForWorkoutType(workout.workoutType))
                                            .font(.body)

                                        Text(goal)
                                            .font(.subheadline)
                                            .foregroundColor(AppTheme.textSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // Botón de completar
                    Button(action: {
                        viewModel.toggleCompletion(modelContext: modelContext)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: workout.isCompleted ? "xmark.circle.fill" : "checkmark.circle.fill")
                                .font(.title3)

                            Text(workout.isCompleted ? "Marcar como Pendiente" : "Marcar como Completado")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            workout.isCompleted
                                ? AppTheme.secondaryBackground
                                : AppTheme.colorForWorkoutType(workout.workoutType)
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .padding(.top)
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}

/// Card de estadística
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var fullWidth: Bool = false
    var customColor: Color? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(customColor ?? AppTheme.primary)

            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)

                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .frame(minWidth: 0, maxWidth: fullWidth ? .infinity : .infinity)
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}

/// Helper para obtener el índice de zona (0-4)
private func getZoneIndex(_ zone: HeartRateZone.Zone) -> Int {
    switch zone {
    case .zone1: return 0
    case .zone2: return 1
    case .zone3: return 2
    case .zone4: return 3
    case .zone5: return 4
    }
}

#Preview {
    let workout = Workout(
        scheduledDate: Date(),
        workoutType: .longRun,
        title: "Carrera Larga",
        description: "Carrera larga a ritmo cómodo para construir resistencia aeróbica."
    )
    workout.distanceKm = 16.0
    workout.targetPaceMinPerKm = 6.2
    workout.primaryHeartRateZone = "zone2"
    workout.heartRateZonePercentageMin = 60
    workout.heartRateZonePercentageMax = 70
    workout.goals = [
        "Construir resistencia aeróbica de larga duración",
        "Mantener ritmo conversacional durante todo el entreno",
        "Acostumbrar las piernas a correr distancias largas"
    ]

    return WorkoutDetailView(workout: workout, maxHR: 180, useMetric: true)
        .modelContainer(for: [Workout.self])
}
