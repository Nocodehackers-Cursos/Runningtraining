//
//  WorkoutType.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation

/// Enum que define los diferentes tipos de entrenamientos
enum WorkoutType: String, Codable, CaseIterable {
    case longRun = "long_run"
    case tempoRun = "tempo_run"
    case intervals = "intervals"
    case easyRun = "easy_run"
    case recoveryRun = "recovery_run"
    case hillRepeats = "hill_repeats"
    case fartlek = "fartlek"
    case crossTraining = "cross_training"
    case rest = "rest"

    /// Nombre para mostrar en la UI
    var displayName: String {
        switch self {
        case .longRun:
            return "Carrera Larga"
        case .tempoRun:
            return "Tempo Run"
        case .intervals:
            return "Intervalos"
        case .easyRun:
            return "Carrera Fácil"
        case .recoveryRun:
            return "Recuperación"
        case .hillRepeats:
            return "Cuestas"
        case .fartlek:
            return "Fartlek"
        case .crossTraining:
            return "Entrenamiento Cruzado"
        case .rest:
            return "Descanso"
        }
    }

    /// Nombre del SF Symbol para el icono
    var systemImageName: String {
        switch self {
        case .longRun:
            return "figure.run"
        case .tempoRun:
            return "hare.fill"
        case .intervals:
            return "speedometer"
        case .easyRun, .recoveryRun:
            return "tortoise.fill"
        case .hillRepeats:
            return "mountain.2.fill"
        case .fartlek:
            return "wind"
        case .crossTraining:
            return "figure.indoor.cycle"
        case .rest:
            return "bed.double.fill"
        }
    }

    /// Descripción breve del tipo de entrenamiento
    var description: String {
        switch self {
        case .longRun:
            return "Carrera de resistencia a ritmo cómodo"
        case .tempoRun:
            return "Carrera a ritmo sostenido, cerca del umbral"
        case .intervals:
            return "Series de alta intensidad con recuperación"
        case .easyRun:
            return "Carrera suave para construir base aeróbica"
        case .recoveryRun:
            return "Carrera muy suave para recuperación activa"
        case .hillRepeats:
            return "Repeticiones en subida para fuerza"
        case .fartlek:
            return "Juego de ritmos variados"
        case .crossTraining:
            return "Actividad complementaria (ciclismo, natación, etc.)"
        case .rest:
            return "Día de descanso completo"
        }
    }
}
