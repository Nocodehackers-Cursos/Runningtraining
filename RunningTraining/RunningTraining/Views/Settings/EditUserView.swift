//
//  EditUserView.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI
import SwiftData

struct EditUserView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let user: User
    let onSave: (Int, Date, Double, Int, Bool) -> Void

    @State private var sessionsPerWeek: Int
    @State private var raceDate: Date
    @State private var currentPace: String
    @State private var maxHeartRate: String
    @State private var useMetricUnits: Bool

    @State private var showingError = false
    @State private var errorMessage = ""

    init(user: User, onSave: @escaping (Int, Date, Double, Int, Bool) -> Void) {
        self.user = user
        self.onSave = onSave
        _sessionsPerWeek = State(initialValue: user.sessionsPerWeek)
        _raceDate = State(initialValue: user.raceDate)
        _currentPace = State(initialValue: String(format: "%.1f", user.currentPaceMinPerKm))
        _maxHeartRate = State(initialValue: "\(user.maxHeartRate)")
        _useMetricUnits = State(initialValue: user.useMetricUnits)
    }

    private var weeksUntilRace: Int {
        Calendar.current.dateComponents([.weekOfYear], from: Date(), to: raceDate).weekOfYear ?? 0
    }

    private var canSave: Bool {
        guard let pace = Double(currentPace),
              let hr = Int(maxHeartRate) else {
            return false
        }
        return pace >= 3.0 && pace <= 10.0 &&
               hr >= 140 && hr <= 220 &&
               weeksUntilRace >= 8
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Entrenamientos por semana
                        FormSection(title: "Entrenamientos por semana") {
                            Stepper("\(sessionsPerWeek) días", value: $sessionsPerWeek, in: 3...7)
                                .font(.headline)
                        }

                        // Fecha de la carrera
                        FormSection(title: "Fecha de la carrera") {
                            DatePicker(
                                "",
                                selection: $raceDate,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)

                            if weeksUntilRace >= 8 {
                                Text("\(weeksUntilRace) semanas de preparación")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.primary)
                            } else {
                                Text("Necesitas al menos 8 semanas de preparación")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }

                        // Ritmo actual
                        FormSection(title: "Ritmo actual (min/km)") {
                            TextField("6.0", text: $currentPace)
                                .keyboardType(.decimalPad)
                                .font(.headline)

                            if let pace = Double(currentPace) {
                                Text(PaceFormatter.format(paceMinPerKm: pace, useMetric: true))
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }

                        // FC máxima
                        FormSection(title: "Frecuencia cardíaca máxima") {
                            TextField("180", text: $maxHeartRate)
                                .keyboardType(.numberPad)
                                .font(.headline)

                            Text("Si no la conoces, usa: 220 - tu edad")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }

                        // Sistema de unidades
                        FormSection(title: "Unidades") {
                            Toggle("Usar sistema métrico (km)", isOn: $useMetricUnits)
                                .font(.headline)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding()
                }

                // Botón guardar
                VStack {
                    Spacer()
                    PrimaryButton(
                        title: "Guardar Cambios",
                        action: saveChanges,
                        isDisabled: !canSave
                    )
                    .padding()
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func saveChanges() {
        guard let pace = Double(currentPace),
              let hr = Int(maxHeartRate) else {
            errorMessage = "Por favor verifica que los valores sean correctos"
            showingError = true
            return
        }

        guard weeksUntilRace >= 8 else {
            errorMessage = "La fecha de la carrera debe ser al menos 8 semanas en el futuro"
            showingError = true
            return
        }

        guard pace >= 3.0 && pace <= 10.0 else {
            errorMessage = "El ritmo debe estar entre 3.0 y 10.0 min/km"
            showingError = true
            return
        }

        guard hr >= 140 && hr <= 220 else {
            errorMessage = "La FC máxima debe estar entre 140 y 220 bpm"
            showingError = true
            return
        }

        onSave(sessionsPerWeek, raceDate, pace, hr, useMetricUnits)
        dismiss()
    }
}
