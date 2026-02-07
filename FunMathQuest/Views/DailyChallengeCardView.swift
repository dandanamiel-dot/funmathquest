import SwiftUI

/// Dashboard card showing daily challenge progress
struct DailyChallengeCardView: View {
    @EnvironmentObject private var challengeStore: DailyChallengeStore
    @EnvironmentObject private var languageStore: LanguageStore
    
    @State private var showCelebration = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(languageStore.t(.dailyChallenge))
                        .font(Theme.titleFont(18))
                        .foregroundStyle(Theme.ink)
                    Text(languageStore.t(.complete100Drills))
                        .font(Theme.bodyFont(12))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Stars badge
                StarsBadge(count: challengeStore.totalStars)
            }
            
            HStack(spacing: 20) {
                // Circular progress ring
                ProgressRing(
                    progress: challengeStore.progress,
                    current: challengeStore.drillsCompletedToday,
                    goal: challengeStore.dailyGoal
                )
                .frame(width: 80, height: 80)
                
                // Milestones
                VStack(alignment: .leading, spacing: 8) {
                    Text(languageStore.t(.todaysProgress))
                        .font(Theme.bodyFont(14))
                        .foregroundStyle(.secondary)
                    
                    MilestoneBar(
                        current: challengeStore.drillsCompletedToday,
                        goal: challengeStore.dailyGoal,
                        milestoneInterval: challengeStore.drillsPerMilestone
                    )
                    
                    Text(String(format: languageStore.t(.earn5StarsEvery10), challengeStore.starsPerMilestone, challengeStore.drillsPerMilestone))
                        .font(Theme.bodyFont(11))
                        .foregroundStyle(.secondary)
                }
            }
            
            // Completion button / status
            if challengeStore.isDailyComplete {
                Button {
                    showCelebration = true
                } label: {
                    HStack {
                        Image(systemName: "trophy.fill")
                        Text(languageStore.t(.challengeComplete))
                    }
                    .font(Theme.bodyFont(14))
                    .foregroundStyle(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(
                        LinearGradient(
                            colors: [Theme.highlight, Theme.modeOrange],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            LinearGradient(
                                colors: [Theme.highlight.opacity(0.5), Theme.modeOrange.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: Theme.highlight.opacity(0.2), radius: 12, x: 0, y: 6)
        .fullScreenCover(isPresented: $showCelebration) {
            ChallengeCompleteView()
                .environmentObject(challengeStore)
                .environmentObject(languageStore)
        }
    }
}

/// Circular progress ring with gradient
struct ProgressRing: View {
    let progress: Double
    let current: Int
    let goal: Int
    
    private let lineWidth: CGFloat = 10
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [Theme.modePink, Theme.modePurple, Theme.modeBlue, Theme.modeTeal],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6), value: progress)
            
            // Center text
            VStack(spacing: 0) {
                Text("\(current)")
                    .font(Theme.titleFont(22))
                    .foregroundStyle(Theme.ink)
                Text("/\(goal)")
                    .font(Theme.bodyFont(11))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Milestone progress bar with checkpoints
struct MilestoneBar: View {
    let current: Int
    let goal: Int
    let milestoneInterval: Int
    
    private var milestoneCount: Int {
        goal / milestoneInterval
    }
    
    private var reachedMilestones: Int {
        current / milestoneInterval
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<milestoneCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index < reachedMilestones ? Theme.highlight : Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .overlay {
                        if index < reachedMilestones {
                            Image(systemName: "star.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(.white)
                        }
                    }
            }
        }
    }
}

/// Golden stars badge with count
struct StarsBadge: View {
    let count: Int
    
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            AnimatedStar(size: 20)
            Text("\(count)")
                .font(Theme.titleFont(16))
                .foregroundStyle(Theme.ink)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.95, blue: 0.7), Color(red: 1.0, green: 0.88, blue: 0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Theme.highlight.opacity(0.4), radius: 4, y: 2)
        )
    }
}

#Preview {
    VStack {
        DailyChallengeCardView()
            .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.backgroundGradient)
    .environmentObject(DailyChallengeStore.mock)
    .environmentObject(LanguageStore())
}
