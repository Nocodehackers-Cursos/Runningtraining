//
//  TrainingPlanParser.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation

/// Parser para convertir JSON de OpenAI en modelos SwiftData
struct TrainingPlanParser {
    // Errores de parsing
    enum ParsingError: LocalizedError {
        case invalidJSON
        case missingRequiredField(String)
        case invalidWorkoutType(String)

        var errorDescription: String? {
            switch self {
            case .invalidJSON:
                return "El JSON recibido no es válido"
            case .missingRequiredField(let field):
                return "Campo requerido faltante: \(field)"
            case .invalidWorkoutType(let type):
                return "Tipo de entrenamiento inválido: \(type)"
            }
        }
    }

    /// Parsea el JSON y crea un TrainingPlan con todas sus relaciones
    /// - Parameters:
    ///   - jsonString: JSON devuelto por OpenAI
    ///   - user: Usuario para el cual se genera el plan
    /// - Returns: TrainingPlan completo con semanas y entrenamientos
    static func parse(jsonString: String, for user: User) throws -> TrainingPlan {
        // DEBUG: Imprimir el JSON recibido
        print("📥 JSON RECIBIDO DE OPENAI:")
        print("Longitud: \(jsonString.count) caracteres")
        print("Primeros 500 caracteres: \(String(jsonString.prefix(500)))")
        print("Últimos 500 caracteres: \(String(jsonString.suffix(500)))")

        // Convertir string a Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌ No se pudo convertir string a Data")
            throw ParsingError.invalidJSON
        }

        // Decodificar JSON
        let decoder = JSONDecoder()
        let planDTO: TrainingPlanDTO
        do {
            planDTO = try decoder.decode(TrainingPlanDTO.self, from: jsonData)
        } catch {
            print("❌ Error decodificando JSON: \(error)")
            print("📄 JSON completo que falló:")
            print(jsonString)
            throw ParsingError.invalidJSON
        }

        // Crear TrainingPlan
        let plan = TrainingPlan(
            startDate: Date().startOfWeek(),
            raceDate: user.raceDate,
            generatedByAI: true
        )

        // Guardar análisis de la IA (si existe)
        if let analysis = planDTO.analysis {
            plan.runnerLevel = analysis.runnerLevel
            plan.weeklyVolumeKm = analysis.weeklyVolumeKm
            plan.planReasoning = analysis.reasoning
            print("📊 Análisis del plan:")
            print("   - Nivel: \(analysis.runnerLevel)")
            print("   - Volumen semanal: \(analysis.weeklyVolumeKm)km")
            print("   - Razonamiento: \(analysis.reasoning)")
        }

        // Parsear cada semana
        for weekDTO in planDTO.weeks {
            let weekStartDate = plan.startDate.addingWeeks(weekDTO.weekNumber - 1)

            let trainingWeek = TrainingWeek(
                weekNumber: weekDTO.weekNumber,
                startDate: weekStartDate,
                focus: weekDTO.focus
            )

            // Parsear cada workout de la semana
            for workoutDTO in weekDTO.workouts {
                let workout = try parseWorkout(
                    dto: workoutDTO,
                    weekStartDate: weekStartDate,
                    maxHR: user.maxHeartRate
                )
                workout.trainingWeek = trainingWeek
                trainingWeek.workouts.append(workout)
            }

            trainingWeek.trainingPlan = plan
            plan.weeks.append(trainingWeek)
        }

        return plan
    }

    /// Parsea un workout individual del DTO
    private static func parseWorkout(
        dto: WorkoutDTO,
        weekStartDate: Date,
        maxHR: Int
    ) throws -> Workout {
        // Convertir string a WorkoutType
        guard let workoutType = WorkoutType(rawValue: dto.type) else {
            throw ParsingError.invalidWorkoutType(dto.type)
        }

        // Calcular fecha del workout (dayOfWeek: 1=Lunes)
        let daysOffset = dto.dayOfWeek - 1
        let workoutDate = weekStartDate.addingDays(daysOffset)

        // Crear workout
        let workout = Workout(
            scheduledDate: workoutDate,
            workoutType: workoutType,
            title: dto.title,
            description: dto.description
        )

        // Asignar parámetros opcionales
        workout.distanceKm = dto.distanceKm
        workout.targetPaceMinPerKm = dto.targetPaceMinPerKm
        workout.goals = dto.goals ?? []

        // Asignar zona de frecuencia cardíaca si existe
        if let zoneString = dto.heartRateZone {
            workout.primaryHeartRateZone = zoneString

            // Extraer porcentajes de la zona
            let zonePercentages = getZonePercentages(from: zoneString)
            workout.heartRateZonePercentageMin = zonePercentages.min
            workout.heartRateZonePercentageMax = zonePercentages.max
        }

        return workout
    }

    /// Obtiene los porcentajes de FC para una zona
    private static func getZonePercentages(from zoneString: String) -> (min: Int, max: Int) {
        switch zoneString {
        case "zone1": return (50, 60)
        case "zone2": return (60, 70)
        case "zone3": return (70, 80)
        case "zone4": return (80, 90)
        case "zone5": return (90, 100)
        default: return (60, 70) // Default a Zone 2
        }
    }
}

// MARK: - DTOs para parsing

/// DTO del análisis del plan (generado por IA)
struct AnalysisDTO: Codable {
    let runnerLevel: String
    let weeklyVolumeKm: Double
    let reasoning: String
}

/// DTO del plan de entrenamiento completo
struct TrainingPlanDTO: Codable {
    let analysis: AnalysisDTO?
    let weeks: [WeekDTO]
}

/// DTO de una semana
struct WeekDTO: Codable {
    let weekNumber: Int
    let focus: String
    let totalVolumeKm: Double?
    let workouts: [WorkoutDTO]
}

/// DTO de un workout
struct WorkoutDTO: Codable {
    let dayOfWeek: Int // 1-7 (1=Lunes)
    let type: String // "easy_run", "tempo_run", etc.
    let title: String
    let description: String
    let distanceKm: Double?
    let targetPaceMinPerKm: Double?
    let heartRateZone: String? // "zone1", "zone2", etc.
    let goals: [String]?
}
