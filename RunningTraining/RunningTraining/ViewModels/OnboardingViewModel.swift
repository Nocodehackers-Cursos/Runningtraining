//
//  OnboardingViewModel.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation
import SwiftData

/// Estados del onboarding
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case sessions = 1
    case raceDate = 2
    case lastRace = 3
    case heartRate = 4
    case summary = 5
    case generating = 6

    var title: String {
        switch self {
        case .welcome: return "Bienvenido"
        case .sessions: return "Sesiones por Semana"
        case .raceDate: return "Fecha de tu Carrera"
        case .lastRace: return "Tu Última Carrera"
        case .heartRate: return "FC Máxima"
        case .summary: return "Todo Listo!"
        case .generating: return "Generando Plan"
        }
    }

    var stepNumber: Int? {
        // Welcome y generating no cuentan como pasos
        switch self {
        case .welcome, .generating: return nil
        case .sessions: return 1
        case .raceDate: return 2
        case .lastRace: return 3
        case .heartRate: return 4
        case .summary: return 5
        }
    }
}

/// ViewModel para el flujo de onboarding
@Observable
class OnboardingViewModel {
    // Navegación
    var currentStep: OnboardingStep = .welcome
    var completedSteps: Set<OnboardingStep> = []

    // Inputs del usuario
    var sessionsPerWeek: Int = 4
    var raceDate: Date = Calendar.current.date(byAdding: .weekOfYear, value: 12, to: Date())!
    var currentPaceMinPerKm: Double = 6.0
    var maxHeartRate: Int = 180
    var useMetricUnits: Bool = true

    // Última carrera del usuario (opcional, pero mejora el plan)
    var hasRecentRace: Bool = false
    var lastRaceDistance: Double = 10.0 // km (por defecto 10K)
    var lastRacePaceMinPerKm: Double = 6.0 // min/km
    var lastRaceDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    var lastRaceType: String = "10K" // "5K", "10K", "21K", "42K", "Otra"

    // Estados
    var isGenerating: Bool = false
    var errorMessage: String?
    var generatedPlan: TrainingPlan?
    var planGenerationCompleted: Bool = false

    // Progreso de generación
    var generationProgress: Double = 0.0
    var generationMessage: String = ""

    private let trainingPlanService = TrainingPlanService()

    // MARK: - Navegación

    /// Navega al siguiente paso
    func navigateNext() {
        guard canContinueFromCurrentStep else { return }

        completedSteps.insert(currentStep)

        switch currentStep {
        case .welcome:
            currentStep = .sessions
        case .sessions:
            currentStep = .raceDate
        case .raceDate:
            currentStep = .lastRace
        case .lastRace:
            // Sincronizar el ritmo actual con el ritmo de la última carrera
            if hasRecentRace {
                currentPaceMinPerKm = lastRacePaceMinPerKm
            }
            currentStep = .heartRate
        case .heartRate:
            currentStep = .summary
        case .summary:
            currentStep = .generating
        case .generating:
            break
        }
    }

    /// Navega al paso anterior
    func navigateBack() {
        switch currentStep {
        case .welcome:
            break
        case .sessions:
            currentStep = .welcome
        case .raceDate:
            currentStep = .sessions
        case .lastRace:
            currentStep = .raceDate
        case .heartRate:
            currentStep = .lastRace
        case .summary:
            currentStep = .heartRate
        case .generating:
            break
        }
    }

    /// Navega a un paso específico
    func navigateToStep(_ step: OnboardingStep) {
        currentStep = step
    }

    // MARK: - Validación Incremental

    var isSessionsValid: Bool {
        sessionsPerWeek >= 3 && sessionsPerWeek <= 7
    }

    var isRaceDateValid: Bool {
        Date().weeksUntil(raceDate) >= 8
    }

    var isPaceValid: Bool {
        currentPaceMinPerKm >= 3.0 && currentPaceMinPerKm <= 10.0
    }

    var isHeartRateValid: Bool {
        maxHeartRate >= 140 && maxHeartRate <= 220
    }

    var isLastRaceValid: Bool {
        // Si tiene carrera reciente, validar los datos
        if hasRecentRace {
            return lastRaceDistance > 0 && lastRacePaceMinPerKm >= 3.0 && lastRacePaceMinPerKm <= 10.0
        }
        // Si NO tiene carrera reciente, debe tener un ritmo objetivo válido
        return currentPaceMinPerKm >= 3.0 && currentPaceMinPerKm <= 10.0
    }

    var canContinueFromCurrentStep: Bool {
        switch currentStep {
        case .welcome: return true
        case .sessions: return isSessionsValid
        case .raceDate: return isRaceDateValid
        case .lastRace: return isLastRaceValid
        case .heartRate: return isHeartRateValid
        case .summary: return isSessionsValid && isRaceDateValid && isLastRaceValid && isPaceValid && isHeartRateValid
        case .generating: return false
        }
    }

    // MARK: - Generación de Plan

    /// Genera el plan de entrenamiento
    func generatePlan(modelContext: ModelContext) async {
        // Reset estados
        errorMessage = nil
        isGenerating = true
        planGenerationCompleted = false
        currentStep = .generating

        // Iniciar simulación de progreso
        Task {
            await simulateGenerationProgress()
        }

        // Validar inputs
        guard validate() else {
            isGenerating = false
            currentStep = .summary
            return
        }

        do {
            // Crear usuario
            let user = User(
                sessionsPerWeek: sessionsPerWeek,
                raceDate: raceDate,
                currentPaceMinPerKm: currentPaceMinPerKm,
                maxHeartRate: maxHeartRate,
                useMetricUnits: useMetricUnits
            )

            // Añadir datos de última carrera si están disponibles
            if hasRecentRace {
                user.lastRaceDistance = lastRaceDistance
                user.lastRacePaceMinPerKm = lastRacePaceMinPerKm
                user.lastRaceDate = lastRaceDate
                user.lastRaceType = lastRaceType
            }

            // Insertar usuario en SwiftData
            modelContext.insert(user)

            // Generar plan (esto ocurre durante el progreso simulado)
            let plan = try await trainingPlanService.generatePlan(
                for: user,
                modelContext: modelContext
            )

            generatedPlan = plan
            planGenerationCompleted = true

            // Esperar a que la simulación termine
            while generationProgress < 1.0 {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }

            isGenerating = false
            print("✅ Plan generado exitosamente!")
        } catch {
            errorMessage = "Error generando plan: \(error.localizedDescription)"
            isGenerating = false
            currentStep = .summary
            print("❌ Error: \(error)")
        }
    }

    /// Simula el progreso de generación
    private func simulateGenerationProgress() async {
        let stages: [(progress: Double, message: String, duration: UInt64)] = [
            (0.0, "Analizando tu nivel actual...", 500_000_000),
            (0.15, "Calculando zonas de frecuencia cardíaca...", 800_000_000),
            (0.30, "Diseñando periodización...", 1_000_000_000),
            (0.50, "Generando plan con IA...", 8_000_000_000),
            (0.85, "Optimizando entrenamientos...", 1_500_000_000),
            (0.95, "Finalizando detalles...", 500_000_000),
            (1.0, "Plan completado!", 300_000_000)
        ]

        for stage in stages {
            await MainActor.run {
                generationProgress = stage.progress
                generationMessage = stage.message
            }
            try? await Task.sleep(nanoseconds: stage.duration)
        }
    }

    /// Valida los inputs del usuario
    private func validate() -> Bool {
        // Validar fecha de carrera (mínimo 8 semanas en futuro)
        let weeksUntilRace = Date().weeksUntil(raceDate)
        if weeksUntilRace < 8 {
            errorMessage = "La carrera debe ser al menos 8 semanas en el futuro"
            return false
        }

        // Validar FC máxima
        if maxHeartRate < 140 || maxHeartRate > 220 {
            errorMessage = "La frecuencia cardíaca máxima debe estar entre 140 y 220 bpm"
            return false
        }

        // Validar ritmo
        if currentPaceMinPerKm < 3.0 || currentPaceMinPerKm > 10.0 {
            errorMessage = "El ritmo debe estar entre 3:00 y 10:00 min/km"
            return false
        }

        // Validar sesiones por semana
        if sessionsPerWeek < 3 || sessionsPerWeek > 7 {
            errorMessage = "Debes entrenar entre 3 y 7 días por semana"
            return false
        }

        return true
    }

    /// Calcula el número de semanas hasta la carrera
    var weeksUntilRace: Int {
        return Date().weeksUntil(raceDate)
    }

    /// Formatea el ritmo para mostrar
    var formattedPace: String {
        return PaceFormatter.format(paceMinPerKm: currentPaceMinPerKm, useMetric: useMetricUnits)
    }
}
