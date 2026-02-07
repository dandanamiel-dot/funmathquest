import Foundation

struct SessionResult: Identifiable, Codable {
    let id: UUID
    let mode: GameMode
    let totalQuestions: Int
    let correctAnswers: Int
    let bestStreak: Int
    let durationSeconds: Int
    let date: Date

    init(mode: GameMode, totalQuestions: Int, correctAnswers: Int, bestStreak: Int, durationSeconds: Int, date: Date = Date()) {
        self.id = UUID()
        self.mode = mode
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.bestStreak = bestStreak
        self.durationSeconds = durationSeconds
        self.date = date
    }

    var accuracyText: String {
        guard totalQuestions > 0 else { return "0%" }
        let percent = Double(correctAnswers) / Double(totalQuestions) * 100
        return String(format: "%.0f%%", percent)
    }

    var durationText: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
