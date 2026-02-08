import SwiftUI

struct DrillView: View {
    @EnvironmentObject private var scoreStore: ScoreStore
    @EnvironmentObject private var languageStore: LanguageStore
    @EnvironmentObject private var challengeStore: DailyChallengeStore
    @Environment(\.dismiss) private var dismiss

    let mode: GameMode

    @State private var questionIndex = 1
    @State private var totalQuestions = 10
    @State private var questions: [Question] = []
    @State private var currentQuestion = Question(lhs: 1, rhs: 1, operation: .multiply)
    @State private var answerText = ""
    @State private var correctCount = 0
    @State private var bestStreak = 0
    @State private var currentStreak = 0
    @State private var showFeedback = false
    @State private var feedbackText = ""
    @State private var feedbackColor: Color = .green
    @State private var startTime = Date()
    @State private var showSummary = false
    
    // Animation states
    @State private var showConfetti = false
    @State private var showStarBurst = false
    @State private var mascotMood: MascotMood = .happy
    @State private var mascotMessage: String? = nil
    @State private var starsEarnedThisSession = 0
    @State private var shakeCard = false

    var body: some View {
        ZStack {
            PlayfulBackground()
            
            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
            
            // Star burst overlay
            if showStarBurst {
                StarBurstView()
            }

            VStack(spacing: 18) {
                header
                
                // Mascot
                MascotView(mood: mascotMood, message: mascotMessage, size: 80)
                    .animation(.spring(response: 0.4), value: mascotMood)

                questionCard
                    .modifier(ShakeEffect(animatableData: shakeCard ? 1 : 0))

                answerSection

                Spacer()
            }
            .padding(20)
        }
        .onAppear {
            startRound()
            mascotMessage = languageStore.t(.youCanDoIt)
        }
        .onChange(of: totalQuestions) { _, _ in
            startRound()
        }
        .sheet(isPresented: $showSummary) {
            RoundSummaryView(
                mode: mode,
                correctCount: correctCount,
                totalQuestions: totalQuestions,
                starsEarned: starsEarnedThisSession,
                onDismiss: { dismiss() }
            )
            .environmentObject(languageStore)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(modeTitle)
                    .font(Theme.titleFont(26))
                    .foregroundStyle(Theme.ink)
                
                Spacer()
                
                // Streak indicator
                if currentStreak >= 2 {
                    HStack(spacing: 4) {
                        Text("🔥")
                        Text("×\(currentStreak)")
                            .font(Theme.titleFont(16))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.modeOrange.opacity(0.2), in: Capsule())
                }
            }
            
            Text(String(format: languageStore.t(.questionOf), questionIndex, totalQuestions))
                .font(Theme.bodyFont(16))
                .foregroundStyle(Theme.textSecondary)

            ProgressView(value: Double(questionIndex), total: Double(totalQuestions))
                .tint(mode.tint)
                .animation(.spring(response: 0.4), value: questionIndex)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var questionCard: some View {
        VStack(spacing: 12) {
            Text("\(currentQuestion.lhs) \(currentQuestion.operation.symbol) \(currentQuestion.rhs)")
                .font(Theme.titleFont(52))
                .foregroundStyle(Theme.ink)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: currentQuestion.lhs)
            
            if showFeedback {
                Text(feedbackText)
                    .font(Theme.bodyFont(18))
                    .foregroundStyle(feedbackColor)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text(languageStore.t(.whatIsAnswer))
                    .font(Theme.bodyFont(16))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [mode.tint.opacity(0.4), mode.tint.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
        )
        .shadow(color: mode.tint.opacity(0.2), radius: 15, x: 0, y: 8)
    }

    private var answerSection: some View {
        VStack(spacing: 12) {
            HStack {
                TextField(languageStore.t(.typeAnswer), text: $answerText)
                    .keyboardType(.numberPad)
                    .font(Theme.titleFont(24))
                    .padding(14)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)

                Button {
                    checkAnswer()
                } label: {
                    Text(languageStore.t(.check))
                        .font(Theme.bodyFont(16))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(mode.tint, in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1)
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(languageStore.t(.streak)): \(currentStreak)")
                    Text("\(languageStore.t(.best)): \(bestStreak)")
                }
                .font(Theme.bodyFont(14))
                .foregroundStyle(Theme.textSecondary)

                Spacer()

                Stepper(String(format: languageStore.t(.questionsCount), totalQuestions), value: $totalQuestions, in: 5...20)
                    .font(Theme.bodyFont(14))
            }
        }
    }

    private func checkAnswer() {
        let trimmed = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let answer = Int(trimmed) else { return }

        let isCorrect = answer == currentQuestion.answer
        
        if isCorrect {
            correctCount += 1
            currentStreak += 1
            bestStreak = max(bestStreak, currentStreak)
            
            // Update mascot
            mascotMood = .excited
            mascotMessage = randomEncouragement(correct: true)
            
            // Show confetti
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showConfetti = false
            }
            
            // Record drill and check for stars
            let newStars = challengeStore.recordDrill(wasCorrect: true)
            if newStars > 0 {
                starsEarnedThisSession += newStars
                showStarBurst = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showStarBurst = false
                }
            }
            
            feedbackText = languageStore.t(.greatJob)
            feedbackColor = Theme.correct
        } else {
            currentStreak = 0
            
            // Update mascot
            mascotMood = .encouraging
            mascotMessage = randomEncouragement(correct: false)
            
            // Gentle shake animation - only affects the card
            withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                shakeCard = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    shakeCard = false
                }
            }
            
            feedbackText = "\(languageStore.t(.oopsAnswer)) \(currentQuestion.answer)"
            feedbackColor = Theme.incorrect
        }

        showFeedback = true
        answerText = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            advanceQuestion()
        }
    }
    
    private func randomEncouragement(correct: Bool) -> String {
        if correct {
            let options = [
                languageStore.t(.greatJob),
                languageStore.t(.amazing),
                languageStore.t(.keepGoing)
            ]
            return options.randomElement() ?? languageStore.t(.greatJob)
        } else {
            let options = [
                languageStore.t(.tryAgain),
                languageStore.t(.youCanDoIt),
                languageStore.t(.almostThere)
            ]
            return options.randomElement() ?? languageStore.t(.tryAgain)
        }
    }

    private func advanceQuestion() {
        showFeedback = false
        mascotMood = .thinking
        mascotMessage = nil
        
        if questionIndex >= totalQuestions {
            finishRound()
            return
        }
        questionIndex += 1
        if let next = questions.first {
            currentQuestion = next
            questions.removeFirst()
        } else {
            finishRound()
        }
        
        // Reset mascot after a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            mascotMood = .happy
            mascotMessage = languageStore.t(.youCanDoIt)
        }
    }

    private func finishRound() {
        let duration = Int(Date().timeIntervalSince(startTime))
        let session = SessionResult(
            mode: mode,
            totalQuestions: totalQuestions,
            correctAnswers: correctCount,
            bestStreak: bestStreak,
            durationSeconds: max(duration, 1)
        )
        scoreStore.add(session)
        showSummary = true
    }

    private func startRound() {
        startTime = Date()
        questionIndex = 1
        correctCount = 0
        bestStreak = 0
        currentStreak = 0
        showFeedback = false
        answerText = ""
        starsEarnedThisSession = 0
        mascotMood = .happy
        questions = makeQuestionPool()
        if let first = questions.first {
            currentQuestion = first
            questions.removeFirst()
        }
    }

    private func makeQuestionPool() -> [Question] {
        switch mode {
        case .by10:
            return buildRepeatedPool(rhs: 10, operation: .multiply)
        case .by100:
            return buildRepeatedPool(rhs: 100, operation: .multiply)
        case .by1000:
            return buildRepeatedPool(rhs: 1000, operation: .multiply)
        case .div10:
            return buildDivisionPool(divisor: 10)
        case .div100:
            return buildDivisionPool(divisor: 100)
        case .random:
            // Combine ALL drill types for a comprehensive random mix
            var all: [Question] = []
            
            // Multiply by 10, 100, 1000
            for multiplier in [10, 100, 1000] {
                for lhs in 1...12 {
                    all.append(Question(lhs: lhs, rhs: multiplier, operation: .multiply))
                }
            }
            
            // Divide by 10, 100
            for divisor in [10, 100] {
                for quotient in 1...12 {
                    all.append(Question(lhs: divisor * quotient, rhs: divisor, operation: .divide))
                }
            }
            
            // Random multiplication (1-12 × 1-12)
            for lhs in 1...12 {
                for rhs in 1...12 {
                    all.append(Question(lhs: lhs, rhs: rhs, operation: .multiply))
                }
            }
            
            // Random division (results 1-12)
            for quotient in 1...12 {
                for divisor in 2...12 {
                    all.append(Question(lhs: quotient * divisor, rhs: divisor, operation: .divide))
                }
            }
            
            return Array(all.shuffled().prefix(totalQuestions))
        case .table:
            return [Question(lhs: 1, rhs: 1, operation: .multiply)]
        }
    }

    private func buildRepeatedPool(rhs: Int, operation: Operation) -> [Question] {
        let base = (1...12).map { Question(lhs: $0, rhs: rhs, operation: operation) }
        if totalQuestions <= base.count {
            return Array(base.shuffled().prefix(totalQuestions))
        }
        var pool: [Question] = []
        while pool.count < totalQuestions {
            pool.append(contentsOf: base.shuffled())
        }
        return Array(pool.prefix(totalQuestions))
    }

    private func buildDivisionPool(divisor: Int) -> [Question] {
        let base = (1...12).map { quotient in
            Question(lhs: divisor * quotient, rhs: divisor, operation: .divide)
        }
        if totalQuestions <= base.count {
            return Array(base.shuffled().prefix(totalQuestions))
        }
        var pool: [Question] = []
        while pool.count < totalQuestions {
            pool.append(contentsOf: base.shuffled())
        }
        return Array(pool.prefix(totalQuestions))
    }

    private var modeTitle: String {
        switch mode {
        case .table:
            return languageStore.t(.multiplicationTable)
        case .by10:
            return languageStore.isHebrew ? "כפל ב־10" : "Multiply by 10"
        case .by100:
            return languageStore.isHebrew ? "כפל ב־100" : "Multiply by 100"
        case .by1000:
            return languageStore.isHebrew ? "כפל ב־1000" : "Multiply by 1000"
        case .div10:
            return languageStore.isHebrew ? "חילוק ב־10" : "Divide by 10"
        case .div100:
            return languageStore.isHebrew ? "חילוק ב־100" : "Divide by 100"
        case .random:
            return languageStore.isHebrew ? "תרגולים אקראיים" : "Random Drills"
        }
    }
}

// MARK: - Question Model

private struct Question {
    let lhs: Int
    let rhs: Int
    let operation: Operation

    var answer: Int {
        switch operation {
        case .multiply:
            return lhs * rhs
        case .divide:
            return lhs / rhs
        }
    }
}

private enum Operation {
    case multiply
    case divide

    var symbol: String {
        switch self {
        case .multiply:
            return "×"
        case .divide:
            return "÷"
        }
    }
}

// MARK: - Shake Effect

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        // Gentle shake: 2 oscillations, max 6 pixels
        let translation = sin(animatableData * .pi * 2) * 6 * (1 - animatableData)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// MARK: - Round Summary View

private struct RoundSummaryView: View {
    let mode: GameMode
    let correctCount: Int
    let totalQuestions: Int
    let starsEarned: Int
    let onDismiss: () -> Void
    
    @EnvironmentObject private var languageStore: LanguageStore
    
    var body: some View {
        VStack(spacing: 24) {
            Text(languageStore.t(.roundComplete))
                .font(Theme.titleFont(28))
                .foregroundStyle(Theme.ink)
            
            MascotView(mood: .excited, size: 100)
            
            VStack(spacing: 8) {
                Text(String(format: languageStore.t(.gotScore), correctCount, totalQuestions))
                    .font(Theme.bodyFont(18))
                
                if starsEarned > 0 {
                    HStack {
                        AnimatedStar(size: 24)
                        Text("+\(starsEarned) \(languageStore.t(.starsEarned))")
                            .font(Theme.titleFont(18))
                            .foregroundStyle(Theme.starGold)
                    }
                    .padding(.top, 8)
                }
            }
            
            Button(languageStore.t(.done)) {
                onDismiss()
            }
            .font(Theme.bodyFont(16))
            .foregroundStyle(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 14)
            .background(mode.tint, in: Capsule())
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.backgroundGradient)
    }
}

#Preview {
    DrillView(mode: .random)
        .environmentObject(ScoreStore.mock)
        .environmentObject(LanguageStore())
        .environmentObject(DailyChallengeStore.mock)
}

