//
//  TodayHeaderView.swift
//  RunningTraining
//
//  Created on 2025-12-24.
//

import SwiftUI

struct TodayHeaderView: View {
    let greeting: String
    let currentDate: Date
    let daysUntilRace: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)

                Text(currentDate.formattedLong())
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            // Countdown circular
            VStack(spacing: 2) {
                Text("\(daysUntilRace)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Text("días")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(width: 70, height: 70)
            .background(
                Circle()
                    .fill(AppTheme.secondary)
            )
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
    }
}
