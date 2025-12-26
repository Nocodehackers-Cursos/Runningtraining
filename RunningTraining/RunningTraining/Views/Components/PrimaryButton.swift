//
//  PrimaryButton.swift
//  RunningTraining
//
//  Created on 2025-12-20.
//

import SwiftUI

/// Botón reutilizable con estilo personalizado
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var style: ButtonStyle = .primary

    enum ButtonStyle {
        case primary
        case secondary

        var backgroundColor: Color {
            switch self {
            case .primary: return AppTheme.primary
            case .secondary: return AppTheme.secondaryBackground
            }
        }

        var foregroundColor: Color {
            return .white
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                }

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isDisabled ? Color.gray.opacity(0.3) : style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .cornerRadius(12)
        }
        .disabled(isDisabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(
            title: "Continuar",
            action: {},
            style: .primary
        )

        PrimaryButton(
            title: "Generando...",
            action: {},
            isLoading: true,
            style: .primary
        )

        PrimaryButton(
            title: "Deshabilitado",
            action: {},
            isDisabled: true,
            style: .primary
        )

        PrimaryButton(
            title: "Secundario",
            action: {},
            style: .secondary
        )
    }
    .padding()
}
