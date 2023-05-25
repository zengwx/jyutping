import SwiftUI
import CoreIME

struct CandidateBoard: View {

        @EnvironmentObject private var context: KeyboardViewController

        private let collapseWidth: CGFloat = 44
        private let collapseHeight: CGFloat = 44

        private func rows(of candidates: [Candidate]) -> [[Candidate]] {
                let keyboardWidth: CGFloat = context.keyboardWidth
                var rows: [[Candidate]] = []
                var row: [Candidate] = []
                var rowWidth: CGFloat = 0
                for candidate in candidates {
                        let maxWidth: CGFloat = rows.isEmpty ? (keyboardWidth - collapseWidth) : keyboardWidth
                        let length: CGFloat = candidateWidth(of: candidate)
                        if rowWidth < (maxWidth - length) {
                                row.append(candidate)
                                rowWidth += length
                        } else {
                                rows.append(row)
                                row = [candidate]
                                rowWidth = length
                        }
                }
                return rows
        }
        private func candidateWidth(of candidate: Candidate) -> CGFloat {
                switch candidate.type {
                case .emoji, .symbol:
                        return 44
                default:
                        return CGFloat(candidate.text.count * 20 + 24)
                }
        }

        var body: some View {
                ZStack(alignment: .topTrailing) {
                        ScrollView(.vertical) {
                                LazyVStack(spacing: 0) {
                                        let candidateRows = rows(of: context.candidates)
                                        ForEach(0..<candidateRows.count, id: \.self) { index in
                                                let rowCandidates: [Candidate] = candidateRows[index]
                                                HStack(spacing: 0) {
                                                        ForEach(0..<rowCandidates.count, id: \.self) { deepIndex in
                                                                let candidate = rowCandidates[deepIndex]
                                                                ZStack {
                                                                        Color.interactiveClear
                                                                        VStack {
                                                                                Text(verbatim: candidate.isCantonese ? candidate.romanization : String.space)
                                                                                        .minimumScaleFactor(0.2)
                                                                                        .lineLimit(1)
                                                                                        .font(.romanization)
                                                                                Text(verbatim: candidate.text)
                                                                                        .lineLimit(1)
                                                                                        .font(.candidate)
                                                                        }
                                                                        .padding(4)
                                                                }
                                                                .frame(maxWidth: .infinity)
                                                                .contentShape(Rectangle())
                                                                .onTapGesture {
                                                                        AudioFeedback.inputed()
                                                                        context.triggerSelectionHapticFeedback()
                                                                        context.operate(.select(candidate))
                                                                }
                                                        }
                                                        if index == 0 {
                                                                Color.clear.frame(width: collapseWidth)
                                                        }
                                                }
                                                Divider()
                                        }
                                }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Image(systemName: "chevron.up")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .frame(width: collapseWidth, height: collapseHeight)
                                .background(Material.ultraThin, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                        AudioFeedback.modified()
                                        context.triggerHapticFeedback()
                                        context.updateKeyboardForm(to: context.previousKeyboardForm)
                                }
                }
        }
}