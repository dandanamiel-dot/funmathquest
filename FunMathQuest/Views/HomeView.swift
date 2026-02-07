import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var scoreStore: ScoreStore
    @EnvironmentObject private var languageStore: LanguageStore
    @EnvironmentObject private var challengeStore: DailyChallengeStore

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            PlayfulBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    
                    // Mascot greeting
                    HStack {
                        Spacer()
                        MascotView(mood: .waving, message: greetingMessage, size: 100)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    // Daily Challenge Card
                    DailyChallengeCardView()

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(GameMode.allCases) { mode in
                            if mode.isDrill {
                                NavigationLink {
                                    DrillView(mode: mode)
                                } label: {
                                    ModeCard(
                                        mode: mode,
                                        title: modeTitle(mode),
                                        subtitle: modeDescription(mode),
                                        startLabel: languageStore.t(.start)
                                    )
                                }
                            } else {
                                NavigationLink {
                                    TableView()
                                } label: {
                                    ModeCard(
                                        mode: mode,
                                        title: modeTitle(mode),
                                        subtitle: modeDescription(mode),
                                        startLabel: languageStore.t(.start)
                                    )
                                }
                            }
                        }
                    }

                    resultsCard
                }
                .padding(20)
            }
        }
    }
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if languageStore.isHebrew {
            if hour < 12 {
                return "בוקר טוב! 🌞"
            } else if hour < 18 {
                return "צהריים טובים! ☀️"
            } else {
                return "ערב טוב! 🌙"
            }
        } else {
            if hour < 12 {
                return "Good morning! 🌞"
            } else if hour < 18 {
                return "Good afternoon! ☀️"
            } else {
                return "Good evening! 🌙"
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(languageStore.t(.appTitle))
                    .font(Theme.titleFont(34))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Menu {
                    Button(languageStore.t(.english)) {
                        languageStore.language = .english
                    }
                    Button(languageStore.t(.hebrew)) {
                        languageStore.language = .hebrew
                    }
                } label: {
                    Text(languageStore.isHebrew ? "🇮🇱" : "🇺🇸")
                        .font(.system(size: 18))
                        .frame(width: 32, height: 32)
                        .background(Theme.card, in: Circle())
                        .overlay(
                            Circle()
                                .stroke(Theme.highlight.opacity(0.4), lineWidth: 1)
                        )
                }
                .accessibilityLabel(languageStore.t(.language))
            }
            Text(languageStore.t(.tagline))
                .font(Theme.bodyFont(18))
                .foregroundStyle(.secondary)
        }
    }

    private var resultsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(languageStore.t(.latestScore))
                .font(Theme.titleFont(20))
                .foregroundStyle(Theme.ink)

            if let latest = scoreStore.sessions.first {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(modeTitle(latest.mode))
                            .font(Theme.bodyFont(16))
                        Text("\(languageStore.t(.accuracy)): \(latest.accuracyText) • \(languageStore.t(.bestStreak)): \(latest.bestStreak)")
                            .font(Theme.bodyFont(14))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            } else {
                Text(languageStore.t(.playRound))
                    .font(Theme.bodyFont(15))
                    .foregroundStyle(.secondary)
            }

            NavigationLink {
                ResultsView()
            } label: {
                HStack {
                    Text(languageStore.t(.openDashboard))
                        .font(Theme.bodyFont(15))
                    Spacer()
                    Image(systemName: "chart.bar.xaxis")
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Theme.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    private func modeTitle(_ mode: GameMode) -> String {
        if languageStore.isHebrew {
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

    private func modeDescription(_ mode: GameMode) -> String {
        if languageStore.isHebrew {
            switch mode {
            case .table:
                return "למדו את לוח הכפל 1–12 בגריד צבעוני."
            case .by10:
                return "תרגול כפל במספר 10."
            case .by100:
                return "תרגול כפל במספר 100."
            case .by1000:
                return "תרגול כפל במספר 1000."
            case .div10:
                return "תרגול חילוק ב־10 עם תוצאות שלמות."
            case .div100:
                return "תרגול חילוק ב־100 עם תוצאות שלמות."
            case .random:
                return "שאלות כפל אקראיות וקצביות."
            }
        }
        return mode.description
    }
}

private struct ModeCard: View {
    let mode: GameMode
    let title: String
    let subtitle: String
    let startLabel: String
    
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(mode.tint.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: mode.iconName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(mode.tint)
                }
                Spacer()
                Text(startLabel)
                    .font(Theme.bodyFont(13))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(mode.tint.opacity(0.15))
                    .foregroundStyle(mode.tint)
                    .clipShape(Capsule())
            }

            Text(title)
                .font(Theme.titleFont(18))
                .foregroundStyle(Theme.ink)

            Text(subtitle)
                .font(Theme.bodyFont(13))
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer()
        }
        .padding(16)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [mode.tint.opacity(0.4), mode.tint.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: mode.tint.opacity(0.2), radius: 12, x: 0, y: 6)
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.3), value: isPressed)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(ScoreStore.mock)
            .environmentObject(LanguageStore())
            .environmentObject(DailyChallengeStore.mock)
    }
}

