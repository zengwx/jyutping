import Foundation
import SQLite3
import CoreIME

struct UserLexicon {

        private static var database: OpaquePointer? = nil

        static func prepare() {
                guard database == nil else { return }
                guard let libraryDirectoryUrl: URL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { return }
                let userLexiconUrl: URL = libraryDirectoryUrl.appendingPathComponent("userlexicon.sqlite3", isDirectory: false)
                if sqlite3_open_v2(userLexiconUrl.path, &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK {
                        ensureTable()
                }
        }
        private static func ensureTable() {
                let command = "CREATE TABLE IF NOT EXISTS lexicon(id INTEGER NOT NULL PRIMARY KEY,input INTEGER NOT NULL,ping INTEGER NOT NULL,prefix INTEGER NOT NULL,shortcut INTEGER NOT NULL,frequency INTEGER NOT NULL,word TEXT NOT NULL,jyutping TEXT NOT NULL);"
                var statement: OpaquePointer? = nil
                if sqlite3_prepare_v2(database, command, -1, &statement, nil) == SQLITE_OK {
                        if sqlite3_step(statement) == SQLITE_DONE {}
                }
                sqlite3_finalize(statement)
        }


        // MARK: - Handle Candidate

        static func handle(_ candidate: Candidate) {
                let id: Int64 = Int64((candidate.lexiconText + candidate.romanization).hash)
                if let frequency: Int64 = find(by: id) {
                        update(id: id, frequency: frequency + 1)
                } else {
                        let jyutping: String = candidate.romanization
                        let newEntry: LexiconEntry = LexiconEntry(id: id,
                                                                  input: Int64(candidate.input.hash),
                                                                  ping: jyutping.ping,
                                                                  prefix: jyutping.prefix,
                                                                  shortcut: jyutping.shortcut,
                                                                  frequency: 1,
                                                                  word: candidate.lexiconText,
                                                                  jyutping: jyutping)
                        insert(entry: newEntry)
                }
        }
        private static func find(by id: Int64) -> Int64? {
                let queryStatementString = "SELECT frequency FROM lexicon WHERE id = \(id) LIMIT 1;"
                var queryStatement: OpaquePointer? = nil
                var frequency: Int64?
                if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                frequency = sqlite3_column_int64(queryStatement, 0)
                        }
                }
                sqlite3_finalize(queryStatement)
                return frequency
        }
        private static func update(id: Int64, frequency: Int64) {
                let updateStatementString = "UPDATE lexicon SET frequency = \(frequency) WHERE id = \(id);"
                var updateStatement: OpaquePointer?
                if sqlite3_prepare_v2(database, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
                        if sqlite3_step(updateStatement) == SQLITE_DONE {}
                }
                sqlite3_finalize(updateStatement)
        }
        private static func insert(entry: LexiconEntry) {
                let command: String = "INSERT INTO lexicon (id, input, ping, prefix, shortcut, frequency, word, jyutping) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
                var statement: OpaquePointer? = nil
                defer { sqlite3_finalize(statement) }
                guard sqlite3_prepare_v2(database, command, -1, &statement, nil) == SQLITE_OK else { return }

                sqlite3_bind_int64(statement, 1, entry.id)
                sqlite3_bind_int64(statement, 2, entry.input)
                sqlite3_bind_int64(statement, 3, entry.ping)
                sqlite3_bind_int64(statement, 4, entry.prefix)
                sqlite3_bind_int64(statement, 5, entry.shortcut)
                sqlite3_bind_int64(statement, 6, entry.frequency)
                sqlite3_bind_text(statement, 7, (entry.word as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 8, (entry.jyutping as NSString).utf8String, -1, nil)

                guard sqlite3_step(statement) == SQLITE_DONE else { return }
        }


        // MARK: - Suggestion

        static func suggest(for text: String) -> [Candidate] {
                let regularMatch = match(text: text, isShortcut: false)
                let regularShortcut = match(text: text, isShortcut: true)
                let convertedText: String = text.replacingOccurrences(of: "eo(ng|k)$", with: "oe$1", options: .regularExpression)
                        .replacingOccurrences(of: "oe(i|n|t)$", with: "eo$1", options: .regularExpression)
                        .replacingOccurrences(of: "eung$", with: "oeng", options: .regularExpression)
                        .replacingOccurrences(of: "(u|o)m$", with: "am", options: .regularExpression)
                        .replacingOccurrences(of: "^(ng|gw|kw|[b-z])?a$", with: "$1aa", options: .regularExpression)
                        .replacingOccurrences(of: "^y(u|un|ut)$", with: "jy$1", options: .regularExpression)
                        .replacingOccurrences(of: "y", with: "j", options: .anchored)
                let anotherMatch = match(text: convertedText, isShortcut: false)
                let anotherShortcut = match(text: convertedText, isShortcut: true)
                return regularMatch + regularShortcut + anotherMatch + anotherShortcut
        }
        private static func match(text: String, isShortcut: Bool) -> [Candidate] {
                var candidates: [Candidate] = []
                let code: Int = isShortcut ? text.replacingOccurrences(of: "y", with: "j").hash : text.hash
                let column: String = isShortcut ? "shortcut" : "ping"
                let queryStatementString = "SELECT word, jyutping FROM lexicon WHERE \(column) = \(code) ORDER BY frequency DESC LIMIT 5;"
                var queryStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                let word = String(cString: sqlite3_column_text(queryStatement, 0))
                                let jyutping = String(cString: sqlite3_column_text(queryStatement, 1))
                                let candidate: Candidate = Candidate(text: word, romanization: jyutping, input: text, lexiconText: word)
                                candidates.append(candidate)
                        }
                }
                sqlite3_finalize(queryStatement)
                return candidates
        }


        // MARK: - Clear User Lexicon

        static func deleteAll() {
                let deleteStatementString = "DELETE FROM lexicon;"
                var deleteStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(database, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
                        if sqlite3_step(deleteStatement) == SQLITE_DONE {}
                }
                sqlite3_finalize(deleteStatement)
        }
}

private struct LexiconEntry {

        /// (Candidate.lexiconText + Candidate.jyutping).hash
        let id: Int64

        /// input.hash
        let input: Int64

        /// jyutping.withoutTonesAndSpaces.hash
        let ping: Int64

        /// jyutping.prefix.hash
        let prefix: Int64

        /// jyutping.initials.hash
        let shortcut: Int64

        let frequency: Int64

        /// Candidate.lexiconText
        let word: String

        let jyutping: String
}
