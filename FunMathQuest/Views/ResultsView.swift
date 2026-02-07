import SwiftUI

struct ResultsView: View {
    @EnvironmentObject private var scoreStore: ScoreStore
    @EnvironmentObject private var languageStore: LanguageStore

    @State private var showShareSheet = false
    @State private var shareImage: UIImage?

    var body: some View {
        ZStack {
            PlayfulBackground()

            if scoreStore.sessions.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        summarySection

                        ForEach(scoreStore.sessions) { session in
                            SessionRow(session: session) {
                                share(session)
                            }
                            .padding(12)
                            .background(Theme.card, in: RoundedRectangle(cornerRadius: 18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Theme.highlight.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle(languageStore.t(.dashboard))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(languageStore.t(.clear)) { scoreStore.clear() }
                    .foregroundStyle(.red)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(activityItems: [image])
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text(languageStore.t(.noScores))
                .font(Theme.titleFont(22))
                .foregroundStyle(Theme.ink)
            Text(languageStore.t(.playRound))
                .font(Theme.bodyFont(16))
                .foregroundStyle(.secondary)
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(languageStore.t(.latestScore))
                .font(Theme.titleFont(20))
                .foregroundStyle(Theme.ink)

            HStack(spacing: 12) {
                SummaryCard(
                    title: languageStore.t(.results),
                    value: "\(scoreStore.sessions.count)",
                    tint: Theme.modeBlue
                )
                SummaryCard(
                    title: languageStore.t(.accuracy),
                    value: averageAccuracyText,
                    tint: Theme.modeTeal
                )
                SummaryCard(
                    title: languageStore.t(.bestStreak),
                    value: "\(bestStreakOverall)",
                    tint: Theme.modeOrange
                )
            }
        }
    }

    private var averageAccuracyText: String {
        guard !scoreStore.sessions.isEmpty else { return "0%" }
        let totalCorrect = scoreStore.sessions.map(\.correctAnswers).reduce(0, +)
        let totalQuestions = scoreStore.sessions.map(\.totalQuestions).reduce(0, +)
        guard totalQuestions > 0 else { return "0%" }
        let percent = Double(totalCorrect) / Double(totalQuestions) * 100
        return String(format: "%.0f%%", percent)
    }

    private var bestStreakOverall: Int {
        scoreStore.sessions.map(\.bestStreak).max() ?? 0
    }

    private func share(_ session: SessionResult) {
        let card = ShareCard(session: session)
        let image = card.snapshotImage(size: CGSize(width: 320, height: 200))
        shareImage = image
        showShareSheet = true
    }
}

private struct SessionRow: View {
    let session: SessionResult
    let shareAction: () -> Void
    @EnvironmentObject private var languageStore: LanguageStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(modeTitle(session.mode, isHebrew: languageStore.isHebrew))
                .font(Theme.titleFont(18))
                .foregroundStyle(Theme.ink)

            Text("\(languageStore.t(.accuracy)): \(session.accuracyText) • \(languageStore.t(.bestStreak)): \(session.bestStreak) • \(languageStore.t(.time)): \(session.durationText)")
                .font(Theme.bodyFont(14))
                .foregroundStyle(.secondary)

            HStack {
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.bodyFont(12))
                    .foregroundStyle(.secondary)

                Spacer()

                Button(languageStore.t(.share)) { shareAction() }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.secondary)
            }
        }
        .padding(8)
    }
}

private struct ShareCard: View {
    let session: SessionResult
    @EnvironmentObject private var languageStore: LanguageStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(languageStore.t(.appTitle))
                .font(Theme.titleFont(20))
                .foregroundStyle(Theme.ink)

            Text(modeTitle(session.mode, isHebrew: languageStore.isHebrew))
                .font(Theme.bodyFont(16))

            HStack {
                StatBubble(label: languageStore.t(.accuracy), value: session.accuracyText)
                StatBubble(label: languageStore.t(.bestStreak), value: "\(session.bestStreak)")
                StatBubble(label: languageStore.t(.time), value: session.durationText)
            }

            Text(session.date.formatted(date: .abbreviated, time: .shortened))
                .font(Theme.bodyFont(12))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.highlight, lineWidth: 2)
        )
        .background(Color.clear)
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Theme.bodyFont(12))
                .foregroundStyle(.secondary)
            Text(value)
                .font(Theme.titleFont(18))
                .foregroundStyle(Theme.ink)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(tint.opacity(0.35), lineWidth: 1)
        )
    }
}

private struct StatBubble: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(Theme.bodyFont(10))
                .foregroundStyle(.secondary)
            Text(value)
                .font(Theme.titleFont(14))
        }
        .padding(8)
        .background(Theme.highlight.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
    }
}

private func modeTitle(_ mode: GameMode, isHebrew: Bool) -> String {
    if isHebrew {
        switch mode {
        case .table:
            return "טבלת כפל"
        case .by10:
            return "כפל ב־10"
        case .by100:
            return "כפל ב־100"
        case .by1000:
            return "כפל ב־1000"
        case .div10:
            return "חילוק ב־10"
        case .div100:
            return "חילוק ב־100"
        case .random:
            return "תרגולים אקראיים"
        }
    }
    return mode.rawValue
}

#Preview {
    ResultsView()
        .environmentObject(ScoreStore.mock)
        .environmentObject(LanguageStore())
}
