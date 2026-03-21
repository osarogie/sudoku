//
//  ContentView.swift
//  sudoku
//
//  Created by NEO on 21/03/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var game = SudokuGame.sample()
    @State private var selectedCell: CellPosition?
    @State private var showSolvedAlert = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let boardSize = min(geometry.size.width - 32, 420.0)

                ScrollView {
                    VStack(spacing: 24) {
                        header
                        board(size: boardSize)
                        controls
                        keypad
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Sudoku")
            .background(Color.secondary.opacity(0.08))
            .alert("Puzzle Solved", isPresented: $showSolvedAlert) {
                Button("New Game") {
                    startNewGame()
                }
                Button("Keep Playing", role: .cancel) {}
            } message: {
                Text("You completed the \(game.puzzle.difficulty.rawValue) puzzle with \(game.mistakes) mistake\(game.mistakes == 1 ? "" : "s").")
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(game.puzzle.difficulty.rawValue)
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                statCard(title: "Filled", value: "\(filledCellCount)/81")
                statCard(title: "Mistakes", value: "\(game.mistakes)")
                statCard(title: "Status", value: game.isSolved ? "Complete" : "Playing")
            }
        }
    }

    private func board(size: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<9, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<9, id: \.self) { column in
                        let position = CellPosition(row: row, column: column)
                        SudokuCellView(
                            value: displayValue(at: position),
                            isFixed: game.isFixed(position),
                            isSelected: selectedCell == position,
                            isRelated: isRelatedToSelection(position),
                            isIncorrect: game.incorrectCells.contains(position)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCell = position
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
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button("New Puzzle") {
                startNewGame()
            }
            .buttonStyle(.borderedProminent)

            Button("Clear Cell") {
                clearSelectedCell()
            }
            .buttonStyle(.bordered)
            .disabled(!canEditSelection)
        }
    }

    private var keypad: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(1...9, id: \.self) { number in
                Button {
                    place(number)
                } label: {
                    Text("\(number)")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 56)
                }
                .buttonStyle(NumberPadButtonStyle())
                .disabled(!canEditSelection)
            }
        }
    }

    private func statCard(title: String, value: String) -> some View {
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

    private var filledCellCount: Int {
        game.board.joined().filter { $0 != 0 }.count
    }

    private var canEditSelection: Bool {
        guard let selectedCell else { return false }
        return !game.isFixed(selectedCell)
    }

    private func displayValue(at position: CellPosition) -> String {
        let value = game.board[position.row][position.column]
        return value == 0 ? "" : "\(value)"
    }

    private func isRelatedToSelection(_ position: CellPosition) -> Bool {
        guard let selectedCell else { return false }
        return selectedCell.row == position.row
            || selectedCell.column == position.column
            || selectedCell.box == position.box
    }

    private func place(_ value: Int) {
        guard let selectedCell, !game.isFixed(selectedCell) else { return }

        game.place(value, at: selectedCell)

        if game.isSolved {
            showSolvedAlert = true
        }
    }

    private func clearSelectedCell() {
        guard let selectedCell, !game.isFixed(selectedCell) else { return }
        game.clear(at: selectedCell)
    }

    private func startNewGame() {
        game = SudokuGame.sample()
        selectedCell = nil
        showSolvedAlert = false
    }
}

private struct SudokuCellView: View {
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

private struct NumberPadButtonStyle: ButtonStyle {
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

private struct SudokuGame {
    let puzzle: SudokuPuzzle
    var board: [[Int]]
    var incorrectCells: Set<CellPosition> = []
    var mistakes = 0

    var isSolved: Bool {
        board == puzzle.solution
    }

    init(puzzle: SudokuPuzzle) {
        self.puzzle = puzzle
        self.board = puzzle.grid
        self.incorrectCells = []
    }

    mutating func place(_ value: Int, at position: CellPosition) {
        board[position.row][position.column] = value

        if puzzle.solution[position.row][position.column] == value {
            incorrectCells.remove(position)
        } else {
            incorrectCells.insert(position)
            mistakes += 1
        }
    }

    mutating func clear(at position: CellPosition) {
        board[position.row][position.column] = 0
        incorrectCells.remove(position)
    }

    func isFixed(_ position: CellPosition) -> Bool {
        puzzle.grid[position.row][position.column] != 0
    }

    static func sample() -> SudokuGame {
        SudokuGame(puzzle: SudokuPuzzle.samples.randomElement() ?? SudokuPuzzle.samples[0])
    }
}

private struct SudokuPuzzle {
    let difficulty: Difficulty
    let grid: [[Int]]
    let solution: [[Int]]

    enum Difficulty: String {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }

    static let samples: [SudokuPuzzle] = [
        SudokuPuzzle(
            difficulty: .easy,
            grid: [
                [5, 3, 0, 0, 7, 0, 0, 0, 0],
                [6, 0, 0, 1, 9, 5, 0, 0, 0],
                [0, 9, 8, 0, 0, 0, 0, 6, 0],
                [8, 0, 0, 0, 6, 0, 0, 0, 3],
                [4, 0, 0, 8, 0, 3, 0, 0, 1],
                [7, 0, 0, 0, 2, 0, 0, 0, 6],
                [0, 6, 0, 0, 0, 0, 2, 8, 0],
                [0, 0, 0, 4, 1, 9, 0, 0, 5],
                [0, 0, 0, 0, 8, 0, 0, 7, 9]
            ],
            solution: [
                [5, 3, 4, 6, 7, 8, 9, 1, 2],
                [6, 7, 2, 1, 9, 5, 3, 4, 8],
                [1, 9, 8, 3, 4, 2, 5, 6, 7],
                [8, 5, 9, 7, 6, 1, 4, 2, 3],
                [4, 2, 6, 8, 5, 3, 7, 9, 1],
                [7, 1, 3, 9, 2, 4, 8, 5, 6],
                [9, 6, 1, 5, 3, 7, 2, 8, 4],
                [2, 8, 7, 4, 1, 9, 6, 3, 5],
                [3, 4, 5, 2, 8, 6, 1, 7, 9]
            ]
        ),
        SudokuPuzzle(
            difficulty: .medium,
            grid: [
                [0, 2, 0, 6, 0, 8, 0, 0, 0],
                [5, 8, 0, 0, 0, 9, 7, 0, 0],
                [0, 0, 0, 0, 4, 0, 0, 0, 0],
                [3, 7, 0, 0, 0, 0, 5, 0, 0],
                [6, 0, 0, 0, 0, 0, 0, 0, 4],
                [0, 0, 8, 0, 0, 0, 0, 1, 3],
                [0, 0, 0, 0, 2, 0, 0, 0, 0],
                [0, 0, 9, 8, 0, 0, 0, 3, 6],
                [0, 0, 0, 3, 0, 6, 0, 9, 0]
            ],
            solution: [
                [1, 2, 3, 6, 7, 8, 9, 4, 5],
                [5, 8, 4, 2, 3, 9, 7, 6, 1],
                [9, 6, 7, 1, 4, 5, 3, 2, 8],
                [3, 7, 2, 4, 6, 1, 5, 8, 9],
                [6, 9, 1, 5, 8, 3, 2, 7, 4],
                [4, 5, 8, 7, 9, 2, 6, 1, 3],
                [8, 3, 6, 9, 2, 4, 1, 5, 7],
                [2, 1, 9, 8, 5, 7, 4, 3, 6],
                [7, 4, 5, 3, 1, 6, 8, 9, 2]
            ]
        ),
        SudokuPuzzle(
            difficulty: .hard,
            grid: [
                [0, 0, 0, 0, 0, 0, 2, 0, 0],
                [0, 8, 0, 0, 0, 7, 0, 9, 0],
                [6, 0, 2, 0, 0, 0, 5, 0, 0],
                [0, 7, 0, 0, 6, 0, 0, 0, 0],
                [0, 0, 0, 9, 0, 1, 0, 0, 0],
                [0, 0, 0, 0, 2, 0, 0, 4, 0],
                [0, 0, 5, 0, 0, 0, 6, 0, 3],
                [0, 9, 0, 4, 0, 0, 0, 7, 0],
                [0, 0, 6, 0, 0, 0, 0, 0, 0]
            ],
            solution: [
                [9, 5, 7, 6, 1, 3, 2, 8, 4],
                [4, 8, 3, 2, 5, 7, 1, 9, 6],
                [6, 1, 2, 8, 4, 9, 5, 3, 7],
                [1, 7, 8, 3, 6, 4, 9, 5, 2],
                [5, 2, 4, 9, 7, 1, 3, 6, 8],
                [3, 6, 9, 5, 2, 8, 7, 4, 1],
                [8, 4, 5, 7, 9, 2, 6, 1, 3],
                [2, 9, 1, 4, 3, 6, 8, 7, 5],
                [7, 3, 6, 1, 8, 5, 4, 2, 9]
            ]
        )
    ]
}

private struct CellPosition: Hashable {
    let row: Int
    let column: Int

    var box: Int {
        (row / 3) * 3 + (column / 3)
    }
}

#Preview {
    ContentView()
}
