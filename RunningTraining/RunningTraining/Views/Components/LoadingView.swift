//
//  LoadingView.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import SwiftUI

/// Vista de carga reutilizable
struct LoadingView: View {
    let message: String
    var showIcon: Bool = true

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                if showIcon {
                    Image(systemName: "figure.run.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.primary)
                        .symbolEffect(.pulse)
                }

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                    .scaleEffect(1.5)

                Text(message)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    LoadingView(message: "Generando tu plan personalizado...")
}
