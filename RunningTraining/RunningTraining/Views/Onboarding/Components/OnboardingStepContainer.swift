//
//  OnboardingStepContainer.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

/// Wrapper reutilizable para todas las vistas de input del onboarding
struct OnboardingStepContainer<Content: View>: View {
    let stepNumber: Int
    let totalSteps: Int
    let title: String
    let subtitle: String?
    let icon: String?
    let content: Content
    let onContinue: () -> Void
    let onBack: (() -> Void)?
    let continueButtonTitle: String
    let isValid: Bool

    @State private var isVisible = false

    init(
        stepNumber: Int,
        totalSteps: Int,
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        @ViewBuilder content: () -> Content,
        onContinue: @escaping () -> Void,
        onBack: (() -> Void)? = nil,
        continueButtonTitle: String = "Continuar",
        isValid: Bool
    ) {
        self.stepNumber = stepNumber
        self.totalSteps = totalSteps
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.content = content()
        self.onContinue = onContinue
        self.onBack = onBack
        self.continueButtonTitle = continueButtonTitle
        self.isValid = isValid
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Progress Bar
                    OnboardingProgressBar(currentStep: stepNumber, totalSteps: totalSteps)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.0), value: isVisible)

                    Spacer()
                        .frame(height: 20)

                    // Icon (opcional)
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.primary)
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.08), value: isVisible)
                    }

                    // Title
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.16), value: isVisible)

                    // Subtitle (opcional)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.24), value: isVisible)
                    }

                    Spacer()
                        .frame(height: 20)

                    // Content (input específico)
                    content
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.32), value: isVisible)

                    Spacer()

                    // Validation Badge
                    if isValid {
                        InputValidationBadge(state: .valid, message: nil)
                            .opacity(isVisible ? 1 : 0)
                            .animation(.easeOut(duration: 0.4).delay(0.40), value: isVisible)
                    }

                    // Botón Continuar
                    PrimaryButton(
                        title: continueButtonTitle,
                        action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            onContinue()
                        },
                        isDisabled: !isValid
                    )
                    .opacity(isVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.48), value: isVisible)

                    // Botón Atrás (opcional)
                    if let onBack = onBack {
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            onBack()
                        }) {
                            Text("Atrás")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .opacity(isVisible ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.56), value: isVisible)
                    }

                    Spacer()
                        .frame(height: 40)
                }
                .padding()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            isVisible = true
        }
    }
}

#Preview {
    OnboardingStepContainer(
        stepNumber: 2,
        totalSteps: 5,
        title: "¿Cuántas veces entrenas?",
        subtitle: "Selecciona el número de sesiones por semana",
        icon: "figure.run",
        content: {
            Text("Contenido aquí")
                .font(.headline)
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(12)
        },
        onContinue: {},
        onBack: {},
        continueButtonTitle: "Continuar",
        isValid: true
    )
}
