import SwiftUI

@main
struct FunMathQuestApp: App {
    @StateObject private var scoreStore = ScoreStore()
    @StateObject private var languageStore = LanguageStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scoreStore)
                .environmentObject(languageStore)
                .environment(\.layoutDirection, languageStore.isHebrew ? .rightToLeft : .leftToRight)
        }
    }
}
