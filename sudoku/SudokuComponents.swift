//
//  SudokuComponents.swift
//  sudoku
//
//  Created by NEO on 21/03/2026.
//

import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct FinishedGameRowView: View {
    let finishedGame: FinishedGame

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(finishedGame.difficulty)
                    .font(.headline)
                Text(finishedGame.completedAt, format: .dateTime.month().day().year().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(finishedGame.clues) clues")
                    .font(.subheadline.weight(.medium))
                Text("\(finishedGame.mistakes) mistake\(finishedGame.mistakes == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
