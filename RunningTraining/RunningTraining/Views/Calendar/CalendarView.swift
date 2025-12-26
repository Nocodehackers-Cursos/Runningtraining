//
//  CalendarView.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//  Redesigned with Runna-inspired UI
//

import SwiftUI
import SwiftData

/// Vista principal de calendario estilo Runna
struct CalendarView: View {
    @Query private var users: [User]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CalendarViewModel()
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
                        // Header con info del plan
                        RunnaStylePlanHeader(plan: plan)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        // Calendario semanal
                        WeekCalendarView(
                            viewModel: viewModel,
                            user: user,
                            onWorkoutTap: { workout in
                                selectedWorkout = workout
                            }
                        )
                        .padding(.horizontal)

                        // Info de la semana
                        if let week = viewModel.selectedWeek {
                            WeekFocusCard(week: week)
                                .padding(.horizontal)
                        }

                        // Lista de workouts
                        WorkoutListView(
                            workouts: viewModel.workoutsForSelectedWeek,
                            user: user,
                            onTap: { workout in
                                selectedWorkout = workout
                            }
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
            } else {
                LoadingView(message: "Cargando plan...")
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
                viewModel.loadActivePlan(for: user)
            }
        }
    }
}

/// Header del plan estilo Runna
struct RunnaStylePlanHeader: View {
    let plan: TrainingPlan

    var body: some View {
        VStack(spacing: 16) {
            // Título del plan
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Plan de Media Maratón")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Fecha de carrera: \(plan.raceDate.formattedShort())")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                // Countdown badge
                VStack {
                    Text("\(plan.daysUntilRace)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("días")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(AppTheme.secondary)
                )
            }

            // Progreso
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Semanas completadas")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text("\(plan.completedWorkouts)/\(plan.totalWorkouts)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.textPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Progreso")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text("\(Int(plan.completionPercentage * 100))%")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.primary)
                }
            }

            // Barra de progreso
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.secondaryBackground)
                        .frame(height: 8)

                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * plan.completionPercentage, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
    }
}

/// Vista de calendario semanal estilo Runna
struct WeekCalendarView: View {
    @Bindable var viewModel: CalendarViewModel
    let user: User
    let onWorkoutTap: (Workout) -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Navegación de semanas
            HStack {
                Button(action: { viewModel.previousWeek() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(viewModel.hasPreviousWeek ? AppTheme.primary : AppTheme.textSecondary)
                        .font(.title3)
                }
                .disabled(!viewModel.hasPreviousWeek)

                Spacer()

                if let week = viewModel.selectedWeek {
                    VStack(spacing: 2) {
                        Text("Semana \(week.weekNumber)")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)

                        Text("\(week.startDate.formattedShort())")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }

                Spacer()

                Button(action: { viewModel.nextWeek() }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(viewModel.hasNextWeek ? AppTheme.primary : AppTheme.textSecondary)
                        .font(.title3)
                }
                .disabled(!viewModel.hasNextWeek)
            }

            // Días de la semana
            HStack(spacing: 0) {
                ForEach(["L", "M", "X", "J", "V", "S", "D"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Indicadores de workouts
            if let week = viewModel.selectedWeek {
                HStack(spacing: 0) {
                    ForEach(1...7, id: \.self) { dayNum in
                        let workout = week.sortedWorkouts.first { $0.scheduledDate.dayOfWeek() == dayNum }

                        VStack(spacing: 4) {
                            if let workout = workout {
                                Button(action: { onWorkoutTap(workout) }) {
                                    Circle()
                                        .fill(AppTheme.colorForWorkoutType(workout.workoutType))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Group {
                                                if workout.isCompleted {
                                                    Image(systemName: "checkmark")
                                                        .font(.caption)
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        )
                                }
                            } else {
                                Circle()
                                    .fill(AppTheme.secondaryBackground)
                                    .frame(width: 32, height: 32)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
    }
}

/// Card de enfoque de la semana
struct WeekFocusCard: View {
    let week: TrainingWeek

    var body: some View {
        HStack {
            Image(systemName: "target")
                .font(.title2)
                .foregroundColor(AppTheme.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Enfoque de la semana")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Text(week.focus)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
            }

            Spacer()
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}

/// Lista de workouts estilo Runna
struct WorkoutListView: View {
    let workouts: [Workout]
    let user: User
    let onTap: (Workout) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(workouts) { workout in
                RunnaStyleWorkoutCard(
                    workout: workout,
                    maxHR: user.maxHeartRate,
                    useMetric: user.useMetricUnits
                )
                .onTapGesture {
                    onTap(workout)
                }
            }
        }
    }
}

/// Card de workout estilo Runna
struct RunnaStyleWorkoutCard: View {
    let workout: Workout
    let maxHR: Int
    let useMetric: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Barra de color lateral
            RoundedRectangle(cornerRadius: 4)
                .fill(AppTheme.colorForWorkoutType(workout.workoutType))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 8) {
                // Título y fecha
                HStack {
                    Text(workout.title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()

                    HStack(spacing: 8) {
                        // HealthKit badge
                        if workout.hasHealthKitData {
                            HealthKitBadge(synced: true)
                        }

                        // Completado badge
                        if workout.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.colorForWorkoutType(workout.workoutType))
                        }
                    }
                }

                // Tipo de workout
                Text(workout.workoutType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.colorForWorkoutType(workout.workoutType))

                // Detalles
                HStack(spacing: 16) {
                    if let distance = workout.distanceKm {
                        Label(PaceFormatter.formatDistance(distance, useMetric: useMetric), systemImage: "figure.run")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    if let pace = workout.targetPaceMinPerKm {
                        Label(PaceFormatter.format(paceMinPerKm: pace, useMetric: useMetric), systemImage: "speedometer")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }

                // Zona FC
                if let zone = workout.getHeartRateZone(maxHR: maxHR) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(zone.zone.color)
                            .frame(width: 8, height: 8)

                        Text("\(zone.zone.description) • \(zone.bpmRange)")
                            .font(.caption2)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}

/// Barra de navegación inferior
struct BottomNavigationBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            NavBarItem(icon: "house.fill", title: "Hoy", isActive: selectedTab == .today)
                .onTapGesture { selectedTab = .today }

            NavBarItem(icon: "calendar", title: "Plan", isActive: selectedTab == .calendar)
                .onTapGesture { selectedTab = .calendar }

            NavBarItem(icon: "chart.line.uptrend.xyaxis", title: "Actividades", isActive: selectedTab == .activities)
                .onTapGesture { selectedTab = .activities }

            NavBarItem(icon: "person.2.fill", title: "Comunidad", isActive: selectedTab == .community)
                .onTapGesture { selectedTab = .community }

            NavBarItem(icon: "info.circle", title: "Soporte", isActive: selectedTab == .support)
                .onTapGesture { selectedTab = .support }
        }
        .padding(.vertical, 8)
        .background(AppTheme.cardBackground.opacity(0.95))
    }
}

struct NavBarItem: View {
    let icon: String
    let title: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
            Text(title)
                .font(.caption2)
        }
        .foregroundColor(isActive ? AppTheme.primary : AppTheme.textSecondary)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CalendarView(selectedTab: .constant(.calendar))
        .modelContainer(for: [User.self, TrainingPlan.self])
}
