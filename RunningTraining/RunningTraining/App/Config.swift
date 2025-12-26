//
//  Config.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation

/// Configuración de la aplicación
enum Config {
    // IMPORTANTE: Reemplaza este placeholder con tu API Key de OpenAI
    // Para obtener una: https://platform.openai.com/api-keys
    static let openAIAPIKey = "TU_API_KEY_AQUI"

    // Modelo de OpenAI a utilizar
    static let openAIModel = "gpt-4o"

    // Endpoint de la API de OpenAI
    static let apiEndpoint = "https://api.openai.com/v1/chat/completions"

    // Timeout para requests (en segundos)
    static let requestTimeout: TimeInterval = 60

    // Temperatura para la generación (0.0 - 2.0, menor = más determinista)
    static let temperature: Double = 0.7

    // Máximo de tokens en la respuesta
    static let maxTokens: Int = 16000
}
