//
//  PerformanceStatus.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import Foundation
import SwiftUI

/// Enum que representa el estado de rendimiento de un entrenamiento
/// comparando los datos planificados vs los datos reales
enum PerformanceStatus {
    /// Rendimiento superior al plan (más rápido)
    case abovePlan

    /// Rendimiento en objetivo (dentro del 5% del plan)
    case onTarget

    /// Rendimiento inferior al plan (más lento)
    case belowPlan

    /// Datos insuficientes para comparar
    case unknown

    // MARK: - Computed Properties

    /// Título descriptivo del estado
    var title: String {
        switch self {
        case .abovePlan:
            return "Por encima del objetivo"
        case .onTarget:
            return "En objetivo"
        case .belowPlan:
            return "Por debajo del objetivo"
        case .unknown:
            return "Sin datos"
        }
    }

    /// Descripción detallada del estado
    var description: String {
        switch self {
        case .abovePlan:
            return "Corriste más rápido de lo planificado"
        case .onTarget:
            return "Mantuviste el ritmo planificado"
        case .belowPlan:
            return "Corriste más lento de lo planificado"
        case .unknown:
            return "No hay datos para comparar"
        }
    }

    /// Color asociado al estado
    var color: Color {
        switch self {
        case .abovePlan:
            return .green
        case .onTarget:
            return .cyan
        case .belowPlan:
            return .orange
        case .unknown:
            return .gray
        }
    }

    /// Icono SF Symbol asociado al estado
    var icon: String {
        switch self {
        case .abovePlan:
            return "arrow.up.circle.fill"
        case .onTarget:
            return "checkmark.circle.fill"
        case .belowPlan:
            return "arrow.down.circle.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }

    // MARK: - Static Methods

    /// Calcula el estado de rendimiento basado en la varianza de ritmo
    /// - Parameter paceVariance: Varianza de ritmo en porcentaje
    ///   - Positivo: Más rápido que lo planificado
    ///   - Negativo: Más lento que lo planificado
    /// - Returns: Estado de rendimiento correspondiente
    static func from(paceVariance: Double?) -> PerformanceStatus {
        guard let variance = paceVariance else {
            return .unknown
        }

        if variance > 5 {
            return .abovePlan // Más de 5% más rápido
        } else if variance < -5 {
            return .belowPlan // Más de 5% más lento
        } else {
            return .onTarget // Dentro del ±5%
        }
    }
}

// MARK: - Identifiable

extension PerformanceStatus: Identifiable {
    var id: String {
        switch self {
        case .abovePlan: return "above"
        case .onTarget: return "target"
        case .belowPlan: return "below"
        case .unknown: return "unknown"
        }
    }
}
