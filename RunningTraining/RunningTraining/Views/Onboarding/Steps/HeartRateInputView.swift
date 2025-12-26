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
    @State private var hrText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    private var isValid: Bool {
        viewModel.maxHeartRate >= 140 && viewModel.maxHeartRate <= 220
    }

    private var suggestedHR: Int {
        // Fórmula simple: 220 - edad promedio (40 años)
        180
    }

    var body: some View {
        OnboardingStepContainer(
            stepNumber: 4,
            totalSteps: 5,
            title: "¿Tu FC máxima?",
            subtitle: "Introduce tu frecuencia cardíaca máxima",
            icon: "heart.fill",
            content: {
                VStack(spacing: 24) {
                    // Input de FC
                    VStack(spacing: 12) {
                        // TextField para valor numérico
                        TextField("180", text: $hrText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                            .multilineTextAlignment(.center)
                            .focused($isTextFieldFocused)
                            .onChange(of: hrText) { oldValue, newValue in
                                // Actualizar viewModel
                                if let hr = Int(newValue) {
                                    viewModel.maxHeartRate = hr
                                }
                            }
                            .onAppear {
                                hrText = "\(viewModel.maxHeartRate)"
                            }

                        Text("bpm")
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
                isTextFieldFocused = false
                viewModel.navigateNext()
            },
            onBack: {
                isTextFieldFocused = false
                viewModel.navigateBack()
            },
            isValid: viewModel.isHeartRateValid
        )
    }
}

#Preview {
    HeartRateInputView(viewModel: OnboardingViewModel())
}
