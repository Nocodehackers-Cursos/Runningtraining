//
//  InfoTooltip.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

/// Tooltip educativo contextual
struct InfoTooltip: View {
    let message: String
    let icon: String

    init(message: String, icon: String = "info.circle.fill") {
        self.message = message
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppTheme.primary)
                .symbolEffect(.pulse)

            Text(message)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.primary.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.primary.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        InfoTooltip(message: "Recomendamos 4-5 sesiones para mejores resultados")
        InfoTooltip(message: "Si no la conoces, usa la fórmula: 220 - tu edad", icon: "heart.fill")
        InfoTooltip(message: "Necesitas al menos 8 semanas para prepararte adecuadamente")
    }
    .padding()
    .background(AppTheme.background)
}
