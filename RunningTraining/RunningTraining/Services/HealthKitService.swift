//
//  HealthKitService.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import Foundation
import HealthKit

/// Servicio para interactuar con Apple HealthKit
/// Maneja autorización, queries de workouts y extracción de métricas
class HealthKitService {

    // MARK: - Singleton

    static let shared = HealthKitService()

    // MARK: - Properties

    private let healthStore = HKHealthStore()
    private var observerQuery: HKObserverQuery?

    // MARK: - Initialization

    private init() {
        // Singleton - inicialización privada
    }

    // MARK: - Authorization

    /// Verifica si HealthKit está disponible en este dispositivo
    var isHealthDataAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    /// Solicita autorización para leer datos de HealthKit
    /// - Returns: true si la autorización fue concedida, false en caso contrario
    func requestAuthorization() async throws -> Bool {
        guard isHealthDataAvailable else {
            throw HealthKitError.notAvailable
        }

        // Tipos de datos que necesitamos leer
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]

        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    /// Verifica si ya tenemos autorización para leer workouts
    func isAuthorized() -> Bool {
        guard isHealthDataAvailable else { return false }

        let workoutType = HKObjectType.workoutType()
        let status = healthStore.authorizationStatus(for: workoutType)

        // NOTA: Para permisos de SOLO LECTURA, HealthKit puede retornar .notDetermined
        // incluso después de que el usuario acepte (por privacidad de Apple)
        // Por lo tanto, aceptamos tanto .sharingAuthorized como .notDetermined
        return status == .sharingAuthorized || status == .notDetermined
    }

    /// Verifica si podemos acceder a HealthKit intentando un query real
    func canAccessHealthData() async -> Bool {
        guard isHealthDataAvailable else { return false }

        do {
            // Intentar un query simple de los últimos 7 días
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
            _ = try await fetchWorkouts(from: startDate, to: endDate)
            return true
        } catch {
            print("⚠️ No se puede acceder a HealthKit: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Query Workouts

    /// Obtiene workouts de HealthKit en un rango de fechas
    /// - Parameters:
    ///   - startDate: Fecha de inicio del rango
    ///   - endDate: Fecha de fin del rango
    /// - Returns: Array de workouts de HealthKit
    func fetchWorkouts(from startDate: Date, to endDate: Date) async throws -> [HKWorkout] {
        guard isAuthorized() else {
            throw HealthKitError.notAuthorized
        }

        // Predicado para workouts de tipo running en el rango de fechas
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
        let datePredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        let compoundPredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [workoutPredicate, datePredicate]
        )

        // Ordenar por fecha de inicio (más reciente primero)
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: compoundPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                let workouts = samples as? [HKWorkout] ?? []
                continuation.resume(returning: workouts)
            }

            healthStore.execute(query)
        }
    }

    /// Obtiene workouts de un día específico
    /// - Parameter date: Fecha del día a buscar
    /// - Returns: Array de workouts de ese día
    func fetchWorkoutsForDay(_ date: Date) async throws -> [HKWorkout] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return try await fetchWorkouts(from: startOfDay, to: endOfDay)
    }

    /// Obtiene workouts de los últimos 30 días
    /// - Returns: Array de workouts de los últimos 30 días
    func fetchWorkoutsForLast30Days() async throws -> [HKWorkout] {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!

        return try await fetchWorkouts(from: startDate, to: endDate)
    }

    // MARK: - Extract Metrics

    /// Extrae métricas de un workout de HealthKit
    /// - Parameter workout: Workout de HealthKit
    /// - Returns: Estructura WorkoutMetrics con todas las métricas
    func extractMetrics(from workout: HKWorkout) async throws -> WorkoutMetrics {
        // Distancia
        let distance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0

        // Duración
        let duration = workout.duration

        // Calcular ritmo promedio (min/km)
        let averagePace: Double
        if distance > 0 {
            let paceSecondsPerMeter = duration / distance
            let paceSecondsPerKm = paceSecondsPerMeter * 1000.0
            averagePace = paceSecondsPerKm / 60.0 // Convertir a min/km
        } else {
            averagePace = 0
        }

        // Intentar obtener datos de frecuencia cardíaca
        var avgHR: Int?
        var maxHR: Int?
        var minHR: Int?

        do {
            let hrSamples = try await fetchHeartRateSamples(for: workout)
            if !hrSamples.isEmpty {
                avgHR = calculateAverageHeartRate(from: hrSamples)
                maxHR = calculateMaxHeartRate(from: hrSamples)
                minHR = calculateMinHeartRate(from: hrSamples)
            }
        } catch {
            print("⚠️ No se pudieron obtener datos de FC: \(error.localizedDescription)")
            // No es un error crítico, continuamos sin datos de FC
        }

        return WorkoutMetrics(
            healthKitUUID: workout.uuid,
            startDate: workout.startDate,
            endDate: workout.endDate,
            distance: distance,
            duration: duration,
            averagePace: averagePace,
            averageHeartRate: avgHR,
            maxHeartRate: maxHR,
            minHeartRate: minHR
        )
    }

    // MARK: - Heart Rate Data

    /// Obtiene samples de frecuencia cardíaca para un workout
    /// - Parameter workout: Workout de HealthKit
    /// - Returns: Array de samples de FC
    func fetchHeartRateSamples(for workout: HKWorkout) async throws -> [HKQuantitySample] {
        guard isAuthorized() else {
            throw HealthKitError.notAuthorized
        }

        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                let hrSamples = samples as? [HKQuantitySample] ?? []
                continuation.resume(returning: hrSamples)
            }

            healthStore.execute(query)
        }
    }

    /// Calcula la frecuencia cardíaca promedio de un conjunto de samples
    /// - Parameter samples: Array de samples de FC
    /// - Returns: FC promedio en BPM, o nil si no hay datos
    func calculateAverageHeartRate(from samples: [HKQuantitySample]) -> Int? {
        guard !samples.isEmpty else { return nil }

        let bpmUnit = HKUnit.count().unitDivided(by: .minute())
        let sum = samples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: bpmUnit) }
        let average = sum / Double(samples.count)

        return Int(round(average))
    }

    /// Calcula la frecuencia cardíaca máxima de un conjunto de samples
    /// - Parameter samples: Array de samples de FC
    /// - Returns: FC máxima en BPM, o nil si no hay datos
    func calculateMaxHeartRate(from samples: [HKQuantitySample]) -> Int? {
        guard !samples.isEmpty else { return nil }

        let bpmUnit = HKUnit.count().unitDivided(by: .minute())
        let maxValue = samples.map { $0.quantity.doubleValue(for: bpmUnit) }.max() ?? 0

        return Int(round(maxValue))
    }

    /// Calcula la frecuencia cardíaca mínima de un conjunto de samples
    /// - Parameter samples: Array de samples de FC
    /// - Returns: FC mínima en BPM, o nil si no hay datos
    func calculateMinHeartRate(from samples: [HKQuantitySample]) -> Int? {
        guard !samples.isEmpty else { return nil }

        let bpmUnit = HKUnit.count().unitDivided(by: .minute())
        let minValue = samples.map { $0.quantity.doubleValue(for: bpmUnit) }.min() ?? 0

        return Int(round(minValue))
    }

    /// Calcula la distribución de tiempo en cada zona de FC
    /// - Parameters:
    ///   - samples: Array de samples de FC
    ///   - maxHR: Frecuencia cardíaca máxima del usuario
    /// - Returns: Diccionario con tiempo en segundos para cada zona
    func calculateHeartRateZoneDistribution(
        from samples: [HKQuantitySample],
        maxHR: Int
    ) -> [HeartRateZone.Zone: TimeInterval] {
        guard !samples.isEmpty else { return [:] }

        var distribution: [HeartRateZone.Zone: TimeInterval] = [
            .zone1: 0,
            .zone2: 0,
            .zone3: 0,
            .zone4: 0,
            .zone5: 0
        ]

        let bpmUnit = HKUnit.count().unitDivided(by: .minute())
        let zones = HeartRateZone.allZones(maxHR: maxHR)

        // Calcular tiempo entre samples (asumiendo ~1 segundo entre samples)
        let sampleDuration: TimeInterval = 1.0

        for sample in samples {
            let bpm = Int(sample.quantity.doubleValue(for: bpmUnit))

            // Encontrar en qué zona está este BPM
            if let zone = zones.first(where: { $0.minBPM <= bpm && bpm <= $0.maxBPM }) {
                distribution[zone.zone, default: 0] += sampleDuration
            }
        }

        return distribution
    }

    // MARK: - Observer Query (Real-time Updates)

    /// Observa cambios en workouts de HealthKit
    /// - Parameter handler: Closure que se ejecuta cuando hay nuevos workouts
    func observeWorkoutChanges(handler: @escaping ([HKWorkout]) -> Void) {
        let workoutType = HKObjectType.workoutType()

        observerQuery = HKObserverQuery(
            sampleType: workoutType,
            predicate: nil
        ) { [weak self] query, completionHandler, error in
            if let error = error {
                print("❌ Observer query error: \(error.localizedDescription)")
                completionHandler()
                return
            }

            // Cuando detectamos cambios, obtenemos los workouts recientes
            Task {
                do {
                    let workouts = try await self?.fetchWorkoutsForLast30Days() ?? []
                    handler(workouts)
                } catch {
                    print("❌ Error fetching workouts in observer: \(error.localizedDescription)")
                }
                completionHandler()
            }
        }

        healthStore.execute(observerQuery!)

        // Habilitar background delivery para recibir notificaciones
        Task {
            try? await enableBackgroundDelivery()
        }
    }

    /// Detiene la observación de cambios
    func stopObserving() {
        if let query = observerQuery {
            healthStore.stop(query)
            observerQuery = nil
        }

        Task {
            try? await disableBackgroundDelivery()
        }
    }

    // MARK: - Background Delivery

    /// Habilita la entrega en background de datos de HealthKit
    func enableBackgroundDelivery() async throws {
        let workoutType = HKObjectType.workoutType()

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.enableBackgroundDelivery(
                for: workoutType,
                frequency: .immediate
            ) { success, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HealthKitError.queryFailed(
                        NSError(domain: "HealthKit", code: -1, userInfo: [
                            NSLocalizedDescriptionKey: "Failed to enable background delivery"
                        ])
                    ))
                }
            }
        }
    }

    /// Deshabilita la entrega en background de datos de HealthKit
    func disableBackgroundDelivery() async throws {
        let workoutType = HKObjectType.workoutType()

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.disableBackgroundDelivery(for: workoutType) { success, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HealthKitError.queryFailed(
                        NSError(domain: "HealthKit", code: -1, userInfo: [
                            NSLocalizedDescriptionKey: "Failed to disable background delivery"
                        ])
                    ))
                }
            }
        }
    }
}

// MARK: - Error Handling

/// Errores específicos de HealthKit
enum HealthKitError: LocalizedError {
    case notAvailable
    case notAuthorized
    case queryFailed(Error)
    case noData
    case invalidWorkout

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit no está disponible en este dispositivo"
        case .notAuthorized:
            return "No tienes autorización para acceder a HealthKit. Por favor, habilítalo en Ajustes."
        case .queryFailed(let error):
            return "Error al consultar HealthKit: \(error.localizedDescription)"
        case .noData:
            return "No se encontraron datos en HealthKit"
        case .invalidWorkout:
            return "El workout de HealthKit no es válido"
        }
    }
}

// MARK: - HeartRateZone Extension

extension HeartRateZone {
    /// Obtiene todas las zonas de FC basadas en la FC máxima
    /// - Parameter maxHR: Frecuencia cardíaca máxima del usuario
    /// - Returns: Array de todas las zonas calculadas
    static func allZones(maxHR: Int) -> [HeartRateZone] {
        return [
            HeartRateZone(zone: .zone1, minBPM: Int(Double(maxHR) * 0.5), maxBPM: Int(Double(maxHR) * 0.6), percentageMin: 50, percentageMax: 60),
            HeartRateZone(zone: .zone2, minBPM: Int(Double(maxHR) * 0.6), maxBPM: Int(Double(maxHR) * 0.7), percentageMin: 60, percentageMax: 70),
            HeartRateZone(zone: .zone3, minBPM: Int(Double(maxHR) * 0.7), maxBPM: Int(Double(maxHR) * 0.8), percentageMin: 70, percentageMax: 80),
            HeartRateZone(zone: .zone4, minBPM: Int(Double(maxHR) * 0.8), maxBPM: Int(Double(maxHR) * 0.9), percentageMin: 80, percentageMax: 90),
            HeartRateZone(zone: .zone5, minBPM: Int(Double(maxHR) * 0.9), maxBPM: maxHR, percentageMin: 90, percentageMax: 100)
        ]
    }
}
