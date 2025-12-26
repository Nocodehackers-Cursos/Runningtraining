//
//  PaceInputView.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

/// Vista para ingresar ritmo actual
struct PaceInputView: View {
    @Bindable var viewModel: OnboardingViewModel
    @State private var paceText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    private var isValid: Bool {
        viewModel.currentPaceMinPerKm >= 3.0 && viewModel.currentPaceMinPerKm <= 10.0
    }

    private var formattedPace: String {
        PaceFormatter.format(paceMinPerKm: viewModel.currentPaceMinPerKm, useMetric: true)
    }

    var body: some View {
        OnboardingStepContainer(
            stepNumber: 3,
            totalSteps: 5,
            title: "¿Cuál es tu ritmo actual?",
            subtitle: "Introduce tu ritmo promedio en carreras de 10K",
            icon: "speedometer",
            content: {
                VStack(spacing: 24) {
                    // Input de ritmo
                    VStack(spacing: 12) {
                        // TextField para valor decimal
                        TextField("6.0", text: $paceText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                            .multilineTextAlignment(.center)
                            .focused($isTextFieldFocused)
                            .onChange(of: paceText) { oldValue, newValue in
                                // Actualizar viewModel
                                if let pace = Double(newValue) {
                                    viewModel.currentPaceMinPerKm = pace
                                }
                            }
                            .onAppear {
                                paceText = String(format: "%.1f", viewModel.currentPaceMinPerKm)
                            }

                        Text("min/km")
                            .font(.title3)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.cardBackground)
                    )
                    .onTapGesture {
                        isTextFieldFocused = true
                    }

                    // Mostrar formato legible
                    if isValid {
                        VStack(spacing: 8) {
                            Text("Ritmo:")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)

                            Text(formattedPace)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.primary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.primary.opacity(0.1))
                        )
                    }

                    // Tooltip
                    InfoTooltip(message: "Introduce tu ritmo promedio en min/km (ej: 5.5 para 5:30/km)")
                }
            },
            onContinue: {
                isTextFieldFocused = false
                viewModel.navigateNext()
            },
            onBack: {
                isTextFieldFocused = false
                viewModel.navigateBack()
            },
            isValid: viewModel.isPaceValid
        )
    }
}

#Preview {
    PaceInputView(viewModel: OnboardingViewModel())
}
