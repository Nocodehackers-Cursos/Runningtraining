//
//  ContentView.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import SwiftUI
import SwiftData

enum AppTab: Int {
    case today = 0
    case calendar = 1
    case activities = 2
    case community = 3
    case support = 4
}

/// Vista principal que enruta entre onboarding y calendario
struct ContentView: View {
    @Query private var users: [User]
    @State private var onboardingCompleted = false
    @State private var selectedTab: AppTab = .today

    private var shouldShowOnboarding: Bool {
        return users.isEmpty || users.first?.activeTrainingPlan == nil
    }

    var body: some View {
        Group {
            if shouldShowOnboarding && !onboardingCompleted {
                OnboardingFlowView(onboardingCompleted: $onboardingCompleted)
            } else {
                TabView(selection: $selectedTab) {
                    TodayView(selectedTab: $selectedTab)
                        .tag(AppTab.today)

                    CalendarView(selectedTab: $selectedTab)
                        .tag(AppTab.calendar)

                    // Placeholders para futuras vistas
                    Text("Actividades - Próximamente")
                        .tag(AppTab.activities)
                    Text("Comunidad - Próximamente")
                        .tag(AppTab.community)

                    SettingsView(selectedTab: $selectedTab)
                        .tag(AppTab.support)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, TrainingPlan.self, TrainingWeek.self, Workout.self])
}
