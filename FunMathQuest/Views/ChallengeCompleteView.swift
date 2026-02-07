import SwiftUI

/// Full-screen celebration when daily challenge is complete
struct ChallengeCompleteView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var challengeStore: DailyChallengeStore
    @EnvironmentObject private var languageStore: LanguageStore
    
    @State private var showConfetti = false
    @State private var showContent = false
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.5, blue: 0.95),
                    Color(red: 0.8, green: 0.6, blue: 0.95),
                    Color(red: 0.95, green: 0.8, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Confetti
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
            
            // Main content
            VStack(spacing: 24) {
                Spacer()
                
                // Trophy
                TrophyView()
                    .frame(width: 150, height: 170)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)
                
                // Title
                Text(languageStore.t(.dailyChallengeComplete))
                    .font(Theme.titleFont(28))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .opacity(showContent ? 1 : 0)
                
                // Mascot
                MascotView(mood: .excited, message: languageStore.t(.youAreMathChampion), size: 100)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .opacity(showContent ? 1 : 0)
                
                // Stars earned
                HStack(spacing: 8) {
                    AnimatedStar(size: 30)
                    Text("\(challengeStore.maxDailyStars) \(languageStore.t(.starsEarned))")
                        .font(Theme.titleFont(20))
                        .foregroundStyle(.white)
                    AnimatedStar(size: 30)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.4), lineWidth: 2)
                        )
                )
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    // Share button
                    Button {
                        shareAchievement()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text(languageStore.t(.shareAchievement))
                        }
                        .font(Theme.bodyFont(16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 32)
                        .background(
                            LinearGradient(
                                colors: [Theme.modePink, Theme.modePurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                    }
                    
                    // Continue button
                    Button {
                        dismiss()
                    } label: {
                        Text(languageStore.t(.continue))
                            .font(Theme.bodyFont(16))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.vertical, 12)
                    }
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
                
                Spacer()
                    .frame(height: 40)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.2)) {
                showContent = true
            }
            withAnimation(.easeOut.delay(0.4)) {
                showConfetti = true
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(activityItems: [image])
            }
        }
    }
    
    private func shareAchievement() {
        let card = AchievementShareCard(starsEarned: challengeStore.maxDailyStars)
        shareImage = card.snapshotImage(size: CGSize(width: 320, height: 280))
        showShareSheet = true
    }
}

/// Golden trophy display
private struct TrophyView: View {
    @State private var isGlowing = false
    
    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 1, green: 0.84, blue: 0).opacity(0.4), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .scaleEffect(isGlowing ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isGlowing)
            
            // Trophy body
            VStack(spacing: 0) {
                // Cup
                ZStack {
                    // Main cup
                    TrophyCupShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.88, blue: 0.3),
                                    Color(red: 1.0, green: 0.76, blue: 0.1),
                                    Color(red: 0.9, green: 0.65, blue: 0.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 100, height: 80)
                    
                    // 100 text
                    Text("100")
                        .font(Theme.titleFont(28))
                        .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 0.1))
                        .offset(y: 5)
                }
                
                // Stem
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.76, blue: 0.1),
                                Color(red: 0.9, green: 0.65, blue: 0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 20, height: 30)
                
                // Base
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.76, blue: 0.1),
                                Color(red: 0.8, green: 0.55, blue: 0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 60, height: 20)
            }
            
            // Star decorations
            ForEach(0..<3) { i in
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .offset(
                        x: CGFloat([-35, 0, 35][i]),
                        y: CGFloat([-15, -45, -15][i])
                    )
            }
        }
        .onAppear {
            isGlowing = true
        }
    }
}

private struct TrophyCupShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topWidth = rect.width
        let bottomWidth = rect.width * 0.5
        
        path.move(to: CGPoint(x: (rect.width - topWidth) / 2, y: 0))
        path.addLine(to: CGPoint(x: (rect.width - topWidth) / 2 + topWidth, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX + bottomWidth / 2, y: rect.height),
            control: CGPoint(x: rect.maxX, y: rect.height * 0.6)
        )
        path.addLine(to: CGPoint(x: rect.midX - bottomWidth / 2, y: rect.height))
        path.addQuadCurve(
            to: CGPoint(x: (rect.width - topWidth) / 2, y: 0),
            control: CGPoint(x: rect.minX, y: rect.height * 0.6)
        )
        
        return path
    }
}

/// Share card for achievement - standalone view for snapshot (no environment objects)
private struct AchievementShareCard: View {
    let starsEarned: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("🏆 Fun Math Quest 🏆")
                .font(Theme.titleFont(20))
                .foregroundStyle(Theme.ink)
            
            Text("Daily Challenge Complete!")
                .font(Theme.bodyFont(16))
            
            HStack {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color(red: 1, green: 0.84, blue: 0))
                }
            }
            .font(.title)
            
            Text("\(starsEarned) Stars Earned!")
                .font(Theme.titleFont(18))
                .foregroundStyle(Theme.modePurple)
            
            Text(Date().formatted(date: .abbreviated, time: .omitted))
                .font(Theme.bodyFont(12))
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(width: 320)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.highlight, lineWidth: 3)
        )
        .padding()
        .background(Color.white)
    }
}


#Preview {
    ChallengeCompleteView()
        .environmentObject(DailyChallengeStore.mockComplete)
        .environmentObject(LanguageStore())
}

