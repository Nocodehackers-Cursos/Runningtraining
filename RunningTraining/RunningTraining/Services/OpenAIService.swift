//
//  OpenAIService.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import Foundation

/// Servicio para comunicarse con la API de OpenAI
class OpenAIService {
    // Errores personalizados
    enum OpenAIError: LocalizedError {
        case invalidAPIKey
        case networkError(Error)
        case invalidResponse
        case decodingError(Error)
        case apiError(String)
        case timeout

        var errorDescription: String? {
            switch self {
            case .invalidAPIKey:
                return "API Key de OpenAI inválida. Verifica la configuración."
            case .networkError(let error):
                return "Error de red: \(error.localizedDescription)"
            case .invalidResponse:
                return "Respuesta inválida de OpenAI"
            case .decodingError(let error):
                return "Error al procesar respuesta: \(error.localizedDescription)"
            case .apiError(let message):
                return "Error de API: \(message)"
            case .timeout:
                return "La solicitud ha excedido el tiempo límite"
            }
        }
    }

    /// Genera un plan de entrenamiento usando GPT-4o
    /// - Parameter prompt: El prompt construido por PromptBuilder
    /// - Returns: Respuesta en formato JSON como String
    func generateTrainingPlan(prompt: String) async throws -> String {
        // Validar API key
        guard Config.openAIAPIKey != "TU_API_KEY_AQUI",
              !Config.openAIAPIKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }

        // Construir request
        guard let url = URL(string: Config.apiEndpoint) else {
            throw OpenAIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = Config.requestTimeout
        request.setValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Body del request
        let requestBody: [String: Any] = [
            "model": Config.openAIModel,
            "messages": [
                [
                    "role": "system",
                    "content": "Eres un entrenador profesional de running. Devuelves únicamente JSON válido, sin texto adicional."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": Config.temperature,
            "max_tokens": Config.maxTokens,
            "response_format": ["type": "json_object"] // Forzar respuesta en JSON
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        // Ejecutar request
        let (data, response) = try await URLSession.shared.data(for: request)

        // Validar respuesta HTTP
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        // Manejar errores HTTP
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                throw OpenAIError.apiError(errorResponse.error.message)
            }
            throw OpenAIError.invalidResponse
        }

        // Decodificar respuesta
        do {
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)

            // Extraer contenido
            guard let content = openAIResponse.choices.first?.message.content else {
                throw OpenAIError.invalidResponse
            }

            return content
        } catch {
            throw OpenAIError.decodingError(error)
        }
    }
}

// MARK: - Response Models

/// Modelo de respuesta de OpenAI
struct OpenAIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}

/// Modelo de error de OpenAI
struct OpenAIErrorResponse: Codable {
    let error: ErrorDetail

    struct ErrorDetail: Codable {
        let message: String
        let type: String?
        let code: String?
    }
}
