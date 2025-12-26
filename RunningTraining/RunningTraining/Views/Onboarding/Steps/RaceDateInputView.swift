//
//  RaceDateInputView.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

/// Vista para seleccionar fecha de la carrera
struct RaceDateInputView: View {
    @Bindable var viewModel: OnboardingViewModel

    private var weeksUntilRace: Int {
        Date().weeksUntil(viewModel.raceDate)
    }

    private var isValid: Bool {
        weeksUntilRace >= 8
    }

    var body: some View {
        OnboardingStepContainer(
            stepNumber: 2,
            totalSteps: 5,
            title: "¿Cuándo es tu carrera?",
            subtitle: "Selecciona la fecha de tu media maratón",
            icon: "calendar",
            content: {
                VStack(spacing: 24) {
                    // DatePicker estilo wheel
                    DatePicker(
                        "",
                        selection: $viewModel.raceDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .accentColor(AppTheme.primary)

                    // Contador de semanas
                    VStack(spacing: 8) {
                        Text("\(weeksUntilRace)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(isValid ? AppTheme.primary : .red)

                        Text("semanas de preparación")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.cardBackground)
                    )

                    // Tooltip
                    if isValid {
                        InfoTooltip(message: "Perfecto! Tienes tiempo suficiente para prepararte adecuadamente")
                    } else {
                        InfoTooltip(message: "Necesitas al menos 8 semanas para prepararte adecuadamente")
                    }
                }
            },
            onContinue: {
                viewModel.navigateNext()
            },
            onBack: {
                viewModel.navigateBack()
            },
            isValid: viewModel.isRaceDateValid
        )
    }
}

#Preview {
    RaceDateInputView(viewModel: OnboardingViewModel())
}
