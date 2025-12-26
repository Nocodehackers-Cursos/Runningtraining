//
//  EditableDataCard.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

/// Card editable para SummaryView
struct EditableDataCard: View {
    let title: String
    let value: String
    let icon: String
    let onEdit: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            onEdit()
        }) {
            HStack(spacing: 16) {
                // Icono
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 40)

                // Título y valor
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)

                    Text(value)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.cardBackground)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        EditableDataCard(
            title: "Sesiones por semana",
            value: "4 días",
            icon: "figure.run",
            onEdit: {}
        )

        EditableDataCard(
            title: "Fecha de carrera",
            value: "15 Mar 2025 (12 semanas)",
            icon: "calendar",
            onEdit: {}
        )

        EditableDataCard(
            title: "Ritmo actual",
            value: "6:00 /km",
            icon: "speedometer",
            onEdit: {}
        )

        EditableDataCard(
            title: "FC máxima",
            value: "180 bpm",
            icon: "heart.fill",
            onEdit: {}
        )
    }
    .padding()
    .background(AppTheme.background)
}
