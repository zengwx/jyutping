import SwiftUI

extension Font {

        private(set) static var candidate: Font = candidateFont()
        static func updateCandidateFont() {
                candidate = candidateFont()
        }

        private static func candidateFont() -> Font {
                let size: CGFloat = AppSettings.candidateFontSize
                switch AppSettings.candidateFontMode {
                case .default:
                        return constructDefaultCandidateFont(size: size)
                case .system:
                        return Font.system(size: size)
                case .custom:
                        let names: [String] = AppSettings.customCandidateFonts
                        let primary: String? = names.first
                        let fallbacks: [String] = Array<String>(names.dropFirst())
                        return customCandidateFont(primary: primary, fallbacks: fallbacks, size: size)
                }
        }
        private static func customCandidateFont(primary: String?, fallbacks: [String], size: CGFloat) -> Font {
                guard let primary else { return constructDefaultCandidateFont(size: size) }
                guard found(font: primary) else { return constructDefaultCandidateFont(size: size) }
                let foundFallbacks: [String] = {
                        guard !(fallbacks.isEmpty) else { return [] }
                        var available: [String] = []
                        for name in fallbacks where name != primary {
                                if found(font: name) {
                                        available.append(name)
                                }
                        }
                        return available.uniqued()
                }()
                guard !(foundFallbacks.isEmpty) else { return Font.custom(primary, size: size) }
                return combineFonts(primary: primary, fallbacks: foundFallbacks, size: size) ?? Font.custom(primary, size: size)
        }
        private static func constructDefaultCandidateFont(size: CGFloat) -> Font {
                let isSFProAvailable: Bool = found(font: Constant.SFPro)
                let primary: String = isSFProAvailable ? Constant.SFPro : Constant.HelveticaNeue
                let fallbacks: [String] = {
                        var list: [String] = isSFProAvailable ? [Constant.HelveticaNeue] : []
                        let firstWave: [String] = ["ChiuKong Gothic CL", "Advocate Ancient Sans", "Source Han Sans K", "Noto Sans CJK KR", "Sarasa Gothic CL"]
                        for name in firstWave {
                                if found(font: name) {
                                        list.append(name)
                                        break
                                }
                        }
                        list.append(Constant.PingFangHK)
                        let planFonts: [String] = ["Plangothic P1", "Plangothic P2"]
                        for name in planFonts {
                                if found(font: name) {
                                        list.append(name)
                                }
                        }
                        let IMingFonts: [String] = [Constant.IMingCP, Constant.IMing]
                        for name in IMingFonts {
                                if found(font: name) {
                                        list.append(name)
                                        break
                                }
                        }
                        if found(font: Constant.HanaMinB) {
                                list.append(Constant.HanaMinB)
                        }
                        return list
                }()
                let shouldUseSystemFont: Bool = fallbacks == [Constant.PingFangHK]
                guard !shouldUseSystemFont else { return Font.system(size: size) }
                return combineFonts(primary: primary, fallbacks: fallbacks, size: size) ?? Font.system(size: size)
        }
}

extension Font {

        private(set) static var comment: Font = commentFont(size: AppSettings.commentFontSize)
        private(set) static var commentTone: Font = {
                let toneFontSize: CGFloat = AppSettings.commentFontSize - 4
                return commentFont(size: toneFontSize)
        }()
        static func updateCommentFont() {
                let commentFontSize: CGFloat = AppSettings.commentFontSize
                let toneFontSize: CGFloat = commentFontSize - 4
                comment = commentFont(size: commentFontSize)
                commentTone = commentFont(size: toneFontSize)
        }

        private static func commentFont(size: CGFloat) -> Font {
                switch AppSettings.commentFontMode {
                case .default:
                        return constructDefaultCommentFont(size: size)
                case .system:
                        return Font.system(size: size)
                case .custom:
                        let names: [String] = AppSettings.customCommentFonts
                        let primary: String? = names.first
                        let fallbacks: [String] = Array<String>(names.dropFirst())
                        return customCommentFont(primary: primary, fallbacks: fallbacks, size: size)
                }
        }
        private static func customCommentFont(primary: String?, fallbacks: [String], size: CGFloat) -> Font {
                guard let primary else { return constructDefaultCommentFont(size: size) }
                guard found(font: primary) else { return constructDefaultCommentFont(size: size) }
                let foundFallbacks: [String] = {
                        guard !(fallbacks.isEmpty) else { return [] }
                        var available: [String] = []
                        for name in fallbacks where name != primary {
                                if found(font: name) {
                                        available.append(name)
                                }
                        }
                        return available.uniqued()
                }()
                guard !(foundFallbacks.isEmpty) else { return Font.custom(primary, size: size) }
                return combineFonts(primary: primary, fallbacks: foundFallbacks, size: size) ?? Font.custom(primary, size: size)
        }
        private static func constructDefaultCommentFont(size: CGFloat) -> Font {
                lazy var fallback: Font = Font.system(size: size, design: .monospaced)
                let isSFMonoAvailable: Bool = found(font: Constant.SFMono)
                guard isSFMonoAvailable else { return fallback }
                let primary: String = Constant.SFMono
                let fallbacks: [String] = {
                        let isSFProAvailable: Bool = found(font: Constant.SFPro)
                        var list: [String] = isSFProAvailable ? [Constant.SFPro, Constant.HelveticaNeue] : [Constant.HelveticaNeue]
                        let firstWave: [String] = ["ChiuKong Gothic CL", "Advocate Ancient Sans", "Source Han Sans K", "Noto Sans CJK KR", "Sarasa Gothic CL"]
                        for name in firstWave {
                                if found(font: name) {
                                        list.append(name)
                                        break
                                }
                        }
                        list.append(Constant.PingFangHK)
                        let planFonts: [String] = ["Plangothic P1", "Plangothic P2"]
                        for name in planFonts {
                                if found(font: name) {
                                        list.append(name)
                                }
                        }
                        let IMingFonts: [String] = [Constant.IMingCP, Constant.IMing]
                        for name in IMingFonts {
                                if found(font: name) {
                                        list.append(name)
                                        break
                                }
                        }
                        if found(font: Constant.HanaMinB) {
                                list.append(Constant.HanaMinB)
                        }
                        return list
                }()
                let shouldFallback: Bool = fallbacks.count == 2
                guard !shouldFallback else { return fallback }
                return combineFonts(primary: primary, fallbacks: fallbacks, size: size) ?? fallback
        }
}

extension Font {

        private(set) static var label: Font = labelFont(size: AppSettings.labelFontSize)
        private(set) static var labelDot: Font = Font.system(size: AppSettings.labelFontSize)
        static func updateLabelFont() {
                let size: CGFloat = AppSettings.labelFontSize
                label = labelFont(size: size)
                labelDot = Font.system(size: size)
        }
        private static func labelFont(size: CGFloat) -> Font {
                switch AppSettings.labelFontMode {
                case .default:
                        return Font.system(size: size).monospacedDigit()
                case .system:
                        return Font.system(size: size).monospacedDigit()
                case .custom:
                        let names: [String] = AppSettings.customLabelFonts
                        let primary: String? = names.first
                        let fallbacks: [String] = Array<String>(names.dropFirst())
                        return customLabelFont(primary: primary, fallbacks: fallbacks, size: size)
                }
        }
        private static func customLabelFont(primary: String?, fallbacks: [String], size: CGFloat) -> Font {
                lazy var fallback: Font = Font.system(size: size).monospacedDigit()
                guard let primary else { return fallback }
                guard found(font: primary) else { return fallback }
                let foundFallbacks: [String] = {
                        guard !(fallbacks.isEmpty) else { return [] }
                        var available: [String] = []
                        for name in fallbacks where name != primary {
                                if found(font: name) {
                                        available.append(name)
                                }
                        }
                        return available.uniqued()
                }()
                guard !(foundFallbacks.isEmpty) else { return Font.custom(primary, size: size) }
                return combineFonts(primary: primary, fallbacks: foundFallbacks, size: size) ?? Font.custom(primary, size: size)
        }
}

private extension Font {

        static func found(font fontName: String) -> Bool {
                return NSFont(name: fontName, size: 15) != nil
        }

        /// Combining multiple fonts
        /// - Parameters:
        ///   - primary: Primary font name
        ///   - fallbacks: Fallback font names
        ///   - size: Font size
        /// - Returns: Font?
        static func combineFonts(primary: String, fallbacks: [String], size: CGFloat) -> Font? {
                guard let primaryFont: NSFont = NSFont(name: primary, size: size) else { return nil }
                let primaryDescriptor: NSFontDescriptor = primaryFont.fontDescriptor
                let fallbackDescriptors: [NSFontDescriptor] = fallbacks.map { fontName -> NSFontDescriptor in
                        return primaryDescriptor.addingAttributes([.name: fontName])
                }
                let combinedDescriptor: NSFontDescriptor = primaryDescriptor.addingAttributes([.cascadeList : fallbackDescriptors])
                guard let combinedFont: NSFont = NSFont(descriptor: combinedDescriptor, size: size) else { return nil }
                return Font(combinedFont)
        }
}
