//
//  OnboardingFlowView.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import SwiftUI

enum SlideDirection {
    case forward
    case backward
}

/// Contenedor del flujo de onboarding
struct OnboardingFlowView: View {
    @State private var viewModel = OnboardingViewModel()
    @State private var slideDirection: SlideDirection = .forward
    @Binding var onboardingCompleted: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.currentStep {
                case .welcome:
                    WelcomeView {
                        slideDirection = .forward
                        viewModel.navigateNext()
                    }
                    .transition(.opacity)
                    .id("welcome")

                case .sessions:
                    SessionsInputView(viewModel: viewModel)
                        .transition(slideTransition)
                        .id("sessions")
                        .onAppear {
                            updateNavigation()
                        }

                case .raceDate:
                    RaceDateInputView(viewModel: viewModel)
                        .transition(slideTransition)
                        .id("raceDate")
                        .onAppear {
                            updateNavigation()
                        }

                case .lastRace:
                    LastRaceInputView(viewModel: viewModel)
                        .transition(slideTransition)
                        .id("lastRace")
                        .onAppear {
                            updateNavigation()
                        }

                case .pace:
                    PaceInputView(viewModel: viewModel)
                        .transition(slideTransition)
                        .id("pace")
                        .onAppear {
                            updateNavigation()
                        }

                case .heartRate:
                    HeartRateInputView(viewModel: viewModel)
                        .transition(slideTransition)
                        .id("heartRate")
                        .onAppear {
                            updateNavigation()
                        }

                case .summary:
                    SummaryView(viewModel: viewModel)
                        .transition(slideTransition)
                        .id("summary")

                case .generating:
                    GeneratingPlanView(viewModel: viewModel)
                        .transition(.opacity)
                        .id("generating")
                }

                // Plan completado
                if viewModel.planGenerationCompleted {
                    Color.clear
                        .onAppear {
                            onboardingCompleted = true
                        }
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.currentStep)
        }
    }

    private var slideTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: slideDirection == .forward ? .trailing : .leading)
                .combined(with: .opacity),
            removal: .move(edge: slideDirection == .forward ? .leading : .trailing)
                .combined(with: .opacity)
        )
    }

    private func updateNavigation() {
        // Configurar las acciones de navegación en cada vista
        // Esto se conectará directamente con el ViewModel
    }
}

#Preview {
    OnboardingFlowView(onboardingCompleted: .constant(false))
        .modelContainer(for: [User.self, TrainingPlan.self])
}
