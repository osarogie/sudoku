//
//  ContentView.swift
//  sudoku
//
//  Created by NEO on 21/03/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var finishedGames: [FinishedGame]
    @State private var game = SudokuGame.sample()
    @State private var selectedCell: CellPosition?
    @State private var showSolvedAlert = false
    @State private var hasRecordedCompletion = false

    init() {
        _finishedGames = Query(sort: \FinishedGame.completedAt, order: .reverse)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let boardSize = min(geometry.size.width - 32, 420.0)

                ScrollView {
                    VStack(spacing: 24) {
                        header
                        SudokuBoardView(
                            game: game,
                            selectedCell: selectedCell,
                            size: boardSize,
                            onSelect: { selectedCell = $0 },
                            isRelatedToSelection: isRelatedToSelection(_:),
                            displayValue: displayValue(at:)
                        )
                        controls
                        keypad
                        completedGamesSection
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                }
#if os(macOS)
                .background {
                    MacKeyboardHandler(
                        onMove: moveSelection,
                        onNumber: place,
                        onDelete: clearSelectedCell
                    )
                }
#endif
            }
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
                StatCardView(title: "Filled", value: "\(filledCellCount)/81")
                StatCardView(title: "Mistakes", value: "\(game.mistakes)")
                StatCardView(title: "Status", value: game.isSolved ? "Complete" : "Playing")
            }
        }
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

    private var completedGamesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Completed Games")
                    .font(.headline)

                Spacer()

                if !finishedGames.isEmpty {
                    Text("\(finishedGames.count)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            if finishedGames.isEmpty {
                Text("Finished puzzles will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                VStack(spacing: 10) {
                    ForEach(finishedGames.prefix(8)) { finishedGame in
                        FinishedGameRowView(finishedGame: finishedGame)
                    }
                }
            }
        }
        .frame(maxWidth: 520, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var keypad: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 9), spacing: 4) {
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

        if game.isSolved, !hasRecordedCompletion {
            saveFinishedGame()
            hasRecordedCompletion = true
            showSolvedAlert = true
        }
    }

    private func clearSelectedCell() {
        guard let selectedCell, !game.isFixed(selectedCell) else { return }
        game.clear(at: selectedCell)
    }

#if os(macOS)
    private func moveSelection(_ direction: MoveCommandDirection) {
        let current = selectedCell ?? CellPosition(row: 0, column: 0)

        switch direction {
        case .up:
            selectedCell = CellPosition(row: max(0, current.row - 1), column: current.column)
        case .down:
            selectedCell = CellPosition(row: min(8, current.row + 1), column: current.column)
        case .left:
            selectedCell = CellPosition(row: current.row, column: max(0, current.column - 1))
        case .right:
            selectedCell = CellPosition(row: current.row, column: min(8, current.column + 1))
        default:
            break
        }
    }
#endif

    private func startNewGame() {
        game = SudokuGame.sample()
        selectedCell = nil
        showSolvedAlert = false
        hasRecordedCompletion = false
    }

    private func saveFinishedGame() {
        let finishedGame = FinishedGame(
            difficulty: game.puzzle.difficulty.rawValue,
            mistakes: game.mistakes,
            clues: game.puzzle.clueCount
        )

        modelContext.insert(finishedGame)

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save finished game: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
