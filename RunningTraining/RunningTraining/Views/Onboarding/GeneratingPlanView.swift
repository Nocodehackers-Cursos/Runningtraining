//
//  GeneratingPlanView.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import SwiftUI

/// Vista mostrada mientras se genera el plan con OpenAI
struct GeneratingPlanView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Icono animado
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppTheme.primary)
                    .symbolEffect(.pulse)
                    .symbolEffect(.rotate.byLayer)

                // Progress bar lineal
                VStack(spacing: 12) {
                    ProgressView(value: viewModel.generationProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: AppTheme.primary))
                        .frame(width: 250)
                        .animation(.easeInOut, value: viewModel.generationProgress)

                    Text("\(Int(viewModel.generationProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }

                // Mensaje dinámico
                Text(viewModel.generationMessage)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.easeInOut, value: viewModel.generationMessage)
                    .frame(height: 60)

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    GeneratingPlanView(viewModel: OnboardingViewModel())
}
