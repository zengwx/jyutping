#if os(iOS)

import SwiftUI
import Materials

struct YingWaaFanWanLabel: View {
        let entry: YingWaaFanWan
        var body: some View {
                VStack(alignment: .leading) {
                        HStack {
                                Text(verbatim: "原文")
                                Text.separator
                                Text(verbatim: entry.pronunciation).font(.body)
                                if let pronunciationMark = entry.pronunciationMark {
                                        Text(verbatim: pronunciationMark).font(.footnote.italic())
                                }
                                if let interpretation = entry.interpretation {
                                        Text(verbatim: interpretation).font(.footnote)
                                }
                        }
                        HStack(spacing: 16) {
                                HStack {
                                        Text(verbatim: "轉寫")
                                        Text.separator
                                        Text(verbatim: entry.romanization).font(.fixedWidth)
                                }
                                Text(verbatim: entry.ipa).font(.body).foregroundStyle(Color.secondary)
                                Spacer()
                                Speaker(entry.jyutping).opacity(entry.romanization.isValidJyutping ? 1 : 0)
                        }
                }
                .font(.copilot)
        }
}

#endif
