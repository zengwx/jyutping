import SwiftUI

extension Font {

        /// Font for Candidate text
        static let candidate: Font = {
                let primaryFontName: String = {
                        let preferredList: [String] = ["ChiuKong Gothic CL", "Source Han Sans K", "Noto Sans CJK KR"]
                        for name in preferredList {
                                if let font = NSFont(name: name, size: 17) {
                                        return name
                                }
                        }
                        return "PingFang HK"
                }()
                let fallbackFontNames: [String] = {
                        let expected: [String] = ["I.MingCP", "I.Ming", "HanaMinA", "HanaMinB"]
                        let results: [String?] = expected.map { name -> String? in
                                if let font = NSFont(name: name, size: 17) {
                                        return name
                                } else {
                                        return nil
                                }
                        }
                        let found: [String] = results.compactMap({ $0 })
                        return found
                }()
                if fallbackFontNames.isEmpty {
                        return Font.custom(primaryFontName, size: 17, relativeTo: .title2)
                } else {
                        return pairFonts(primary: primaryFontName, fallbacks: fallbackFontNames)
                }
        }()


        /// Font for Candidate serial number
        static let serialNumber: Font = {
                if let font_0 = NSFont(name: "JetBrains Mono", size: 14) {
                        return Font.custom("JetBrains Mono", size: 14, relativeTo: .title3)
                } else {
                        return Font.title3.monospaced()
                }
        }()
        static let comment: Font = Font.title3.monospaced()
        static let secondaryComment: Font = Font.body.monospaced()


        private static func pairFonts(primary name: String, fallbacks: [String]) -> Font {
                let fontSize: CGFloat = 17
                let originalFont: NSFont = NSFont(name: name, size: fontSize) ?? .systemFont(ofSize: fontSize)
                let originalDescriptor: NSFontDescriptor = originalFont.fontDescriptor
                let fallbackDescriptors: [NSFontDescriptor] = fallbacks.map { fontName -> NSFontDescriptor in
                        return originalDescriptor.addingAttributes([.name: fontName])
                }
                let repairedDescriptor: NSFontDescriptor = originalDescriptor.addingAttributes([.cascadeList : fallbackDescriptors])
                let pairedFont: NSFont = NSFont(descriptor: repairedDescriptor, size: fontSize) ?? .systemFont(ofSize: fontSize)
                return Font(pairedFont)
        }
}