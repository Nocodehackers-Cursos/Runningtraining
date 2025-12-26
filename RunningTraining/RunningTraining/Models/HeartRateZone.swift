//
//  HeartRateZone.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation
import SwiftUI

/// Struct que representa una zona de frecuencia cardíaca
struct HeartRateZone: Codable, Hashable, Identifiable {
    let id: UUID
    let zone: Zone
    let minBPM: Int
    let maxBPM: Int
    let percentageMin: Int
    let percentageMax: Int

    init(zone: Zone, minBPM: Int, maxBPM: Int, percentageMin: Int, percentageMax: Int) {
        self.id = UUID()
        self.zone = zone
        self.minBPM = minBPM
        self.maxBPM = maxBPM
        self.percentageMin = percentageMin
        self.percentageMax = percentageMax
    }

    /// Representación en texto del rango de porcentaje
    var percentageRange: String {
        "\(percentageMin)-\(percentageMax)%"
    }

    /// Representación en texto del rango de BPM
    var bpmRange: String {
        "\(minBPM)-\(maxBPM) bpm"
    }

    /// Enum que define las 5 zonas de frecuencia cardíaca
    enum Zone: String, Codable, CaseIterable {
        case zone1 = "zone1"
        case zone2 = "zone2"
        case zone3 = "zone3"
        case zone4 = "zone4"
        case zone5 = "zone5"

        /// Nombre descriptivo de la zona
        var displayName: String {
            switch self {
            case .zone1: return "Zona 1"
            case .zone2: return "Zona 2"
            case .zone3: return "Zona 3"
            case .zone4: return "Zona 4"
            case .zone5: return "Zona 5"
            }
        }

        /// Descripción del propósito de la zona
        var description: String {
            switch self {
            case .zone1: return "Recuperación"
            case .zone2: return "Base Aeróbica"
            case .zone3: return "Tempo"
            case .zone4: return "Umbral"
            case .zone5: return "VO2 Max"
            }
        }

        /// Color asociado a cada zona para la UI
        var color: Color {
            switch self {
            case .zone1: return .gray
            case .zone2: return .blue
            case .zone3: return .green
            case .zone4: return .yellow
            case .zone5: return .red
            }
        }

        /// Porcentaje de FC máxima para esta zona
        var percentageRange: (min: Int, max: Int) {
            switch self {
            case .zone1: return (50, 60)
            case .zone2: return (60, 70)
            case .zone3: return (70, 80)
            case .zone4: return (80, 90)
            case .zone5: return (90, 100)
            }
        }
    }

    /// Calcula todas las zonas basándose en la FC máxima
    static func calculateZones(maxHR: Int) -> [HeartRateZone] {
        return Zone.allCases.map { zone in
            let range = zone.percentageRange
            let minBPM = Int(Double(maxHR) * Double(range.min) / 100.0)
            let maxBPM = Int(Double(maxHR) * Double(range.max) / 100.0)

            return HeartRateZone(
                zone: zone,
                minBPM: minBPM,
                maxBPM: maxBPM,
                percentageMin: range.min,
                percentageMax: range.max
            )
        }
    }
}
