import SwiftUI
import Observation

struct CardState: Codable { var box: Int; var due: Date }

struct Saved: Codable {
    var cards: [Int: CardState] = [:]
    var letters: Set<Int> = []
    var streak = 0
    var lastDay: Date? = nil
    var grammarBest: [String: Int] = [:]
    var dialogsDone: Set<String> = []
}

@Observable
final class Store {
    static let intervals = [0, 1, 2, 4, 8, 16] // Tage pro Leitner-Fach
    var saved: Saved
    var category: Cat? = nil

    init() {
        if let d = UserDefaults.standard.data(forKey: "ellinika"),
           let s = try? JSONDecoder().decode(Saved.self, from: d) {
            saved = s
        } else {
            saved = Saved()
        }
    }

    func persist() {
        if let d = try? JSONEncoder().encode(saved) { UserDefaults.standard.set(d, forKey: "ellinika") }
    }

    var pool: [Word] { words.filter { category == nil || $0.cat == category } }
    func isDue(_ w: Word) -> Bool {
        guard let c = saved.cards[w.id] else { return false }
        return c.due <= Date()
    }
    var learnedCount: Int { saved.cards.values.filter { $0.box >= 3 }.count }
    var dueCount: Int { words.filter(isDue).count }

    private var today: Date { Calendar.current.startOfDay(for: .now) }
    var streak: Int {
        guard let l = saved.lastDay else { return 0 }
        let y = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        return l >= y ? saved.streak : 0
    }
    func touchStreak() {
        let t = today
        if saved.lastDay == t { return }
        let y = Calendar.current.date(byAdding: .day, value: -1, to: t)!
        saved.streak = (saved.lastDay == y) ? saved.streak + 1 : 1
        saved.lastDay = t
        persist()
    }

    func grade(_ w: Word, ok: Bool) {
        var c = saved.cards[w.id] ?? CardState(box: 0, due: .now)
        c.box = ok ? min(5, c.box + 1) : 1
        c.due = Calendar.current.date(byAdding: .day, value: Store.intervals[c.box], to: today)!
        saved.cards[w.id] = c
        touchStreak()
        persist()
    }

    func recordGrammar(_ id: String, score: Int) {
        saved.grammarBest[id] = max(saved.grammarBest[id] ?? 0, score)
        touchStreak(); persist()
    }
    func recordDialog(_ id: String) {
        saved.dialogsDone.insert(id)
        touchStreak(); persist()
    }
    func toggleLetter(_ i: Int) {
        if saved.letters.contains(i) { saved.letters.remove(i) } else { saved.letters.insert(i) }
        persist()
    }
}
