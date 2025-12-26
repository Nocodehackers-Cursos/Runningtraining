//
//  RestDayCard.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

struct RestDayCard: View {
    var body: some View {
        VStack(spacing: 16) {
            // Icono
            Image(systemName: "bed.double.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.primary)

            // Título
            Text("Día de Descanso")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)

            // Mensaje motivacional
            Text("La recuperación es parte del entrenamiento. ¡Disfruta tu descanso!")
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
    }
}
