#if os(macOS)

import SwiftUI

struct VisualEffect: NSViewRepresentable {
        func makeNSView(context: Self.Context) -> NSView {
                let view = NSVisualEffectView()
                view.material = .sidebar
                view.blendingMode = .behindWindow
                view.state = .active
                return view
        }
        func updateNSView(_ nsView: NSView, context: Context) { }
}
extension View {
        func visualEffect() -> some View {
                return self.background(VisualEffect())
        }
}

@available(macOS 13.0, *)
struct MacContentView: View {

        @State private var selection: ViewIdentifier = .search

        var body: some View {
                NavigationSplitView {
                        List(selection: $selection) {
                                Section {
                                        Label("Install Input Method", systemImage: "laptopcomputer.and.arrow.down").tag(ViewIdentifier.installation)
                                        Label("Introductions", systemImage: "book").tag(ViewIdentifier.introductions)
                                        Label("Cantonese Expressions", systemImage: "checkmark.seal").tag(ViewIdentifier.expressions)
                                        Label("Hans Mess", systemImage: "character").tag(ViewIdentifier.hansMess)
                                } header: {
                                        Text("Input Method").textCase(nil)
                                }
                                Section {
                                        Label("Search", systemImage: "magnifyingglass").tag(ViewIdentifier.search)
                                        Label("Initials", systemImage: "rectangle.leadingthird.inset.filled").tag(ViewIdentifier.initials)
                                        Label("Finals", systemImage: "rectangle.trailingthird.inset.filled").tag(ViewIdentifier.finals)
                                        Label("Tones", systemImage: "bell").tag(ViewIdentifier.tones)
                                } header: {
                                        Text("Jyutping").textCase(nil)
                                }
                                Section {
                                        Label("Numbers", systemImage: "number").tag(ViewIdentifier.numbers)
                                        Label("Stems and Branches", systemImage: "timelapse").tag(ViewIdentifier.stemsBranches)
                                        Label("Chinese Zodiac", systemImage: "hare").tag(ViewIdentifier.chineseZodiac)
                                        Label("Solar Terms", systemImage: "cloud.sun").tag(ViewIdentifier.solarTerms)
                                        Label("title.surnames", systemImage: "person").tag(ViewIdentifier.surnames)
                                        Label("title.characters", systemImage: "character").tag(ViewIdentifier.cinZiMan)
                                        Label("Canton Metro", systemImage: "tram.circle").tag(ViewIdentifier.cantonMetro)
                                        Label("Fatshan Metro", systemImage: "tram.circle").tag(ViewIdentifier.fatshanMetro)
                                        Label("Sham Chun Metro", systemImage: "tram.circle").tag(ViewIdentifier.shamchunMetro)
                                        Label("Hong Kong MTR", systemImage: "tram.circle").tag(ViewIdentifier.hongkongMTR)
                                } header: {
                                        Text("Cantonese").textCase(nil)
                                }
                                Section {
                                        Label("Resources", systemImage: "globe.asia.australia").tag(ViewIdentifier.resources)
                                        Label("About", systemImage: "info.circle").tag(ViewIdentifier.about)
                                } header: {
                                        Text("About").textCase(nil)
                                }
                        }
                        .toolbarBackground(Material.ultraThin, for: .windowToolbar)
                        .navigationTitle("Jyutping")
                } detail: {
                        switch selection {
                        case .installation:
                                MacInputMethodInstallationView().visualEffect()
                        case .introductions:
                                MacIntroductionsView().visualEffect()
                        case .expressions:
                                MacExpressionsView().visualEffect()
                        case .hansMess:
                                MacHansMessView().visualEffect()
                        case .search:
                                MacSearchView().visualEffect()
                        case .initials:
                                InitialTable().visualEffect()
                        case .finals:
                                FinalTable().visualEffect()
                        case .tones:
                                MacToneTableView().visualEffect()
                        case .numbers:
                                NumbersView().visualEffect()
                        case .stemsBranches:
                                StemsBranchesView().visualEffect()
                        case .chineseZodiac:
                                ChineseZodiacView().visualEffect()
                        case .solarTerms:
                                SolarTermsView().visualEffect()
                        case .surnames:
                                MacSurnamesView().visualEffect()
                        case .cinZiMan:
                                MacCinZiManView().visualEffect()
                        case .cantonMetro:
                                MacCantonMetroView().visualEffect()
                        case .fatshanMetro:
                                MacFatshanMetroView().visualEffect()
                        case .shamchunMetro:
                                MacShamChunMetroView().visualEffect()
                        case .hongkongMTR:
                                MacHongKongMTRView().visualEffect()
                        case .resources:
                                MacResourcesView().visualEffect()
                        case .about:
                                MacAboutView().visualEffect()
                        }
                }
        }
}

private enum ViewIdentifier: Int, Hashable, Identifiable {

        case installation
        case introductions
        case expressions
        case hansMess

        case search
        case initials
        case finals
        case tones

        case numbers
        case stemsBranches
        case chineseZodiac
        case solarTerms
        case surnames
        case cinZiMan
        case cantonMetro
        case fatshanMetro
        case shamchunMetro
        case hongkongMTR

        case resources
        case about

        var id: Int {
                return rawValue
        }
}

#endif
