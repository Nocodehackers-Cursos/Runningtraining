//
//  User.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation
import SwiftData

/// Modelo de usuario con sus preferencias y configuración de entrenamiento
@Model
final class User {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    // Preferencias de entrenamiento
    var sessionsPerWeek: Int
    var raceDate: Date
    var currentPaceMinPerKm: Double
    var maxHeartRate: Int

    // Última carrera del usuario (para personalizar mejor el plan)
    var lastRaceDistance: Double? // en km
    var lastRacePaceMinPerKm: Double? // ritmo de la última carrera
    var lastRaceDate: Date? // fecha de la última carrera
    var lastRaceType: String? // "5K", "10K", "21K", "42K", "Otra"

    // Configuración
    var useMetricUnits: Bool // true = km, false = millas

    // Relaciones
    @Relationship(deleteRule: .cascade) var trainingPlans: [TrainingPlan]
    var activeTrainingPlanID: UUID?

    init(
        sessionsPerWeek: Int,
        raceDate: Date,
        currentPaceMinPerKm: Double,
        maxHeartRate: Int,
        useMetricUnits: Bool = true
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.sessionsPerWeek = sessionsPerWeek
        self.raceDate = raceDate
        self.currentPaceMinPerKm = currentPaceMinPerKm
        self.maxHeartRate = maxHeartRate
        self.useMetricUnits = useMetricUnits
        self.trainingPlans = []
        self.activeTrainingPlanID = nil
    }

    /// Plan de entrenamiento activo (computed property)
    var activeTrainingPlan: TrainingPlan? {
        guard let activeID = activeTrainingPlanID else { return nil }
        return trainingPlans.first { $0.id == activeID }
    }

    /// Establece un plan como activo
    func setActivePlan(_ plan: TrainingPlan) {
        self.activeTrainingPlanID = plan.id
        self.updatedAt = Date()
    }

    /// Zonas de frecuencia cardíaca calculadas
    var heartRateZones: [HeartRateZone] {
        return HeartRateZone.calculateZones(maxHR: maxHeartRate)
    }
}
