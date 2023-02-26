import SwiftUI
import InputMethodKit

extension JyutpingInputController {

        override func menu() -> NSMenu! {
                let menuTittle: String = NSLocalizedString("menu.title", comment: "")
                let menu = NSMenu(title: menuTittle)

                let checkmark: String = " ✓"
                let cantoneseModeTitle: String = {
                        let text = NSLocalizedString("menu.mode.cantonese", comment: "")
                        return InstantSettings.inputMethodMode.isCantonese ? (text + checkmark) : text
                }()
                let abcModeTitle: String = {
                        let text = NSLocalizedString("menu.mode.abc", comment: "")
                        return InstantSettings.inputMethodMode.isABC ? (text + checkmark) : text
                }()
                let cantoneseMode = NSMenuItem(title: cantoneseModeTitle, action: #selector(toggleInputMethodMode), keyEquivalent: "")
                let abcMode = NSMenuItem(title: abcModeTitle, action: #selector(toggleInputMethodMode), keyEquivalent: "")
                menu.addItem(cantoneseMode)
                menu.addItem(abcMode)

                menu.addItem(.separator())

                let preferencesTitle: String = NSLocalizedString("menu.preferences", comment: "")
                let preferences = NSMenuItem(title: preferencesTitle, action: #selector(openPreferencesWindow), keyEquivalent: ",")
                preferences.keyEquivalentModifierMask = [.control, .shift]
                menu.addItem(preferences)

                menu.addItem(.separator())

                let terminateTittle: String = NSLocalizedString("menu.terminate", comment: "")
                let terminate = NSMenuItem(title: terminateTittle, action: #selector(terminateApp), keyEquivalent: "")
                menu.addItem(terminate)

                return menu
        }

        @objc private func toggleInputMethodMode() {
                let newMode: InputMethodMode = InstantSettings.inputMethodMode.isCantonese ? .abc : .cantonese
                InstantSettings.updateInputMethodMode(to: newMode)
                InputState.updateCurrent()
        }

        @objc private func openPreferencesWindow() {
                let shouldOpenNewWindow: Bool = NSApp.windows.map({ $0.frame.size.width < 128 }).reduce(true, { $0 && $1 })
                guard shouldOpenNewWindow else { return }
                let frame: CGRect = preferencesWindowFrame
                let window = NSWindow(contentRect: frame, styleMask: [.titled, .closable, .resizable, .fullSizeContentView], backing: .buffered, defer: true)
                window.title = NSLocalizedString("Jyutping Input Method Preferences", comment: "")
                let visualEffectView = NSVisualEffectView()
                visualEffectView.material = .sidebar
                visualEffectView.blendingMode = .behindWindow
                visualEffectView.state = .active
                window.contentView = visualEffectView
                let pane = NSHostingController(rootView: PreferencesView())
                window.contentView?.addSubview(pane.view)
                pane.view.translatesAutoresizingMaskIntoConstraints = false
                if let topAnchor = window.contentView?.topAnchor,
                   let bottomAnchor = window.contentView?.bottomAnchor,
                   let leadingAnchor = window.contentView?.leadingAnchor,
                   let trailingAnchor = window.contentView?.trailingAnchor {
                        NSLayoutConstraint.activate([
                                pane.view.topAnchor.constraint(equalTo: topAnchor),
                                pane.view.bottomAnchor.constraint(equalTo: bottomAnchor),
                                pane.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                                pane.view.trailingAnchor.constraint(equalTo: trailingAnchor)
                        ])
                }
                window.contentViewController?.addChild(pane)
                window.orderFrontRegardless()
                window.setFrame(frame, display: true)
                NSApp.activate(ignoringOtherApps: true)
        }
        private var preferencesWindowFrame: CGRect {
                let screenWidth: CGFloat = NSScreen.main?.frame.size.width ?? 1920
                let screenHeight: CGFloat = NSScreen.main?.frame.size.height ?? 1080
                let x: CGFloat = screenWidth / 4.0
                let y: CGFloat = screenHeight / 5.0
                let width: CGFloat = screenWidth / 2.0
                let height: CGFloat = (screenHeight / 5.0) * 3.0
                return CGRect(x: x, y: y, width: width, height: height)
        }

        @objc private func terminateApp() {
                NSRunningApplication.current.terminate()
                NSApp.terminate(self)
                exit(0)
        }
}
