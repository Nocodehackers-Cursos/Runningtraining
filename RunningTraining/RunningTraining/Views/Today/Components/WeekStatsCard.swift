//
//  WeekStatsCard.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

struct WeekStatsCard: View {
    let weekNumber: Int
    let progress: String
    let distance: String
    let completionPercentage: Double
    let focus: String

    var body: some View {
        VStack(spacing: 16) {
            // Header con número de semana y porcentaje
            HStack {
                Text("Semana \(weekNumber)")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text("\(Int(completionPercentage * 100))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primary)
            }

            // Stats de entrenamientos y distancia
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Entrenamientos")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(progress)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Distancia")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(distance)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                }
            }

            // Barra de progreso
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.secondaryBackground)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * completionPercentage, height: 8)
                }
            }
            .frame(height: 8)

            // Enfoque de la semana
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .foregroundColor(AppTheme.primary)
                Text(focus)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}
