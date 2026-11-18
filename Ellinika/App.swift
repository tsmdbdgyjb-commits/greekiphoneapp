import SwiftUI

@main
struct EllinikaApp: App {
    @State private var store = Store()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .tint(Theme.olive)
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            VocabView()
                .tabItem { Label("Vokabeln", systemImage: "rectangle.stack") }
            GrammarListView()
                .tabItem { Label("Grammatik", systemImage: "text.book.closed") }
            ConversationsView()
                .tabItem { Label("Gespräche", systemImage: "bubble.left.and.bubble.right") }
            AlphabetView()
                .tabItem { Label("Alphabet", systemImage: "textformat.abc") }
        }
    }
}
