//
//  SettingsViewModel.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import Foundation
import SwiftData
import HealthKit

@Observable
class SettingsViewModel {
    var user: User?
    var showingDeleteConfirmation = false
    var showingCreateNewPlanConfirmation = false
    var showingEditUserSheet = false
    var errorMessage: String?

    // MARK: - HealthKit Properties
    var healthKitEnabled = false
    var isSyncingHealthKit = false
    var healthKitSyncStatus: String?

    private let trainingPlanService = TrainingPlanService()
    private let healthKitService = HealthKitService.shared

    // MARK: - User Info Computed Properties

    var userName: String {
        "Mi Perfil"
    }

    var sessionsPerWeek: Int {
        user?.sessionsPerWeek ?? 4
    }

    var raceDate: Date {
        user?.raceDate ?? Date()
    }

    var currentPace: Double {
        user?.currentPaceMinPerKm ?? 6.0
    }

    var maxHeartRate: Int {
        user?.maxHeartRate ?? 180
    }

    var useMetricUnits: Bool {
        user?.useMetricUnits ?? true
    }

    var hasActivePlan: Bool {
        user?.activeTrainingPlan != nil
    }

    var planInfo: String {
        guard let plan = user?.activeTrainingPlan else {
            return "No hay plan activo"
        }
        return "\(plan.weeks.count) semanas • \(plan.totalWorkouts) entrenamientos"
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - Methods

    func loadData(for user: User) {
        self.user = user
        checkHealthKitStatus()
    }

    // MARK: - HealthKit Methods

    /// Verifica el estado actual de HealthKit
    func checkHealthKitStatus() {
        guard healthKitService.isHealthDataAvailable else {
            healthKitEnabled = false
            return
        }

        healthKitEnabled = healthKitService.isAuthorized()
    }

    /// Solicita autorización de HealthKit
    func requestHealthKitAuthorization() async {
        guard healthKitService.isHealthDataAvailable else {
            errorMessage = "HealthKit no está disponible en este dispositivo"
            healthKitEnabled = false
            return
        }

        do {
            _ = try await healthKitService.requestAuthorization()

            // Verificar si realmente podemos acceder a los datos
            let canAccess = await healthKitService.canAccessHealthData()

            if canAccess {
                healthKitEnabled = true
                healthKitSyncStatus = "Autorizado ✓"

                // Limpiar el status después de 2 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.healthKitSyncStatus = nil
                }
            } else {
                healthKitEnabled = false
                healthKitSyncStatus = nil
                errorMessage = "No tienes autorización para acceder a HealthKit. Por favor, ve a Ajustes → Privacidad → Salud → RunningTraining y habilita los permisos de lectura."
            }
        } catch {
            errorMessage = "Error al solicitar autorización: \(error.localizedDescription)"
            healthKitEnabled = false
            healthKitSyncStatus = nil
        }
    }

    /// Sincroniza los últimos 30 días de entrenamientos desde HealthKit
    func syncLast30Days(modelContext: ModelContext) async {
        // Verificar acceso real a HealthKit
        let canAccess = await healthKitService.canAccessHealthData()

        if !canAccess {
            healthKitEnabled = false
            errorMessage = "No tienes autorización para acceder a HealthKit. Por favor, habilítalo en Ajustes."
            return
        }

        isSyncingHealthKit = true
        healthKitSyncStatus = "Sincronizando..."

        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!

        do {
            try await trainingPlanService.syncHealthKitWorkouts(
                from: startDate,
                to: endDate,
                modelContext: modelContext
            )

            healthKitSyncStatus = "Sincronizado ✓"

            // Limpiar el status después de 3 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.healthKitSyncStatus = nil
            }
        } catch {
            let errorMsg = error.localizedDescription
            print("❌ Error de sincronización: \(errorMsg)")

            // Verificar si es un error de autorización
            if errorMsg.contains("authorization") || errorMsg.contains("autorización") {
                healthKitEnabled = false
                errorMessage = "No tienes autorización para acceder a HealthKit. Por favor, ve a Ajustes iOS → Privacidad → Salud → RunningTraining."
            } else {
                errorMessage = "Error al sincronizar: \(errorMsg)"
            }

            healthKitSyncStatus = nil
        }

        isSyncingHealthKit = false
    }

    /// Desactiva HealthKit
    func disableHealthKit() {
        healthKitEnabled = false
        healthKitSyncStatus = "HealthKit desactivado"
    }

    func updateUser(
        sessionsPerWeek: Int,
        raceDate: Date,
        currentPace: Double,
        maxHeartRate: Int,
        useMetricUnits: Bool,
        modelContext: ModelContext
    ) {
        guard let user = user else { return }

        user.sessionsPerWeek = sessionsPerWeek
        user.raceDate = raceDate
        user.currentPaceMinPerKm = currentPace
        user.maxHeartRate = maxHeartRate
        user.useMetricUnits = useMetricUnits
        user.updatedAt = Date()

        do {
            try modelContext.save()
            self.user = user
        } catch {
            errorMessage = "Error al guardar cambios: \(error.localizedDescription)"
        }
    }

    func deleteCurrentPlan(modelContext: ModelContext) {
        guard let user = user, let plan = user.activeTrainingPlan else { return }

        do {
            // Eliminar el plan
            modelContext.delete(plan)
            try modelContext.save()

            // Recargar usuario
            self.user = user
        } catch {
            errorMessage = "Error al eliminar plan: \(error.localizedDescription)"
        }
    }

    func deleteUserAndPlan(modelContext: ModelContext) {
        guard let user = user else { return }

        do {
            // Esto eliminará en cascada el plan y todos los workouts
            modelContext.delete(user)
            try modelContext.save()

            self.user = nil
        } catch {
            errorMessage = "Error al eliminar datos: \(error.localizedDescription)"
        }
    }
}
