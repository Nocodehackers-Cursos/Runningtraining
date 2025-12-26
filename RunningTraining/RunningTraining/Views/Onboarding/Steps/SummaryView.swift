//
//  SummaryView.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI
import SwiftData

/// Vista de resumen antes de generar el plan
struct SummaryView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(\.modelContext) private var modelContext

    private var formattedRaceDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: viewModel.raceDate)
    }

    private var weeksInfo: String {
        "\(viewModel.weeksUntilRace) semanas"
    }

    var body: some View {
        OnboardingStepContainer(
            stepNumber: 5,
            totalSteps: 5,
            title: "Todo Listo!",
            subtitle: "Revisa tus datos antes de generar tu plan",
            icon: "checkmark.circle.fill",
            content: {
                VStack(spacing: 16) {
                    // Cards editables
                    EditableDataCard(
                        title: "Sesiones por semana",
                        value: "\(viewModel.sessionsPerWeek) días",
                        icon: "figure.run"
                    ) {
                        viewModel.navigateToStep(.sessions)
                    }

                    EditableDataCard(
                        title: "Fecha de carrera",
                        value: "\(formattedRaceDate) (\(weeksInfo))",
                        icon: "calendar"
                    ) {
                        viewModel.navigateToStep(.raceDate)
                    }

                    EditableDataCard(
                        title: "Ritmo actual",
                        value: viewModel.formattedPace,
                        icon: "speedometer"
                    ) {
                        viewModel.navigateToStep(.pace)
                    }

                    EditableDataCard(
                        title: "FC máxima",
                        value: "\(viewModel.maxHeartRate) bpm",
                        icon: "heart.fill"
                    ) {
                        viewModel.navigateToStep(.heartRate)
                    }

                    // Nota informativa
                    InfoTooltip(message: "Toca cualquier campo para editarlo")
                }
            },
            onContinue: {
                Task {
                    await viewModel.generatePlan(modelContext: modelContext)
                }
            },
            onBack: {
                viewModel.navigateBack()
            },
            continueButtonTitle: "Generar mi Plan",
            isValid: viewModel.canContinueFromCurrentStep
        )
    }
}

#Preview {
    SummaryView(viewModel: OnboardingViewModel())
        .modelContainer(for: [User.self, TrainingPlan.self])
}
