struct PunctuationKey: Hashable {

        let keyText: String
        let shiftingKeyText: String
        let instantSymbol: String?
        let instantShiftingSymbol: String?
        let symbols: [PunctuationSymbol]
        let shiftingSymbols: [PunctuationSymbol]

        static let comma = PunctuationKey(keyText: ",", shiftingKeyText: "<", instantSymbol: "，", instantShiftingSymbol: nil, symbols: [.init("，")], shiftingSymbols: [.init("《 "), .init("〈"), .init("«"), .init("‹")])
        static let period = PunctuationKey(keyText: ".", shiftingKeyText: ">", instantSymbol: "。", instantShiftingSymbol: nil, symbols: [.init("，")], shiftingSymbols: [.init("》"), .init("〉"), .init("»"), .init("›")])
        static let slash: PunctuationKey = {
                let symbols: [PunctuationSymbol] = [
                        PunctuationSymbol("/", comment: "半形"),
                        PunctuationSymbol("／", comment: "全形"),
                        PunctuationSymbol("÷"),
                        PunctuationSymbol("？", comment: "全形"),
                        PunctuationSymbol("?", comment: "半形"),
                        PunctuationSymbol(String.fullWidthSpace, comment: "全形空格", secondaryComment: "U+3000")
                ]
                return PunctuationKey(keyText: "/", shiftingKeyText: "?", instantSymbol: nil, instantShiftingSymbol: "？", symbols: symbols, shiftingSymbols: [.init("？")])
        }()
        static let semicolon = PunctuationKey(keyText: ";", shiftingKeyText: ":", instantSymbol: "；", instantShiftingSymbol: "：", symbols: [.init("；")], shiftingSymbols: [.init("：")])
        static let bracketLeft: PunctuationKey = {
                let shiftingSymbols: [PunctuationSymbol] = [
                        PunctuationSymbol("『"),
                        PunctuationSymbol("【"),
                        PunctuationSymbol("〖"),
                        PunctuationSymbol("〔"),
                        PunctuationSymbol("［", comment: "全形"),
                        PunctuationSymbol("[", comment: "半形"),
                        PunctuationSymbol("｛", comment: "全形"),
                        PunctuationSymbol("{", comment: "半形")
                ]
                return PunctuationKey(keyText: "[", shiftingKeyText: "{", instantSymbol: "「", instantShiftingSymbol: nil, symbols: [.init("「")], shiftingSymbols: shiftingSymbols)
        }()
        static let bracketRight: PunctuationKey = {
                let shiftingSymbols: [PunctuationSymbol] = [
                        PunctuationSymbol("』"),
                        PunctuationSymbol("】"),
                        PunctuationSymbol("〗"),
                        PunctuationSymbol("〕"),
                        PunctuationSymbol("］", comment: "全形"),
                        PunctuationSymbol("]", comment: "半形"),
                        PunctuationSymbol("｝", comment: "全形"),
                        PunctuationSymbol("}", comment: "半形")
                ]
                return PunctuationKey(keyText: "]", shiftingKeyText: "}", instantSymbol: "」", instantShiftingSymbol: nil, symbols: [.init("」")], shiftingSymbols: shiftingSymbols)
        }()
        static let backSlash: PunctuationKey = {
                let shiftingSymbols: [PunctuationSymbol] = [
                        PunctuationSymbol("|", comment: "半形"),
                        PunctuationSymbol("｜", comment: "全形"),
                        PunctuationSymbol("\\", comment: "半形"),
                        PunctuationSymbol("＼", comment: "全形"),
                        PunctuationSymbol("•", comment: "Bullet", secondaryComment: "U+2022"),
                        PunctuationSymbol("·", comment: "陸標間隔號", secondaryComment: "Middle Dot, U+00B7"),
                        PunctuationSymbol("‧", comment: "港臺間隔號", secondaryComment: "U+2027"),
                        PunctuationSymbol("・", comment: "全形中點", secondaryComment: "U+30FB"),
                        PunctuationSymbol("°", comment: "度")
                ]
                return PunctuationKey(keyText: "\\", shiftingKeyText: "|", instantSymbol: "、", instantShiftingSymbol: nil, symbols: [.init("、")], shiftingSymbols: shiftingSymbols)
        }()
}


struct PunctuationSymbol: Hashable {

        let symbol: String
        let comment: String?
        let secondaryComment: String?

        init(_ symbol: String, comment: String? = nil, secondaryComment: String? = nil) {
                self.symbol = symbol
                self.comment = comment
                self.secondaryComment = secondaryComment
        }
}

