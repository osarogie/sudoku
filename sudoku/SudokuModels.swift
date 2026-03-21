//
//  SudokuModels.swift
//  sudoku
//
//  Created by NEO on 21/03/2026.
//

import Foundation
import SwiftUI

struct SudokuGame {
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

struct SudokuPuzzle {
    let difficulty: Difficulty
    let grid: [[Int]]
    let solution: [[Int]]

    var clueCount: Int {
        grid.joined().filter { $0 != 0 }.count
    }

    enum Difficulty: String, CaseIterable {
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

struct CellPosition: Hashable {
    let row: Int
    let column: Int

    var box: Int {
        (row / 3) * 3 + (column / 3)
    }
}
