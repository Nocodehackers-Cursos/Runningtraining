//
//  UserInputView.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import SwiftUI
import SwiftData

/// Vista de formulario para recoger datos del usuario
struct UserInputView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Configura tu Plan")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Responde estas preguntas para generar tu plan personalizado")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                // Formulario
                VStack(spacing: 20) {
                    // Sesiones por semana
                    FormSection(title: "Entrenamientos por semana") {
                        Stepper("\(viewModel.sessionsPerWeek) días", value: $viewModel.sessionsPerWeek, in: 3...7)
                            .font(.headline)
                    }

                    // Fecha de la carrera
                    FormSection(title: "Fecha de tu media maratón") {
                        DatePicker(
                            "Fecha",
                            selection: $viewModel.raceDate,
                            in: Date.now...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)

                        Text("\(viewModel.weeksUntilRace) semanas de preparación")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Ritmo actual
                    FormSection(title: "Tu ritmo actual (min/km)") {
                        HStack {
                            Text("Ritmo:")
                            Spacer()
                            TextField("6.0", value: $viewModel.currentPaceMinPerKm, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("min/km")
                        }

                        Text(viewModel.formattedPace)
                            .font(.caption)
                            .foregroundColor(AppTheme.primary)
                    }

                    // FC máxima
                    FormSection(title: "Frecuencia cardíaca máxima") {
                        HStack {
                            Text("FC máx:")
                            Spacer()
                            TextField("180", value: $viewModel.maxHeartRate, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("bpm")
                        }

                        Text("Si no la conoces, usa: 220 - tu edad")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding(.horizontal)

                // Mensaje de error si existe
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                // Botón generar plan
                PrimaryButton(
                    title: "Generar Plan",
                    action: {
                        Task {
                            await viewModel.generatePlan(modelContext: modelContext)
                        }
                    },
                    isLoading: viewModel.isGenerating
                )
                .padding(.horizontal)
                .padding(.bottom, 32)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

/// Sección del formulario
struct FormSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: 8) {
                content
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
        }
    }
}

#Preview {
    UserInputView(viewModel: OnboardingViewModel())
        .modelContainer(for: [User.self, TrainingPlan.self])
}
