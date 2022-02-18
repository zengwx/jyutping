import SwiftUI
import Cocoa
import InputMethodKit


enum KeyboardMode {
        case transparent
        case english
        case cantonese

        var isCantoneseMode: Bool {
                return self == .cantonese
        }
        var isEnglishMode: Bool {
                switch self {
                case .transparent:
                        return true
                case .english:
                        return true
                case .cantonese:
                        return false
                }
        }
}


class JyutpingInputController: IMKInputController {

        private var window: NSWindow?
        private lazy var isWindowInitialed: Bool = false

        private lazy var screenFrame: CGRect = NSScreen.main?.frame ?? CGRect(origin: .zero, size: CGSize(width: 1920, height: 1080))

        // FIXME: candidateView size
        private func showWindow(origin: CGPoint, size: CGSize = CGSize(width: 600, height: 256)) {
                guard isBufferState && !displayObject.items.isEmpty else { return }
                let x: CGFloat = {
                        if origin.x > (screenFrame.maxX - size.width) {
                                // should be cursor's left side
                                return origin.x + 16
                        } else {
                                return origin.x + 16
                        }
                }()
                let y: CGFloat = {
                        if origin.y > (screenFrame.minY + size.height) {
                                // below cursor
                                return origin.y - size.height - 8
                        } else {
                                // above cursor
                                return origin.y + 16
                        }
                }()
                let frame = CGRect(x: x, y: y, width: size.width, height: size.height)
                if isWindowInitialed {
                        window?.setFrame(frame, display: true)
                } else {
                        window = NSWindow(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)
                        initialMainWindow()
                }
        }
        private func initialMainWindow() {
                window?.backgroundColor = .clear
                window?.level = .floating
                window?.orderFrontRegardless()

                let candidateUI = NSHostingController(rootView: CandidatesView().environmentObject(displayObject))
                window?.contentView?.addSubview(candidateUI.view)
                candidateUI.view.translatesAutoresizingMaskIntoConstraints = false
                if let topAnchor = window?.contentView?.topAnchor, let leadingAnchor = window?.contentView?.leadingAnchor {
                        NSLayoutConstraint.activate([
                                candidateUI.view.topAnchor.constraint(equalTo: topAnchor),
                                candidateUI.view.leadingAnchor.constraint(equalTo: leadingAnchor)
                        ])
                }
                window?.contentViewController?.addChild(candidateUI)

                isWindowInitialed = true
        }

        private func position(of client: IMKTextInput) -> CGPoint {
                var lineHeightRectangle: CGRect = .init()
                client.attributes(forCharacterIndex: 0, lineHeightRectangle: &lineHeightRectangle)
                return lineHeightRectangle.origin
        }

        private lazy var displayObject = DisplayObject()
        private lazy var candidates: [Candidate] = [] {
                didSet {
                        displayObject.resetHighlightedIndex()
                        guard !candidates.isEmpty else {
                                displayObject.items = []
                                return
                        }
                        let bound: Int = candidates.count > 9 ? 9 : candidates.count
                        displayObject.items = candidates[..<bound].map({ DisplayCandidate($0.text, comment: $0.romanization) })
                }
        }

        private lazy var bufferText: String = .empty {
                didSet {
                        guard !bufferText.isEmpty else {
                                markedText = .empty
                                candidates = []
                                displayObject.resetHighlightedIndex()
                                displayObject.items = []
                                window?.setFrame(.zero, display: true)
                                return
                        }
                        let schemes = Splitter.split(bufferText)
                        if let firstScheme = schemes.first, firstScheme.joined().count == bufferText.count {
                                markedText = firstScheme.joined(separator: " ")
                        } else {
                                markedText = bufferText
                        }
                        if let suggestions = engine?.suggest(for: bufferText, schemes: schemes) {
                                candidates = suggestions.uniqued()
                        }
                }
        }
        private lazy var currentClient: IMKTextInput? = nil
        private lazy var markedText: String = .empty {
                didSet {
                        let convertedText: NSString = markedText as NSString
                        currentClient?.setMarkedText(convertedText, selectionRange: NSRange(location: convertedText.length, length: 0), replacementRange: NSRange(location: NSNotFound, length: 0))
                }
        }

        private lazy var engine: Engine? = nil

        override func activateServer(_ sender: Any!) {
                if engine == nil {
                        engine = Engine()
                }
                currentClient = sender as? IMKTextInput
        }
        override func deactivateServer(_ sender: Any!) {
                engine?.close()
                engine = nil
                shutdownSession()
                currentClient = nil
        }

        private lazy var keyboardMode: KeyboardMode = .cantonese
        private var isBufferState: Bool {
                return !(bufferText.isEmpty)
        }

        override func recognizedEvents(_ sender: Any!) -> Int {
                let masks: NSEvent.EventTypeMask = [.keyDown, .flagsChanged]
                return Int(masks.rawValue)
        }

        override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {

                // Ignore any Command + ...
                guard !(event.modifierFlags.contains(.command)) else {
                        if isBufferState {
                                bufferText = .empty
                        }
                        return false
                }
                if event.keyCode == KeyCode.Keypad.VK_KEYPAD_CLEAR {
                        // FIXME: Replace CLEAR with Shift
                        switch keyboardMode {
                        case .transparent, .english:
                                keyboardMode = .cantonese
                        case .cantonese:
                                keyboardMode = .english
                        }
                        return true
                }
                guard keyboardMode.isCantoneseMode else { return false }
                guard let client: IMKTextInput = sender as? IMKTextInput else { return false }

                switch event.keyCode.representative {
                case .arrow(let direction):
                        switch direction {
                        case .up:
                                guard isBufferState else { return false }
                                displayObject.decreaseHighlightedIndex()
                        case .down:
                                guard isBufferState else { return false }
                                displayObject.increaseHighlightedIndex()
                        case .left:
                                return false
                        case .right:
                                return false
                        }
                case .number(let number):
                        guard isBufferState else { return false }
                        selectDisplayingItem(index: number - 1, client: client)
                case .instant(let text):
                        if isBufferState {
                                selectDisplayingItem(index: displayObject.highlightedIndex, client: client)
                        }
                        insert(text)
                        bufferText = .empty
                case .transparent:
                        if isBufferState {
                                insert(bufferText)
                                bufferText = .empty
                        }
                        return false
                case .alphabet:
                        guard let letter: String = event.characters else { return false }
                        bufferText += letter
                default:
                        switch event.keyCode {
                        case KeyCode.Special.VK_ESCAPE:
                                shutdownSession()
                        case KeyCode.Symbol.VK_MINUS, KeyCode.Special.VK_PAGEUP:
                                guard isBufferState else { return false }
                                // FIXME: previousPage()
                                displayObject.decreaseHighlightedIndex()
                        case KeyCode.Symbol.VK_EQUAL, KeyCode.Special.VK_PAGEDOWN:
                                guard isBufferState else { return false }
                                // FIXME: nextPage()
                                displayObject.increaseHighlightedIndex()
                        case KeyCode.Special.VK_SPACE:
                                guard isBufferState else { return false }
                                selectDisplayingItem(index: displayObject.highlightedIndex, client: client)
                        case KeyCode.Special.VK_RETURN, KeyCode.Keypad.VK_KEYPAD_ENTER:
                                guard isBufferState else { return false }
                                insert(bufferText)
                                bufferText = .empty
                        case KeyCode.Special.VK_BACKWARD_DELETE:
                                guard isBufferState else { return false }
                                bufferText = String(bufferText.dropLast())
                        case KeyCode.Keypad.VK_KEYPAD_CLEAR:
                                guard isBufferState else { return false }
                                bufferText = .empty
                        case KeyCode.Alphabet.VK_U where event.modifierFlags == .control:
                                guard isBufferState else { return false }
                                bufferText = .empty
                        default:
                                return false
                        }
                }

                showWindow(origin: position(of: client))

                return true
        }

        private func selectDisplayingItem(index: Int, client: IMKTextInput) {
                guard let selectedItem = displayObject.items.fetch(index) else { return }
                client.insertText(selectedItem.text, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))

                guard let correspondingCandidate = candidates.fetch(index) else { return }
                let newBufferText = bufferText.dropFirst(correspondingCandidate.input.count)
                if newBufferText.isEmpty {
                        shutdownSession()
                } else {
                        bufferText = String(newBufferText)
                }
        }

        private func insert(_ text: String) {
                currentClient?.insertText(text, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        }

        private func shutdownSession() {
                bufferText = .empty
                candidates = []
                displayObject.items = []
                displayObject.resetHighlightedIndex()
                window?.setFrame(.zero, display: true)
        }
}
