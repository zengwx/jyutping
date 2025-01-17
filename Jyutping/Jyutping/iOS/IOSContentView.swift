#if os(iOS)

import SwiftUI

struct IOSContentView: View {

        @State private var selection: Int = 0

        var body: some View {
                TabView(selection: $selection) {
                        HomeView()
                                .tabItem {
                                        Label("Home", systemImage: "house").environment(\.symbolVariants, .none)
                                }
                                .tag(0)

                        JyutpingView()
                                .tabItem {
                                        Label("Jyutping", systemImage: "doc.text.magnifyingglass").environment(\.symbolVariants, .none)
                                }
                                .tag(1)

                        CantoneseView()
                                .tabItem {
                                        Label("Cantonese", systemImage: "globe.asia.australia").environment(\.symbolVariants, .none)
                                }
                                .tag(2)

                        AboutView()
                                .tabItem {
                                        Label("About", systemImage: "info.circle").environment(\.symbolVariants, .none)
                                }
                                .tag(3)
                }
                .onAppear {
                        UITextField.appearance().clearButtonMode = .always
                }
        }
}

#endif
