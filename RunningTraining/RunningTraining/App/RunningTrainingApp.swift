//
//  RunningTrainingApp.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import SwiftUI
import SwiftData

@main
struct RunningTrainingApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            // Configurar el contenedor de SwiftData con todos los modelos
            modelContainer = try ModelContainer(
                for: User.self,
                TrainingPlan.self,
                TrainingWeek.self,
                Workout.self
            )

            print("✅ SwiftData ModelContainer inicializado correctamente")
        } catch {
            fatalError("❌ Error al inicializar ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
