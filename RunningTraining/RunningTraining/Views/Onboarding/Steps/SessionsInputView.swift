//
//  SessionsInputView.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

/// Vista para seleccionar sesiones por semana
struct SessionsInputView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingStepContainer(
            stepNumber: 1,
            totalSteps: 5,
            title: "¿Cuántas veces entrenas?",
            subtitle: "Selecciona el número de sesiones por semana",
            icon: "figure.run",
            content: {
                VStack(spacing: 24) {
                    // Stepper visual grande
                    HStack(spacing: 32) {
                        // Botón menos
                        Button(action: {
                            if viewModel.sessionsPerWeek > 3 {
                                viewModel.sessionsPerWeek -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(viewModel.sessionsPerWeek > 3 ? AppTheme.primary : AppTheme.textSecondary.opacity(0.3))
                        }
                        .disabled(viewModel.sessionsPerWeek <= 3)

                        // Valor actual
                        VStack(spacing: 8) {
                            Text("\(viewModel.sessionsPerWeek)")
                                .font(.system(size: 72, weight: .bold))
                                .foregroundColor(AppTheme.primary)

                            Text("días")
                                .font(.title3)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .frame(minWidth: 120)

                        // Botón más
                        Button(action: {
                            if viewModel.sessionsPerWeek < 7 {
                                viewModel.sessionsPerWeek += 1
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(viewModel.sessionsPerWeek < 7 ? AppTheme.primary : AppTheme.textSecondary.opacity(0.3))
                        }
                        .disabled(viewModel.sessionsPerWeek >= 7)
                    }
                    .padding(.vertical, 32)

                    // Tooltip
                    InfoTooltip(message: "Recomendamos 4-5 sesiones para mejores resultados")
                }
            },
            onContinue: {
                viewModel.navigateNext()
            },
            onBack: nil,
            isValid: viewModel.isSessionsValid
        )
    }
}

#Preview {
    SessionsInputView(viewModel: OnboardingViewModel())
}
