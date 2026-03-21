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
        SudokuGame(puzzle: SudokuPuzzle.generate())
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

    private static let difficultyClues: [Difficulty: Int] = [
        .easy: 40,
        .medium: 32,
        .hard: 26
    ]

    static func generate() -> SudokuPuzzle {
        let difficulty = Difficulty.allCases.randomElement() ?? .medium
        let solution = shuffledSolvedBoard()
        let clues = difficultyClues[difficulty] ?? 32
        let grid = puzzleGrid(from: solution, clues: clues)
        return SudokuPuzzle(difficulty: difficulty, grid: grid, solution: solution)
    }

    private static func shuffledSolvedBoard() -> [[Int]] {
        let base = 3
        let side = base * base

        func pattern(_ row: Int, _ column: Int) -> Int {
            (base * (row % base) + row / base + column) % side
        }

        func shuffledGroups() -> [Int] {
            Array(0..<base).shuffled()
        }

        let rows = shuffledGroups().flatMap { group in
            Array((group * base)..<(group * base + base)).shuffled()
        }
        let columns = shuffledGroups().flatMap { group in
            Array((group * base)..<(group * base + base)).shuffled()
        }
        let numbers = Array(1...side).shuffled()

        return rows.map { row in
            columns.map { column in
                numbers[pattern(row, column)]
            }
        }
    }

    private static func puzzleGrid(from solution: [[Int]], clues: Int) -> [[Int]] {
        var puzzle = solution
        var positions = Array(0..<81).shuffled()
        let removalsTarget = max(0, 81 - clues)
        var removed = 0

        while removed < removalsTarget, let index = positions.popLast() {
            let row = index / 9
            let column = index % 9
            let previous = puzzle[row][column]
            puzzle[row][column] = 0

            var candidate = puzzle
            var solutionCount = 0
            solve(&candidate, solutionCount: &solutionCount, limit: 2)

            if solutionCount == 1 {
                removed += 1
            } else {
                puzzle[row][column] = previous
            }
        }

        return puzzle
    }

    private static func solve(_ board: inout [[Int]], solutionCount: inout Int, limit: Int) {
        guard solutionCount < limit else { return }

        guard let cell = nextEmptyCell(in: board) else {
            solutionCount += 1
            return
        }

        for value in Array(1...9).shuffled() where isValid(value, atRow: cell.row, column: cell.column, in: board) {
            board[cell.row][cell.column] = value
            solve(&board, solutionCount: &solutionCount, limit: limit)
            board[cell.row][cell.column] = 0

            if solutionCount >= limit {
                return
            }
        }
    }

    private static func nextEmptyCell(in board: [[Int]]) -> CellPosition? {
        var bestCell: CellPosition?
        var bestCandidateCount = Int.max

        for row in 0..<9 {
            for column in 0..<9 where board[row][column] == 0 {
                let candidateCount = validValues(forRow: row, column: column, in: board).count

                if candidateCount < bestCandidateCount {
                    bestCandidateCount = candidateCount
                    bestCell = CellPosition(row: row, column: column)
                }

                if candidateCount == 1 {
                    return bestCell
                }
            }
        }

        return bestCell
    }

    private static func validValues(forRow row: Int, column: Int, in board: [[Int]]) -> [Int] {
        Array(1...9).filter { isValid($0, atRow: row, column: column, in: board) }
    }

    private static func isValid(_ value: Int, atRow row: Int, column: Int, in board: [[Int]]) -> Bool {
        let boxRow = (row / 3) * 3
        let boxColumn = (column / 3) * 3

        for index in 0..<9 {
            if board[row][index] == value || board[index][column] == value {
                return false
            }
        }

        for rowOffset in 0..<3 {
            for columnOffset in 0..<3 where board[boxRow + rowOffset][boxColumn + columnOffset] == value {
                return false
            }
        }

        return true
    }
}

extension SudokuPuzzle.Difficulty: CaseIterable {}

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
