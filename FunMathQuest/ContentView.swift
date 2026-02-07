import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
        .tint(Theme.accent)
    }
}

#Preview {
    ContentView()
        .environmentObject(ScoreStore.mock)
}
