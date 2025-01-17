#if os(iOS)

import SwiftUI
import Materials

struct IOSCantonMetroView: View {

        @State private var lines: [Metro.Line] = []
        @State private var expanded: [Bool] = Array(repeating: false, count: 40)

        var body: some View {
                List {
                        Section {
                                HeaderTermView(term: Term(name: "廣州地鐵", romanization: "gwong2 zau1 dei6 tit3"))
                        }
                        ForEach(0..<lines.count, id: \.self) { index in
                                Section {
                                        IOSMetroLineView(line: lines[index], isExpanded: $expanded[index])
                                }
                        }
                }
                .animation(.default, value: expanded)
                .textSelection(.enabled)
                .task {
                        guard lines.isEmpty else { return }
                        lines = Metro.cantonMetroLines
                }
                .navigationTitle("Canton Metro")
                .navigationBarTitleDisplayMode(.inline)
        }
}

#endif
