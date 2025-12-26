//
//  OnboardingProgressBar.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

/// Indicador visual de progreso del onboarding
struct OnboardingProgressBar: View {
    let currentStep: Int    // 1-5
    let totalSteps: Int     // 5

    var body: some View {
        VStack(spacing: 12) {
            // Barra de segmentos
            HStack(spacing: 8) {
                ForEach(1...totalSteps, id: \.self) { step in
                    Rectangle()
                        .fill(step <= currentStep ? AppTheme.primary : AppTheme.textSecondary.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }

            // Texto del paso
            Text("Paso \(currentStep) de \(totalSteps)")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 40) {
        OnboardingProgressBar(currentStep: 1, totalSteps: 5)
        OnboardingProgressBar(currentStep: 3, totalSteps: 5)
        OnboardingProgressBar(currentStep: 5, totalSteps: 5)
    }
    .padding()
    .background(AppTheme.background)
}
