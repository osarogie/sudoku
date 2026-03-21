//
//  SudokuBoardView.swift
//  sudoku
//
//  Created by NEO on 21/03/2026.
//

import SwiftUI

struct SudokuBoardView: View {
    let game: SudokuGame
    let selectedCell: CellPosition?
    let size: CGFloat
    let onSelect: (CellPosition) -> Void
    let isRelatedToSelection: (CellPosition) -> Bool
    let displayValue: (CellPosition) -> String

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<9, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<9, id: \.self) { column in
                        let position = CellPosition(row: row, column: column)
                        SudokuCellView(
                            value: displayValue(position),
                            isFixed: game.isFixed(position),
                            isSelected: selectedCell == position,
                            isRelated: isRelatedToSelection(position),
                            isIncorrect: game.incorrectCells.contains(position)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelect(position)
                        }
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(row % 3 == 0 ? Color.primary : Color.secondary.opacity(0.35))
                                .frame(height: row % 3 == 0 ? 2 : 0.5)
                        }
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(column % 3 == 0 ? Color.primary : Color.secondary.opacity(0.35))
                                .frame(width: column % 3 == 0 ? 2 : 0.5)
                        }
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(row == 8 ? Color.primary : Color.clear)
                                .frame(height: row == 8 ? 2 : 0)
                        }
                        .overlay(alignment: .trailing) {
                            Rectangle()
                                .fill(column == 8 ? Color.primary : Color.clear)
                                .frame(width: column == 8 ? 2 : 0)
                        }
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .background(.background)
        .clipShape(Rectangle())
        .overlay {
            Rectangle()
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
    }
}

struct SudokuCellView: View {
    let value: String
    let isFixed: Bool
    let isSelected: Bool
    let isRelated: Bool
    let isIncorrect: Bool

    var body: some View {
        ZStack {
            backgroundColor

            Text(value)
                .font(.title3.weight(isFixed ? .bold : .medium))
                .foregroundStyle(foregroundColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.24)
        }
        if isIncorrect {
            return Color.red.opacity(0.16)
        }
        if isRelated {
            return Color.accentColor.opacity(0.08)
        }
        return Color.clear
    }

    private var foregroundColor: Color {
        if isIncorrect {
            return .red
        }
        return isFixed ? .primary : .accentColor
    }
}

struct NumberPadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.accentColor.opacity(0.22) : Color.secondary.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            }
    }
}
