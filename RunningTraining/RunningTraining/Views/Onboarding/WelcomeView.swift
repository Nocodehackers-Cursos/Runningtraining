//
//  WelcomeView.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import SwiftUI

/// Pantalla de bienvenida del onboarding
struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Icono principal
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(AppTheme.primary)
                    .padding(.bottom, 20)

                // Título
                Text("RunningTraining")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)

                // Subtítulo
                Text("Tu entrenador personal de media maratón")
                    .font(.title3)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                // Descripción de características
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(
                        icon: "brain.head.profile",
                        title: "Planes con IA",
                        description: "Generados con GPT-4o según tus objetivos"
                    )

                    FeatureRow(
                        icon: "heart.fill",
                        title: "Zonas de FC",
                        description: "Entrena en las zonas correctas"
                    )

                    FeatureRow(
                        icon: "calendar",
                        title: "Periodización",
                        description: "Plan progresivo hasta tu carrera"
                    )
                }
                .padding(.horizontal)

                Spacer()

                // Botón comenzar
                PrimaryButton(
                    title: "Comenzar",
                    action: onContinue
                )
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
    }
}

/// Fila de característica
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.primary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
}

#Preview {
    WelcomeView(onContinue: {})
}
