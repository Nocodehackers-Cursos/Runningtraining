//
//  WorkoutMetrics.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import Foundation
import HealthKit

/// Estructura que encapsula las métricas extraídas de un workout de HealthKit
struct WorkoutMetrics {
    // MARK: - Identificación

    /// UUID único del workout de HealthKit
    let healthKitUUID: UUID

    /// Fecha de inicio del workout
    let startDate: Date

    /// Fecha de fin del workout
    let endDate: Date

    // MARK: - Métricas de Distancia y Tiempo

    /// Distancia total en metros
    let distance: Double

    /// Duración total en segundos
    let duration: TimeInterval

    /// Ritmo promedio en minutos por kilómetro
    let averagePace: Double

    // MARK: - Métricas de Frecuencia Cardíaca

    /// Frecuencia cardíaca promedio en BPM (opcional)
    let averageHeartRate: Int?

    /// Frecuencia cardíaca máxima en BPM (opcional)
    let maxHeartRate: Int?

    /// Frecuencia cardíaca mínima en BPM (opcional)
    let minHeartRate: Int?

    // MARK: - Inicializadores

    init(
        healthKitUUID: UUID,
        startDate: Date,
        endDate: Date,
        distance: Double,
        duration: TimeInterval,
        averagePace: Double,
        averageHeartRate: Int? = nil,
        maxHeartRate: Int? = nil,
        minHeartRate: Int? = nil
    ) {
        self.healthKitUUID = healthKitUUID
        self.startDate = startDate
        self.endDate = endDate
        self.distance = distance
        self.duration = duration
        self.averagePace = averagePace
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.minHeartRate = minHeartRate
    }

    // MARK: - Computed Properties

    /// Distancia en kilómetros
    var distanceInKm: Double {
        distance / 1000.0
    }

    /// Duración en minutos
    var durationInMinutes: Double {
        duration / 60.0
    }

    /// Velocidad promedio en km/h
    var averageSpeed: Double {
        guard duration > 0 else { return 0 }
        return (distance / 1000.0) / (duration / 3600.0)
    }
}

// MARK: - CustomStringConvertible

extension WorkoutMetrics: CustomStringConvertible {
    var description: String {
        var desc = """
        WorkoutMetrics(
          UUID: \(healthKitUUID)
          Distancia: \(String(format: "%.2f", distanceInKm)) km
          Duración: \(String(format: "%.1f", durationInMinutes)) min
          Ritmo: \(String(format: "%.2f", averagePace)) min/km
        """

        if let avgHR = averageHeartRate {
            desc += "\n  FC Promedio: \(avgHR) bpm"
        }
        if let maxHR = maxHeartRate {
            desc += "\n  FC Máxima: \(maxHR) bpm"
        }

        desc += "\n)"
        return desc
    }
}
