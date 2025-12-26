//
//  HealthKitBadge.swift
//  RunningTraining
//
//  Created on 2025-12-25.
//

import SwiftUI

/// Badge visual para indicar si un workout está sincronizado con Apple Health
struct HealthKitBadge: View {
    let synced: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption)
            Text(text)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .cornerRadius(12)
    }

    private var iconName: String {
        synced ? "checkmark.seal.fill" : "applewatch"
    }

    private var text: String {
        synced ? "Sincronizado" : "Apple Health"
    }

    private var backgroundColor: Color {
        synced ? Color.green.opacity(0.2) : Color.gray.opacity(0.2)
    }

    private var foregroundColor: Color {
        synced ? .green : .gray
    }
}

#Preview {
    VStack(spacing: 16) {
        HealthKitBadge(synced: true)
        HealthKitBadge(synced: false)
    }
    .padding()
    .background(AppTheme.background)
}
