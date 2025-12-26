//
//  SettingsView.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var users: [User]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()
    @Binding var selectedTab: AppTab

    private var currentUser: User? {
        users.first
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if let user = currentUser {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.primary)

                            Text(viewModel.userName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)

                            if viewModel.hasActivePlan {
                                Text(viewModel.planInfo)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)

                        // Información del Usuario
                        SettingsSectionView(title: "TU PERFIL") {
                            SettingsRowView(
                                icon: "calendar",
                                title: "Entrenamientos",
                                value: "\(viewModel.sessionsPerWeek) por semana"
                            )

                            SettingsRowView(
                                icon: "flag.checkered",
                                title: "Fecha de la carrera",
                                value: formatDate(viewModel.raceDate)
                            )

                            SettingsRowView(
                                icon: "speedometer",
                                title: "Ritmo actual",
                                value: PaceFormatter.format(paceMinPerKm: viewModel.currentPace, useMetric: true)
                            )

                            SettingsRowView(
                                icon: "heart.fill",
                                title: "FC Máxima",
                                value: "\(viewModel.maxHeartRate) bpm"
                            )

                            Button {
                                viewModel.showingEditUserSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundColor(AppTheme.primary)
                                    Text("Editar Perfil")
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(12)
                            }
                        }

                        // Apple Health
                        SettingsSectionView(title: "APPLE HEALTH") {
                            VStack(spacing: 12) {
                                Toggle(isOn: Binding(
                                    get: { viewModel.healthKitEnabled },
                                    set: { newValue in
                                        if newValue {
                                            Task {
                                                await viewModel.requestHealthKitAuthorization()
                                            }
                                        } else {
                                            viewModel.disableHealthKit()
                                        }
                                    }
                                )) {
                                    HStack {
                                        Image(systemName: "heart.circle.fill")
                                            .foregroundColor(.red)
                                            .frame(width: 24)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Sincronizar con Health")
                                                .foregroundColor(AppTheme.textPrimary)
                                                .fontWeight(.medium)

                                            if let status = viewModel.healthKitSyncStatus {
                                                Text(status)
                                                    .font(.caption)
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(12)

                                if viewModel.healthKitEnabled {
                                    VStack(spacing: 8) {
                                        Text("Los entrenamientos grabados con Apple Watch o iPhone se sincronizarán automáticamente.")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 4)

                                        Button {
                                            Task {
                                                await viewModel.syncLast30Days(modelContext: modelContext)
                                            }
                                        } label: {
                                            HStack {
                                                if viewModel.isSyncingHealthKit {
                                                    ProgressView()
                                                        .scaleEffect(0.8)
                                                } else {
                                                    Image(systemName: "arrow.triangle.2.circlepath")
                                                }

                                                Text(viewModel.isSyncingHealthKit ? "Sincronizando..." : "Sincronizar últimos 30 días")
                                                    .fontWeight(.medium)
                                                Spacer()
                                            }
                                            .foregroundColor(AppTheme.primary)
                                            .padding()
                                            .background(AppTheme.cardBackground)
                                            .cornerRadius(12)
                                        }
                                        .disabled(viewModel.isSyncingHealthKit)
                                    }
                                }
                            }
                        }

                        // Gestión del Plan
                        if viewModel.hasActivePlan {
                            SettingsSectionView(title: "GESTIÓN DE PLAN") {
                                Button {
                                    viewModel.showingCreateNewPlanConfirmation = true
                                } label: {
                                    SettingsActionRow(
                                        icon: "plus.circle.fill",
                                        title: "Crear Nuevo Plan",
                                        iconColor: AppTheme.primary
                                    )
                                }

                                Button {
                                    viewModel.showingDeleteConfirmation = true
                                } label: {
                                    SettingsActionRow(
                                        icon: "trash.circle.fill",
                                        title: "Eliminar Plan Actual",
                                        iconColor: .red
                                    )
                                }
                            }
                        } else {
                            SettingsSectionView(title: "GESTIÓN DE PLAN") {
                                Text("No tienes un plan activo")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding()

                                Button {
                                    viewModel.showingCreateNewPlanConfirmation = true
                                } label: {
                                    SettingsActionRow(
                                        icon: "plus.circle.fill",
                                        title: "Crear Plan de Entrenamiento",
                                        iconColor: AppTheme.primary
                                    )
                                }
                            }
                        }

                        // Información de la App
                        SettingsSectionView(title: "INFORMACIÓN") {
                            SettingsRowView(
                                icon: "app.badge",
                                title: "Versión",
                                value: "\(viewModel.appVersion) (\(viewModel.buildNumber))"
                            )

                            SettingsRowView(
                                icon: "sparkles",
                                title: "Powered by",
                                value: "OpenAI GPT-4o"
                            )

                            Link(destination: URL(string: "https://github.com")!) {
                                SettingsActionRow(
                                    icon: "info.circle.fill",
                                    title: "Ayuda y Soporte",
                                    iconColor: AppTheme.primary
                                )
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            } else {
                LoadingView(message: "Cargando datos...")
            }

            // Bottom Navigation Bar
            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $viewModel.showingEditUserSheet) {
            if let user = currentUser {
                EditUserView(user: user) { sessions, date, pace, hr, metric in
                    viewModel.updateUser(
                        sessionsPerWeek: sessions,
                        raceDate: date,
                        currentPace: pace,
                        maxHeartRate: hr,
                        useMetricUnits: metric,
                        modelContext: modelContext
                    )
                }
            }
        }
        .alert("Crear Nuevo Plan", isPresented: $viewModel.showingCreateNewPlanConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Continuar", role: .destructive) {
                viewModel.deleteUserAndPlan(modelContext: modelContext)
            }
        } message: {
            Text("Esto eliminará tu plan actual y tus datos. ¿Estás seguro?")
        }
        .alert("Eliminar Plan", isPresented: $viewModel.showingDeleteConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                viewModel.deleteCurrentPlan(modelContext: modelContext)
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar tu plan actual? Esta acción no se puede deshacer.")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .onAppear {
            if let user = currentUser {
                viewModel.loadData(for: user)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

// MARK: - Components

struct SettingsSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 8) {
                content
            }
        }
    }
}

struct SettingsRowView: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(AppTheme.primary)

            Text(title)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Text(value)
                .foregroundColor(AppTheme.textSecondary)
                .font(.subheadline)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}

struct SettingsActionRow: View {
    let icon: String
    let title: String
    let iconColor: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(iconColor)

            Text(title)
                .foregroundColor(AppTheme.textPrimary)
                .fontWeight(.medium)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    SettingsView(selectedTab: .constant(.support))
        .modelContainer(for: [User.self, TrainingPlan.self])
}
