//
//  SudokuKeyboardHandler.swift
//  sudoku
//
//  Created by NEO on 21/03/2026.
//

import SwiftUI

#if os(macOS)
import AppKit

struct MacKeyboardHandler: NSViewRepresentable {
    let onMove: (MoveCommandDirection) -> Void
    let onNumber: (Int) -> Void
    let onDelete: () -> Void

    func makeNSView(context: Context) -> KeyCatchingView {
        let view = KeyCatchingView()
        view.onMove = onMove
        view.onNumber = onNumber
        view.onDelete = onDelete
        return view
    }

    func updateNSView(_ nsView: KeyCatchingView, context: Context) {
        nsView.onMove = onMove
        nsView.onNumber = onNumber
        nsView.onDelete = onDelete
        nsView.makeFirstResponderIfNeeded()
    }
}

final class KeyCatchingView: NSView {
    var onMove: ((MoveCommandDirection) -> Void)?
    var onNumber: ((Int) -> Void)?
    var onDelete: (() -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        makeFirstResponderIfNeeded()
    }

    func makeFirstResponderIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let window = self.window, window.firstResponder !== self else { return }
            window.makeFirstResponder(self)
        }
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            onMove?(.left)
        case 124:
            onMove?(.right)
        case 125:
            onMove?(.down)
        case 126:
            onMove?(.up)
        case 51, 117:
            onDelete?()
        default:
            guard let characters = event.charactersIgnoringModifiers else {
                super.keyDown(with: event)
                return
            }

            for character in characters {
                switch character {
                case "1"..."9":
                    onNumber?(Int(String(character)) ?? 0)
                    return
                case "0":
                    onDelete?()
                    return
                default:
                    continue
                }
            }

            super.keyDown(with: event)
        }
    }
}
#endif
