//
//  PromptBuilder.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation

/// Constructor de prompts para OpenAI
struct PromptBuilder {
    /// Construye el prompt para generar un plan de entrenamiento de media maratón
    /// - Parameter user: El usuario con sus parámetros de entrenamiento
    /// - Returns: Prompt estructurado para GPT-4o
    static func buildTrainingPlanPrompt(for user: User) -> String {
        let weeksUntilRace = Date().weeksUntil(user.raceDate)
        let currentPace = PaceFormatter.format(paceMinPerKm: user.currentPaceMinPerKm, useMetric: user.useMetricUnits)

        // Calcular volumen semanal recomendado basado en sesiones
        let recommendedVolumeMin = user.sessionsPerWeek * 7
        let recommendedVolumeMax = user.sessionsPerWeek * 10

        // Construir información de última carrera si está disponible
        var lastRaceInfo = ""
        if let lastDistance = user.lastRaceDistance,
           let lastPace = user.lastRacePaceMinPerKm,
           let lastType = user.lastRaceType {
            let lastPaceFormatted = PaceFormatter.format(paceMinPerKm: lastPace, useMetric: user.useMetricUnits)
            let daysAgo = user.lastRaceDate.map { Date().daysUntil($0) } ?? 0

            let paceComparison = lastPace < user.currentPaceMinPerKm ? "MÁS RÁPIDO" : "similar o más lento"

            lastRaceInfo = """

            ÚLTIMA CARRERA:
            - Distancia: \(lastType) (\(String(format: "%.1f", lastDistance))km)
            - Ritmo: \(lastPaceFormatted) (vs objetivo \(currentPace) → \(paceComparison))
            - Hace: \(abs(daysAgo)) días
            """
        }

        return """
        Eres un entrenador profesional certificado en running, especializado en media maratones.

        PERFIL DEL CORREDOR:
        - Sesiones/semana: \(user.sessionsPerWeek)
        - Semanas hasta carrera: \(weeksUntilRace)
        - Ritmo objetivo: \(currentPace)
        - FC Máxima: \(user.maxHeartRate) bpm\(lastRaceInfo)

        PASO 1 - ANÁLISIS (razonamiento interno):
        Determina:
        a) Nivel del corredor (principiante/intermedio/avanzado)
           - Si tiene última carrera y ritmo < objetivo → nivel superior
           - Si tiene < 10 semanas o ritmo > 7:00/km → principiante
           - Si tiene experiencia reciente y ritmo 5:30-7:00/km → intermedio
           - Si ritmo < 5:30/km y experiencia → avanzado

        b) Volumen semanal apropiado
           - \(user.sessionsPerWeek) sesiones → \(recommendedVolumeMin)-\(recommendedVolumeMax)km iniciales
           - Long run inicial: 30-40% del volumen semanal
           - Incremento: máx 10%/semana con descarga cada 3-4 sem

        c) Distribución de fases según \(weeksUntilRace) semanas:
           - 8-10 sem: 40% base, 40% build, 20% taper
           - 11-14 sem: 35% base, 45% build, 20% taper
           - 15+ sem: 30% base, 50% build, 20% taper

        PASO 2 - PLAN DE \(weeksUntilRace) SEMANAS:

        Tipos de workout:
        - long_run: Construir resistencia aeróbica (zona 2-3, pace objetivo +45-60s/km)
        - tempo_run: Umbral anaeróbico (zona 3-4, pace objetivo +15-30s/km)
        - intervals: Velocidad/VO2max (zona 4-5, pace objetivo -15-30s/km)
        - easy_run: Recuperación activa (zona 2, pace objetivo +60-90s/km)
        - recovery_run: Muy suave (zona 1-2, pace objetivo +90-120s/km)
        - rest: Descanso completo

        Principios de seguridad:
        ✓ Incremento gradual (máx 10%/semana, descarga cada 3-4 sem)
        ✓ Nunca aumentar distancia E intensidad simultáneamente
        ✓ Incluir 10min warm-up en workouts intensos (incluido en distancia)
        ✓ Mínimo 1 día completo de descanso/semana
        ✓ Últimas 2 semanas = taper (50% volumen)

        Zonas FC (% de \(user.maxHeartRate) bpm):
        - zone1: 50-60% (recuperación)
        - zone2: 60-70% (base aeróbica)
        - zone3: 70-80% (tempo)
        - zone4: 80-90% (umbral)
        - zone5: 90-100% (VO2max)

        JSON Output (ÚNICAMENTE JSON válido, sin markdown):
        {
          "analysis": {
            "runnerLevel": "principiante|intermedio|avanzado",
            "weeklyVolumeKm": número,
            "reasoning": "Breve explicación (2-3 líneas) del enfoque del plan"
          },
          "weeks": [
            {
              "weekNumber": 1,
              "focus": "Base Building|Build Phase|Peak Week|Taper",
              "totalVolumeKm": número,
              "workouts": [
                {
                  "dayOfWeek": 1-7,
                  "type": "long_run|tempo_run|intervals|easy_run|recovery_run|rest",
                  "title": "Título descriptivo",
                  "distanceKm": número (null si rest),
                  "targetPaceMinPerKm": número (null si rest),
                  "heartRateZone": "zone1|zone2|zone3|zone4|zone5" (null si rest),
                  "description": "Descripción con instrucciones específicas. Para intensos incluye estructura del workout (ej: 2km warmup + 6x800m + 2km cooldown)",
                  "goals": ["objetivo1", "objetivo2", "objetivo3"]
                }
              ]
            }
          ]
        }

        REGLAS CRÍTICAS:
        - dayOfWeek: 1=Lunes, 7=Domingo
        - EXACTAMENTE \(user.sessionsPerWeek) workouts por semana (incluye rest si aplica)
        - Distribuir workouts equitativamente en la semana
        - Mínimo 1 long_run/semana
        - Últimas 2 semanas = taper (reducir volumen 50%)
        - Para "rest": omitir distanceKm, targetPaceMinPerKm, heartRateZone
        - Para otros tipos: TODOS los campos son obligatorios
        - totalVolumeKm debe coincidir con suma de distancias de workouts
        - Ritmos ajustados según nivel y tipo de workout

        DEVUELVE ÚNICAMENTE JSON VÁLIDO, SIN ```json NI TEXTO ADICIONAL.
        """
    }
}
