import Foundation
import SQLite3

/// Core IME Engine
public struct Lychee {

        /// SQLite3 database
        private(set) static var database: OpaquePointer? = {
                guard let path: String = Bundle.module.path(forResource: "lexicon", ofType: "sqlite3") else { return nil }
                var db: OpaquePointer?
                if sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK {
                        return db
                } else {
                        return nil
                }
        }()

        /// Connect SQLite3 database
        public static func connect() {
                guard let path: String = Bundle.module.path(forResource: "lexicon", ofType: "sqlite3") else { return }
                var db: OpaquePointer?
                if sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK {
                        database = db
                }
        }

        /// Close SQLite3 database
        public static func close() {
                sqlite3_close_v2(database)
        }
}


extension Lychee {

        public static func searchEmojis(for text: String) -> [Candidate] {
                var candidates: [Candidate] = []
                // TODO: improve ping text
                let queryString = "SELECT emoji, cantonese, romanization FROM emojitable WHERE ping = \(text.hash);"
                var queryStatement: OpaquePointer? = nil
                defer {
                        sqlite3_finalize(queryStatement)
                }
                if sqlite3_prepare_v2(Lychee.database, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                let emojiCodeText: String = String(cString: sqlite3_column_text(queryStatement, 0))
                                let cantonese: String = String(cString: sqlite3_column_text(queryStatement, 1))
                                let romanization: String = String(cString: sqlite3_column_text(queryStatement, 2))
                                if let emoji: String = transform(codes: emojiCodeText) {
                                        let instance = Candidate(emoji: emoji, cantonese: cantonese, romanization: romanization, input: text)
                                        candidates.append(instance)
                                }
                        }
                }
                return candidates
        }
        private static func transform(codes: String) -> String? {
                let blocks: [String] = codes.components(separatedBy: ".")
                switch blocks.count {
                case 0, 1:
                        guard let character = character(from: codes) else { return nil }
                        return String(character)
                default:
                        let characters = blocks.map({ character(from: $0) })
                        let found = characters.compactMap({ $0 })
                        guard found.count == characters.count else { return nil }
                        return String(found)
                }
        }
        /// Create a Character from the given Unicode Code Point String, e.g. 1F600
        private static func character(from codePoint: String) -> Character? {
                guard let u32 = UInt32(codePoint, radix: 16) else { return nil }
                guard let scalar = Unicode.Scalar(u32) else { return nil }
                return Character(scalar)
        }
}


extension Lychee {


        /// Search special mark for text
        /// - Parameter text: Input text
        /// - Returns: Candidate, type == .specialMark
        public static func searchMark(for text: String) -> Candidate? {
                let key: String = text.lowercased()
                guard let markText = specialMarks[key] else { return nil }
                return Candidate(mark: markText)
        }

        private static let specialMarks: [String: String] = {
                let values: [String] = [
                        "iOS",
                        "iPadOS",
                        "macOS",
                        "watchOS",
                        "tvOS",
                        "iPhone",
                        "iPad",
                        "iPod",
                        "iMac",
                        "MacBook",
                        "HomePod",
                        "AirPods",
                        "AirTag",
                        "iCloud",
                        "FaceTime",
                        "iMessage",
                        "SwiftUI",
                        "GitHub",
                        "PayPal",
                        "WhatsApp",
                        "YouTube",
                        "Canton",
                        "Cantonese",
                        "Cantonia"
                ]
                let keys: [String] = values.map({ $0.lowercased() })
                let dict: [String: String] = Dictionary(uniqueKeysWithValues: zip(keys, values))
                return dict
        }()
}

