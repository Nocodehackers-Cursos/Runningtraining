//
//  HeartRateInputView.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

/// Vista para ingresar FC máxima
struct HeartRateInputView: View {
    @Bindable var viewModel: OnboardingViewModel

    private var isValid: Bool {
        viewModel.maxHeartRate >= 140 && viewModel.maxHeartRate <= 220
    }

    var body: some View {
        OnboardingStepContainer(
            stepNumber: 4,
            totalSteps: 5,
            title: "¿Tu FC máxima?",
            subtitle: "Selecciona tu frecuencia cardíaca máxima",
            icon: "heart.fill",
            content: {
                VStack(spacing: 24) {
                    // Slider de FC
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(spacing: 16) {
                            // Display del valor actual
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("\(viewModel.maxHeartRate)")
                                    .font(.system(size: 64, weight: .bold))
                                    .foregroundColor(AppTheme.primary)

                                Text("bpm")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.textSecondary)
                            }

                            // Slider
                            VStack(spacing: 8) {
                                Slider(
                                    value: Binding(
                                        get: { Double(viewModel.maxHeartRate) },
                                        set: { viewModel.maxHeartRate = Int($0) }
                                    ),
                                    in: 140...220,
                                    step: 1
                                )
                                .tint(AppTheme.primary)

                                // Labels de rango
                                HStack {
                                    Text("140")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Text("Desliza para ajustar")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Text("220")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(12)
                    }

                    // Sugerencia calculada
                    VStack(spacing: 8) {
                        Text("Fórmula estimada:")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)

                        Text("220 - tu edad")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.cardBackground)
                    )

                    // Tooltip
                    InfoTooltip(
                        message: "Si no la conoces, usa la fórmula: 220 - tu edad",
                        icon: "heart.fill"
                    )
                }
            },
            onContinue: {
                viewModel.navigateNext()
            },
            onBack: {
                viewModel.navigateBack()
            },
            isValid: viewModel.isHeartRateValid
        )
    }
}

#Preview {
    HeartRateInputView(viewModel: OnboardingViewModel())
}
