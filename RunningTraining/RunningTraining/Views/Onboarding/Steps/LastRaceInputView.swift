//
//  LastRaceInputView.swift
//  RunningTraining
//
//  Created on 2025-12-25.
//

import SwiftUI

/// Vista para ingresar información sobre la última carrera
struct LastRaceInputView: View {
    @Bindable var viewModel: OnboardingViewModel

    private let raceTypeOptions = ["5K", "10K", "21K", "42K", "Otra"]
    private let raceDistances: [String: Double] = [
        "5K": 5.0,
        "10K": 10.0,
        "21K": 21.0975,
        "42K": 42.195,
        "Otra": 10.0
    ]

    var body: some View {
        OnboardingStepContainer(
            stepNumber: 3,
            totalSteps: 5,
            title: "¿Has corrido recientemente?",
            subtitle: "Ayúdanos a ajustar mejor tu plan",
            icon: "figure.run",
            content: {
                VStack(spacing: 24) {
                    // Toggle para indicar si ha corrido
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $viewModel.hasRecentRace) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("He corrido una carrera recientemente")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary)

                                Text("En los últimos 6 meses")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: AppTheme.primary))
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(12)
                    }

                    if viewModel.hasRecentRace {
                        VStack(spacing: 20) {
                            // Selector de tipo de carrera
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Distancia")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.textSecondary)

                                HStack(spacing: 8) {
                                    ForEach(raceTypeOptions, id: \.self) { type in
                                        Button {
                                            viewModel.lastRaceType = type
                                            viewModel.lastRaceDistance = raceDistances[type] ?? 10.0
                                        } label: {
                                            Text(type)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(
                                                    viewModel.lastRaceType == type ? .white : AppTheme.textPrimary
                                                )
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(viewModel.lastRaceType == type ? AppTheme.primary : AppTheme.cardBackground)
                                                )
                                        }
                                    }
                                }
                            }

                            // Selector de ritmo de la carrera
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Ritmo promedio de la carrera")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.textSecondary)

                                VStack(spacing: 16) {
                                    // Display del valor actual
                                    Text(PaceFormatter.format(
                                        paceMinPerKm: viewModel.lastRacePaceMinPerKm,
                                        useMetric: true
                                    ))
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(AppTheme.primary)

                                    // Slider
                                    VStack(spacing: 8) {
                                        Slider(
                                            value: $viewModel.lastRacePaceMinPerKm,
                                            in: 3.0...10.0,
                                            step: 0.25
                                        )
                                        .tint(AppTheme.primary)

                                        // Labels de rango
                                        HStack {
                                            Text("3:00")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.textSecondary)
                                            Spacer()
                                            Text("Desliza para ajustar")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.textSecondary)
                                            Spacer()
                                            Text("10:00")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                    }
                                }
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(12)
                            }

                            // Tooltip informativo
                            InfoTooltip(message: "Esta información nos ayudará a ajustar mejor tus entrenamientos según tu nivel actual")
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        // Selector de ritmo objetivo cuando NO ha corrido recientemente
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("¿Cuál es tu ritmo objetivo?")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.textSecondary)

                                VStack(spacing: 16) {
                                    // Display del valor actual
                                    Text(PaceFormatter.format(
                                        paceMinPerKm: viewModel.currentPaceMinPerKm,
                                        useMetric: true
                                    ))
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(AppTheme.primary)

                                    // Slider
                                    VStack(spacing: 8) {
                                        Slider(
                                            value: $viewModel.currentPaceMinPerKm,
                                            in: 3.0...10.0,
                                            step: 0.25
                                        )
                                        .tint(AppTheme.primary)

                                        // Labels de rango
                                        HStack {
                                            Text("3:00")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.textSecondary)
                                            Spacer()
                                            Text("Desliza para ajustar")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.textSecondary)
                                            Spacer()
                                            Text("10:00")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                    }
                                }
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(12)
                            }

                            InfoTooltip(message: "Usaremos este ritmo como referencia para crear tu plan personalizado")
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
            },
            onContinue: {
                viewModel.navigateNext()
            },
            onBack: {
                viewModel.navigateBack()
            },
            isValid: viewModel.isLastRaceValid
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.hasRecentRace)
    }
}

#Preview {
    LastRaceInputView(viewModel: OnboardingViewModel())
}
