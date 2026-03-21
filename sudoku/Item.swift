//
//  Item.swift
//  sudoku
//
//  Created by NEO on 21/03/2026.
//

import Foundation
import SwiftData

@Model
final class FinishedGame {
    var completedAt: Date
    var difficulty: String
    var mistakes: Int
    var clues: Int

    init(completedAt: Date = .now, difficulty: String, mistakes: Int, clues: Int) {
        self.completedAt = completedAt
        self.difficulty = difficulty
        self.mistakes = mistakes
        self.clues = clues
    }
}
