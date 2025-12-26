//
//  PaceFormatter.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation

/// Utilidad para formatear y convertir ritmos de carrera
struct PaceFormatter {
    /// Formatea un ritmo en min/km para mostrar en la UI
    /// - Parameters:
    ///   - paceMinPerKm: Ritmo en minutos por kilómetro
    ///   - useMetric: true para km, false para millas
    /// - Returns: String formateado (ej: "5:30 /km" o "8:51 /mi")
    static func format(paceMinPerKm: Double, useMetric: Bool = true) -> String {
        let pace = useMetric ? paceMinPerKm : convertToMinPerMile(paceMinPerKm)
        let unit = useMetric ? "/km" : "/mi"

        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)

        return String(format: "%d:%02d %@", minutes, seconds, unit)
    }

    /// Convierte ritmo de min/km a min/milla
    /// - Parameter minPerKm: Ritmo en minutos por kilómetro
    /// - Returns: Ritmo en minutos por milla
    static func convertToMinPerMile(_ minPerKm: Double) -> Double {
        return minPerKm * 1.60934
    }

    /// Convierte ritmo de min/milla a min/km
    /// - Parameter minPerMile: Ritmo en minutos por milla
    /// - Returns: Ritmo en minutos por kilómetro
    static func convertToMinPerKm(_ minPerMile: Double) -> Double {
        return minPerMile / 1.60934
    }

    /// Formatea una distancia
    /// - Parameters:
    ///   - distanceKm: Distancia en kilómetros
    ///   - useMetric: true para km, false para millas
    /// - Returns: String formateado (ej: "10.5 km" o "6.5 mi")
    static func formatDistance(_ distanceKm: Double, useMetric: Bool = true) -> String {
        let distance = useMetric ? distanceKm : convertKmToMiles(distanceKm)
        let unit = useMetric ? "km" : "mi"

        return String(format: "%.1f %@", distance, unit)
    }

    /// Convierte kilómetros a millas
    /// - Parameter km: Distancia en kilómetros
    /// - Returns: Distancia en millas
    static func convertKmToMiles(_ km: Double) -> Double {
        return km * 0.621371
    }

    /// Convierte millas a kilómetros
    /// - Parameter miles: Distancia en millas
    /// - Returns: Distancia en kilómetros
    static func convertMilesToKm(_ miles: Double) -> Double {
        return miles / 0.621371
    }

    /// Formatea una duración en minutos
    /// - Parameter minutes: Duración en minutos
    /// - Returns: String formateado (ej: "1h 30min" o "45min")
    static func formatDuration(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) h"
            } else {
                return "\(hours) h \(remainingMinutes) min"
            }
        }
    }

    /// Calcula el ritmo basado en distancia y tiempo
    /// - Parameters:
    ///   - distanceKm: Distancia en kilómetros
    ///   - durationMinutes: Duración en minutos
    /// - Returns: Ritmo en min/km
    static func calculatePace(distanceKm: Double, durationMinutes: Int) -> Double {
        guard distanceKm > 0 else { return 0 }
        return Double(durationMinutes) / distanceKm
    }

    /// Calcula el tiempo estimado para una distancia y ritmo
    /// - Parameters:
    ///   - distanceKm: Distancia en kilómetros
    ///   - paceMinPerKm: Ritmo en min/km
    /// - Returns: Tiempo estimado en minutos
    static func calculateDuration(distanceKm: Double, paceMinPerKm: Double) -> Int {
        return Int(distanceKm * paceMinPerKm)
    }
}
