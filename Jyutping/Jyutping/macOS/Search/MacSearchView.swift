#if os(macOS)

import SwiftUI
import Materials

struct MacSearchView: View {

        @State private var inputText: String = ""
        @State private var cantonese: String = ""
        @State private var pronunciations: [String] = []

        @State private var yingWaaEntries: [YingWaaFanWan] = []
        @State private var choHokEntries: [ChoHokYuetYamCitYiu] = []
        @State private var fanWanEntries: [FanWanCuetYiu] = []
        @State private var gwongWanEntries: [GwongWan] = []

        @State private var animationState: Int = 0
        @FocusState private var isTextFieldFocused: Bool

        var body: some View {
                ScrollView {
                        LazyVStack(spacing: 32) {
                                TextField("Search Pronunciation", text: $inputText)
                                        .textFieldStyle(.plain)
                                        .disableAutocorrection(true)
                                        .onSubmit {
                                                let trimmedInput: String = inputText.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .controlCharacters)
                                                guard trimmedInput != cantonese else { return }
                                                defer {
                                                        animationState += 1
                                                }
                                                guard !trimmedInput.isEmpty else {
                                                        cantonese = ""
                                                        pronunciations = []
                                                        yingWaaEntries = []
                                                        choHokEntries = []
                                                        fanWanEntries = []
                                                        gwongWanEntries = []
                                                        return
                                                }
                                                yingWaaEntries = AppMaster.lookupYingWaaFanWan(for: trimmedInput)
                                                choHokEntries = AppMaster.lookupChoHokYuetYamCitYiu(for: trimmedInput)
                                                fanWanEntries = AppMaster.lookupFanWanCuetYiu(for: trimmedInput)
                                                gwongWanEntries = AppMaster.lookupGwongWan(for: trimmedInput)
                                                let search = AppMaster.lookup(text: trimmedInput)
                                                if search.romanizations.isEmpty {
                                                        cantonese = trimmedInput
                                                        pronunciations = []
                                                } else {
                                                        cantonese = search.text
                                                        pronunciations = search.romanizations
                                                }
                                        }
                                        .focused($isTextFieldFocused)
                                        .padding(8)
                                        .background(Color.textBackgroundColor, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                                        .onAppear {
                                                isTextFieldFocused = true
                                        }
                                if !cantonese.isEmpty {
                                        CantoneseTextView(cantonese).block()
                                }
                                if !pronunciations.isEmpty {
                                        VStack {
                                                ForEach(0..<pronunciations.count, id: \.self) { index in
                                                        RomanizationLabelView(pronunciations[index])
                                                        if (index < pronunciations.count - 1) {
                                                                Divider()
                                                        }
                                                }
                                        }
                                        .block()
                                }
                                if !yingWaaEntries.isEmpty {
                                        VStack(spacing: 2) {
                                                HStack {
                                                        Text(verbatim: yingWaaEntries.first!.word)
                                                        Text(verbatim: "《英華分韻撮要》")
                                                        Text(verbatim: "衛三畏(Samuel Wells Williams)　1856　廣州").foregroundColor(.secondary)
                                                        Spacer()
                                                }
                                                .font(.copilot)
                                                VStack {
                                                        ForEach(0..<yingWaaEntries.count, id: \.self) { index in
                                                                YingWaaFanWanView(entry: yingWaaEntries[index])
                                                                if (index < yingWaaEntries.count - 1) {
                                                                        Divider()
                                                                }
                                                        }
                                                }
                                                .block()
                                        }
                                }
                                if !choHokEntries.isEmpty {
                                        VStack(spacing: 2) {
                                                HStack {
                                                        Text(verbatim: choHokEntries.first!.word)
                                                        Text(verbatim: "《初學粵音切要》")
                                                        Text(verbatim: "湛約翰(John Chalmers)　1855　香港").foregroundColor(.secondary)
                                                        Spacer()
                                                }
                                                .font(.copilot)
                                                VStack {
                                                        ForEach(0..<choHokEntries.count, id: \.self) { index in
                                                                ChoHokYuetYamCitYiuView(entry: choHokEntries[index])
                                                                if (index < choHokEntries.count - 1) {
                                                                        Divider()
                                                                }
                                                        }
                                                }
                                                .block()
                                        }
                                }
                                if !fanWanEntries.isEmpty {
                                        VStack(spacing: 2) {
                                                HStack {
                                                        Text(verbatim: fanWanEntries.first!.word)
                                                        Text(verbatim: "《分韻撮要》")
                                                        Text(verbatim: "佚名　約明末清初").foregroundColor(.secondary)
                                                        Spacer()
                                                }
                                                .font(.copilot)
                                                VStack {
                                                        ForEach(0..<fanWanEntries.count, id: \.self) { index in
                                                                FanWanCuetYiuView(entry: fanWanEntries[index])
                                                                if (index < fanWanEntries.count - 1) {
                                                                        Divider()
                                                                }
                                                        }
                                                }
                                                .block()
                                        }
                                }
                                if !gwongWanEntries.isEmpty {
                                        VStack(spacing: 2) {
                                                HStack {
                                                        Text(verbatim: gwongWanEntries.first!.word)
                                                        Text(verbatim: "《大宋重修廣韻》")
                                                        Spacer()
                                                }
                                                .font(.copilot)
                                                VStack {
                                                        ForEach(0..<gwongWanEntries.count, id: \.self) { index in
                                                                GwongWanView(entry: gwongWanEntries[index])
                                                                if (index < gwongWanEntries.count - 1) {
                                                                        Divider()
                                                                }
                                                        }
                                                }
                                                .block()
                                        }
                                }
                        }
                        .font(.master)
                        .textSelection(.enabled)
                        .padding()
                }
                .animation(.default, value: animationState)
                .navigationTitle("Search")
        }
}

#endif
