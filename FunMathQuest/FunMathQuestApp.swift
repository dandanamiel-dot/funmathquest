import SwiftUI

@main
struct FunMathQuestApp: App {
    @StateObject private var scoreStore = ScoreStore()
    @StateObject private var languageStore = LanguageStore()
    @StateObject private var challengeStore = DailyChallengeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scoreStore)
                .environmentObject(languageStore)
                .environmentObject(challengeStore)
                .environment(\.layoutDirection, languageStore.isHebrew ? .rightToLeft : .leftToRight)
        }
    }
}

