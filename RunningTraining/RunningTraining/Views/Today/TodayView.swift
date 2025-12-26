//
//  TodayView.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Query private var users: [User]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TodayViewModel()
    @State private var selectedWorkout: Workout?
    @Binding var selectedTab: AppTab

    private var currentUser: User? {
        users.first
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if let user = currentUser, let plan = viewModel.trainingPlan {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        TodayHeaderView(
                            greeting: viewModel.greetingMessage,
                            currentDate: Date(),
                            daysUntilRace: viewModel.daysUntilRace
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Workout de hoy O mensaje de descanso
                        if let todayWorkout = viewModel.todayWorkout {
                            TodayWorkoutCard(
                                workout: todayWorkout,
                                maxHR: user.maxHeartRate,
                                useMetric: user.useMetricUnits,
                                onComplete: {
                                    viewModel.completeWorkout(todayWorkout, modelContext: modelContext)
                                }
                            )
                            .padding(.horizontal)
                            .onTapGesture {
                                selectedWorkout = todayWorkout
                            }
                        } else {
                            // No hay workout hoy - mostrar descanso
                            RestDayCard()
                                .padding(.horizontal)
                        }

                        // Stats de la semana
                        if let week = viewModel.currentWeek {
                            WeekStatsCard(
                                weekNumber: week.weekNumber,
                                progress: viewModel.weekProgress,
                                distance: viewModel.weekDistance,
                                completionPercentage: viewModel.weekCompletionPercentage,
                                focus: week.focus
                            )
                            .padding(.horizontal)
                        }

                        // Próximos entrenamientos
                        if !viewModel.upcomingWorkouts.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("PRÓXIMOS ENTRENAMIENTOS")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding(.horizontal)

                                ForEach(viewModel.upcomingWorkouts) { workout in
                                    RunnaStyleWorkoutCard(
                                        workout: workout,
                                        maxHR: user.maxHeartRate,
                                        useMetric: user.useMetricUnits
                                    )
                                    .onTapGesture {
                                        selectedWorkout = workout
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top)
                }
            } else {
                LoadingView(message: "Cargando datos...")
            }

            // Bottom Navigation Bar
            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $selectedWorkout) { workout in
            if let user = currentUser {
                WorkoutDetailView(
                    workout: workout,
                    maxHR: user.maxHeartRate,
                    useMetric: user.useMetricUnits
                )
            }
        }
        .onAppear {
            if let user = currentUser {
                viewModel.loadData(for: user)
            }
        }
    }
}

#Preview {
    TodayView(selectedTab: .constant(.today))
        .modelContainer(for: [User.self, TrainingPlan.self])
}
