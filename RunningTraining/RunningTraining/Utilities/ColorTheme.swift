//
//  ColorTheme.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import SwiftUI

/// Tema de colores de la app (estilo Runna)
struct AppTheme {
    // Colores de fondo
    static let background = Color(hex: "0A0A0A")
    static let cardBackground = Color(hex: "1C1C1E")
    static let secondaryBackground = Color(hex: "2C2C2E")

    // Colores de workout types (inspirado en Runna)
    static let easyRunColor = Color(hex: "4CAF50") // Verde
    static let tempoRunColor = Color(hex: "FF9800") // Naranja
    static let intervalsColor = Color(hex: "F44336") // Rojo
    static let longRunColor = Color(hex: "9C27B0") // Morado
    static let recoveryColor = Color(hex: "03A9F4") // Azul claro
    static let restColor = Color(hex: "757575") // Gris

    // Colores de acento
    static let primary = Color(hex: "00BCD4") // Cyan/Turquesa
    static let secondary = Color(hex: "FF6B6B")

    // Colores de texto
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "999999")

    /// Obtiene el color según el tipo de workout
    static func colorForWorkoutType(_ type: WorkoutType) -> Color {
        switch type {
        case .easyRun, .recoveryRun:
            return easyRunColor
        case .tempoRun:
            return tempoRunColor
        case .intervals, .hillRepeats, .fartlek:
            return intervalsColor
        case .longRun:
            return longRunColor
        case .crossTraining:
            return recoveryColor
        case .rest:
            return restColor
        }
    }
}

// Extension para crear colores desde hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
