//
//  InputValidationBadge.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

/// Estados de validación para inputs
enum ValidationState {
    case idle        // Sin feedback
    case valid       // Checkmark verde
    case invalid     // X roja + mensaje
    case warning     // ! amarilla + mensaje
}

/// Feedback visual de validación con estado
struct InputValidationBadge: View {
    let state: ValidationState
    let message: String?

    @State private var checkmarkScale: CGFloat = 1.0

    var body: some View {
        Group {
            switch state {
            case .idle:
                EmptyView()

            case .valid:
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .scaleEffect(checkmarkScale)
                    if let message = message {
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
                .onAppear {
                    triggerValidAnimation()
                }

            case .invalid:
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    if let message = message {
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
                .onAppear {
                    triggerInvalidHaptic()
                }

            case .warning:
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    if let message = message {
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                    }
                }
                .onAppear {
                    triggerWarningHaptic()
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func triggerValidAnimation() {
        // Feedback háptico
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Bounce animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            checkmarkScale = 1.2
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.1)) {
            checkmarkScale = 1.0
        }
    }

    private func triggerInvalidHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    private func triggerWarningHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

#Preview {
    VStack(spacing: 30) {
        InputValidationBadge(state: .valid, message: "Perfecto")
        InputValidationBadge(state: .invalid, message: "Valor inválido")
        InputValidationBadge(state: .warning, message: "Advertencia")
        InputValidationBadge(state: .idle, message: nil)
    }
    .padding()
    .background(AppTheme.background)
}
