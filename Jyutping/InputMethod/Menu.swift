import SwiftUI
import InputMethodKit

extension JyutpingInputController {

        override func menu() -> NSMenu! {
                let menuTitle: String = NSLocalizedString("menu.title", comment: "")
                let menu = NSMenu(title: menuTitle)

                let cantoneseModeTitle: String = NSLocalizedString("menu.mode.cantonese", comment: "")
                let abcModeTitle: String = NSLocalizedString("menu.mode.abc", comment: "")
                let cantoneseMode = NSMenuItem(title: cantoneseModeTitle, action: #selector(toggleInputMethodMode), keyEquivalent: "")
                let abcMode = NSMenuItem(title: abcModeTitle, action: #selector(toggleInputMethodMode), keyEquivalent: "")
                cantoneseMode.state = Options.inputMethodMode.isCantonese ? .on : .off
                abcMode.state = Options.inputMethodMode.isABC ? .on : .off
                menu.addItem(cantoneseMode)
                menu.addItem(abcMode)

                menu.addItem(.separator())

                let preferencesTitle: String = NSLocalizedString("menu.preferences", comment: "")
                let preferences = NSMenuItem(title: preferencesTitle, action: #selector(openPreferencesWindow), keyEquivalent: ",")
                preferences.keyEquivalentModifierMask = [.control, .shift]
                menu.addItem(preferences)

                let check4updatesTitle: String = NSLocalizedString("menu.check4updates", comment: "")
                let check4updates = NSMenuItem(title: check4updatesTitle, action: #selector(checkForUpdates), keyEquivalent: "")
                menu.addItem(check4updates)

                let helpTitle: String = NSLocalizedString("menu.help", comment: "")
                let help = NSMenuItem(title: helpTitle, action: #selector(openHelpWindow), keyEquivalent: "")
                menu.addItem(help)

                let aboutTitle: String = NSLocalizedString("menu.about", comment: "")
                let about = NSMenuItem(title: aboutTitle, action: #selector(openAboutWindow), keyEquivalent: "")
                menu.addItem(about)

                menu.addItem(.separator())

                let terminateTitle: String = NSLocalizedString("menu.terminate", comment: "")
                let terminate = NSMenuItem(title: terminateTitle, action: #selector(terminateApp), keyEquivalent: "")
                menu.addItem(terminate)

                return menu
        }

        @objc private func toggleInputMethodMode() {
                let newMode: InputMethodMode = Options.inputMethodMode.isCantonese ? .abc : .cantonese
                Options.updateInputMethodMode(to: newMode)
                appContext.updateInputForm()
        }

        @objc private func openPreferencesWindow() {
                Options.updateSelectedPreferencesRow(to: .layouts)
                displayPreferencesView()
        }
        @objc private func openHelpWindow() {
                Options.updateSelectedPreferencesRow(to: .hotkeys)
                displayPreferencesView()
        }
        @objc private func openAboutWindow() {
                Options.updateSelectedPreferencesRow(to: .about)
                displayPreferencesView()
        }
        private func displayPreferencesView() {
                let shouldOpenNewWindow: Bool = NSApp.windows.filter({ $0.identifier?.rawValue == Constant.preferencesWindowIdentifier }).isEmpty
                guard shouldOpenNewWindow else { return }
                let frame: CGRect = preferencesWindowFrame()
                let window = NSWindow(contentRect: frame, styleMask: [.titled, .closable, .resizable, .fullSizeContentView], backing: .buffered, defer: true)
                window.identifier = NSUserInterfaceItemIdentifier(rawValue: Constant.preferencesWindowIdentifier)
                window.title = NSLocalizedString("Jyutping Input Method Preferences", comment: "")
                let visualEffectView = NSVisualEffectView()
                visualEffectView.material = .sidebar
                visualEffectView.blendingMode = .behindWindow
                visualEffectView.state = .active
                window.contentView = visualEffectView
                let preferencesUI = NSHostingController(rootView: PreferencesView())
                window.contentView?.addSubview(preferencesUI.view)
                preferencesUI.view.translatesAutoresizingMaskIntoConstraints = false
                if let topAnchor = window.contentView?.topAnchor,
                   let bottomAnchor = window.contentView?.bottomAnchor,
                   let leadingAnchor = window.contentView?.leadingAnchor,
                   let trailingAnchor = window.contentView?.trailingAnchor {
                        NSLayoutConstraint.activate([
                                preferencesUI.view.topAnchor.constraint(equalTo: topAnchor),
                                preferencesUI.view.bottomAnchor.constraint(equalTo: bottomAnchor),
                                preferencesUI.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                                preferencesUI.view.trailingAnchor.constraint(equalTo: trailingAnchor)
                        ])
                }
                window.contentViewController?.addChild(preferencesUI)
                window.orderFrontRegardless()
                window.setFrame(frame, display: true)
                NSApp.activate(ignoringOtherApps: true)
        }
        private func preferencesWindowFrame() -> CGRect {
                let screenWidth: CGFloat = NSScreen.main?.frame.size.width ?? 1920
                let screenHeight: CGFloat = NSScreen.main?.frame.size.height ?? 1080
                let x: CGFloat = screenWidth / 4.0
                let y: CGFloat = screenHeight / 5.0
                let width: CGFloat = screenWidth / 2.0
                let height: CGFloat = (screenHeight / 5.0) * 3.0
                return CGRect(x: x, y: y, width: width, height: height)
        }

        @objc private func terminateApp() {
                switchInputSource()
                NSRunningApplication.current.terminate()
                NSApp.terminate(self)
                exit(0)
        }
        private func switchInputSource() {
                guard let inputSourceList = TISCreateInputSourceList(nil, true).takeRetainedValue() as? [TISInputSource] else { return }
                for inputSource in inputSourceList {
                        if shouldSelect(inputSource) {
                                TISSelectInputSource(inputSource)
                                break
                        }
                }
        }
        private func shouldSelect(_ inputSource: TISInputSource) -> Bool {
                guard let pointer2ID = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID) else { return false }
                let inputSourceID = Unmanaged<CFString>.fromOpaque(pointer2ID).takeUnretainedValue() as String
                guard inputSourceID.hasPrefix("com.apple.keylayout") else { return false }
                guard let pointer2IsSelectable = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceIsSelectCapable) else { return false }
                let isSelectable = Unmanaged<CFBoolean>.fromOpaque(pointer2IsSelectable).takeRetainedValue()
                return CFBooleanGetValue(isSelectable)
        }
}
