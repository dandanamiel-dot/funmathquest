import SwiftUI

struct DrillView: View {
    @EnvironmentObject private var scoreStore: ScoreStore
    @EnvironmentObject private var languageStore: LanguageStore
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

    var body: some View {
        ZStack {
            PlayfulBackground()

            VStack(spacing: 18) {
                header

                questionCard

                answerSection

                Spacer()
            }
            .padding(20)
        }
        .onAppear {
            startRound()
        }
        .onChange(of: totalQuestions) { _, _ in
            startRound()
        }
        .alert(languageStore.t(.roundComplete), isPresented: $showSummary) {
            Button(languageStore.t(.done)) { dismiss() }
        } message: {
            Text(String(format: languageStore.t(.gotScore), correctCount, totalQuestions))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(modeTitle)
                .font(Theme.titleFont(26))
                .foregroundStyle(Theme.ink)
            Text(String(format: languageStore.t(.questionOf), questionIndex, totalQuestions))
                .font(Theme.bodyFont(16))
                .foregroundStyle(.secondary)

            ProgressView(value: Double(questionIndex), total: Double(totalQuestions))
                .tint(mode.tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var questionCard: some View {
        VStack(spacing: 12) {
            Text("\(currentQuestion.lhs) \(currentQuestion.operation.symbol) \(currentQuestion.rhs)")
                .font(Theme.titleFont(52))
                .foregroundStyle(Theme.ink)
            if showFeedback {
                Text(feedbackText)
                    .font(Theme.bodyFont(18))
                    .foregroundStyle(feedbackColor)
            } else {
                Text(languageStore.t(.whatIsAnswer))
                    .font(Theme.bodyFont(16))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(mode.tint.opacity(0.25), lineWidth: 2)
                )
        )
        .shadow(color: mode.tint.opacity(0.18), radius: 12, x: 0, y: 6)
    }

    private var answerSection: some View {
        VStack(spacing: 12) {
            HStack {
                TextField(languageStore.t(.typeAnswer), text: $answerText)
                    .keyboardType(.numberPad)
                    .font(Theme.titleFont(20))
                    .padding(12)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 16))

                Button(languageStore.t(.check)) {
                    checkAnswer()
                }
                .buttonStyle(.borderedProminent)
                .tint(mode.tint)
                .disabled(answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(languageStore.t(.streak)): \(currentStreak)")
                    Text("\(languageStore.t(.best)): \(bestStreak)")
                }
                .font(Theme.bodyFont(14))
                .foregroundStyle(.secondary)

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
            feedbackText = languageStore.isHebrew ? "כל הכבוד!" : "Great job!"
            feedbackColor = .green
        } else {
            currentStreak = 0
            feedbackText = languageStore.isHebrew ? "אופס! התשובה היא \(currentQuestion.answer)" : "Oops! It was \(currentQuestion.answer)"
            feedbackColor = .red
        }

        showFeedback = true
        answerText = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            advanceQuestion()
        }
    }

    private func advanceQuestion() {
        showFeedback = false
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
            var all: [Question] = []
            for lhs in 1...12 {
                for rhs in 1...12 {
                    all.append(Question(lhs: lhs, rhs: rhs, operation: .multiply))
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

#Preview {
    DrillView(mode: .random)
        .environmentObject(ScoreStore.mock)
        .environmentObject(LanguageStore())
}
