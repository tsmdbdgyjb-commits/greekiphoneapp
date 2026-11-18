import SwiftUI

struct VocabView: View {
    enum Mode: String, CaseIterable { case karten = "Karteikarten", quiz = "Quiz", liste = "Wortliste" }
    @State private var mode: Mode = .karten
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Modus", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { Text($0.rawValue) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal).padding(.bottom, 8)
                switch mode {
                case .karten: CardsView()
                case .quiz: QuizView()
                case .liste: WordListView()
                }
            }
            .background(Theme.bg)
            .navigationTitle("Vokabeln")
        }
    }
}

struct StatsHeader: View {
    @Environment(Store.self) private var store
    var body: some View {
        HStack(spacing: 0) {
            stat("\(store.learnedCount)/\(words.count)", "gelernt")
            Divider().frame(height: 30)
            stat("\(store.dueCount)", "fällig")
            Divider().frame(height: 30)
            stat("\(store.streak)", "Tage in Folge")
        }
        .padding(.vertical, 10)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line))
        .padding(.horizontal)
    }
    private func stat(_ v: String, _ l: String) -> some View {
        VStack(spacing: 2) {
            Text(v).font(.title3.weight(.semibold).monospacedDigit())
            Text(l.uppercased()).font(.caption2.weight(.semibold)).tracking(0.8).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity)
    }
}

// MARK: Karteikarten (Leitner-System)
struct CardsView: View {
    @Environment(Store.self) private var store
    @State private var queue: [Word] = []
    @State private var current: Word?
    @State private var flipped = false
    @State private var done = 0
    @State private var started = false

    var body: some View {
        @Bindable var store = store
        ScrollView {
            VStack(spacing: 16) {
                StatsHeader()
                CategoryChips(selection: $store.category)
                if let w = current { card(w) } else { finished }
                boxes
                Text("Richtige Antworten schieben eine Karte ins nächste Fach, sie kommt dann nach 1, 2, 4, 8 oder 16 Tagen wieder. Bei einer falschen Antwort geht sie zurück in Fach 1.")
                    .font(.footnote).foregroundStyle(.secondary).padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
        .onAppear { if !started { buildQueue(); started = true } }
        .onChange(of: store.category) { buildQueue() }
    }

    private func buildQueue() {
        let pool = store.pool
        let due = pool.filter(store.isDue).shuffled()
        let fresh = pool.filter { store.saved.cards[$0.id] == nil }.prefix(max(0, 10 - due.count))
        queue = due + fresh
        done = 0; flipped = false
        current = queue.isEmpty ? nil : queue.removeFirst()
    }

    private func card(_ w: Word) -> some View {
        let total = done + queue.count + 1
        let box = store.saved.cards[w.id].map { "Fach \($0.box)" } ?? "neu"
        return VStack(spacing: 14) {
            HStack {
                Text("\(w.cat.title) · \(box)").font(.caption.weight(.semibold)).textCase(.uppercase).foregroundStyle(.secondary)
                Spacer()
                Text("\(done + 1) von \(total)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            ProgressView(value: Double(done), total: Double(total))
            Panel {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Text(w.gr).font(Theme.greek(40)).minimumScaleFactor(0.5).lineLimit(2).multilineTextAlignment(.center)
                        SpeakButton(text: w.gr)
                    }
                    if flipped {
                        Text(w.tr).italic().foregroundStyle(.secondary)
                        Text(w.de).font(.title3.weight(.semibold)).multilineTextAlignment(.center)
                    } else {
                        Text("Weißt du, was das heißt?").font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .frame(minHeight: 200)
            }
            .contentShape(Rectangle())
            .onTapGesture { if !flipped { flip(w) } }
            if flipped {
                HStack(spacing: 12) {
                    Button { grade(false) } label: { Label("Wusste ich nicht", systemImage: "xmark").frame(maxWidth: .infinity) }
                        .buttonStyle(.bordered).tint(.red)
                    Button { grade(true) } label: { Label("Wusste ich", systemImage: "checkmark").frame(maxWidth: .infinity) }
                        .buttonStyle(.borderedProminent).tint(.green)
                }
                .controlSize(.large)
            } else {
                Button { flip(w) } label: { Text("Antwort zeigen").frame(maxWidth: .infinity) }
                    .buttonStyle(.borderedProminent).controlSize(.large)
            }
        }
        .padding(.horizontal)
    }

    private var finished: some View {
        Panel {
            VStack(spacing: 10) {
                Text("Μπράβο!").font(Theme.greek(40))
                Text("Für heute ist alles wiederholt.").font(.headline)
                Text("Neue Wiederholungen werden fällig, sobald ihre Pause vorbei ist.").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                Button("10 weitere Karten üben") {
                    queue = Array(store.pool.shuffled().prefix(10)); done = 0; flipped = false
                    current = queue.isEmpty ? nil : queue.removeFirst()
                }
                .buttonStyle(.borderedProminent).padding(.top, 4)
            }
        }
        .padding(.horizontal)
    }

    private var boxes: some View {
        let pool = store.pool
        var counts = [Int](repeating: 0, count: 6)
        for w in pool { counts[store.saved.cards[w.id]?.box ?? 0] += 1 }
        let labels = ["neu", "Fach 1", "Fach 2", "Fach 3", "Fach 4", "Fach 5"]
        return HStack(spacing: 6) {
            ForEach(0..<6, id: \.self) { i in
                VStack(spacing: 2) {
                    Text("\(counts[i])").font(.headline.monospacedDigit())
                    Text(labels[i]).font(.caption2).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 8)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.line))
            }
        }
        .padding(.horizontal)
    }

    private func flip(_ w: Word) { flipped = true; Speaker.say(w.gr) }
    private func grade(_ ok: Bool) {
        guard let w = current else { return }
        store.grade(w, ok: ok)
        if !ok { queue.insert(w, at: min(3, queue.count)) }
        done += 1; flipped = false
        current = queue.isEmpty ? nil : queue.removeFirst()
    }
}

// MARK: Quiz
struct QuizView: View {
    enum QMode: String, CaseIterable { case grDe = "GR → DE", deGr = "DE → GR", abc = "Buchstaben" }
    struct Q { let prompt: String; let answer: String; let speak: String; let promptGreek: Bool; let answerGreek: Bool; let options: [String] }

    @Environment(Store.self) private var store
    @State private var mode: QMode = .grDe
    @State private var qs: [Q] = []
    @State private var i = 0
    @State private var score = 0
    @State private var picked: Int?

    var body: some View {
        @Bindable var store = store
        ScrollView {
            VStack(spacing: 16) {
                Picker("Richtung", selection: $mode) { ForEach(QMode.allCases, id: \.self) { Text($0.rawValue) } }
                    .pickerStyle(.segmented).padding(.horizontal)
                if mode != .abc { CategoryChips(selection: $store.category) }
                if qs.isEmpty { EmptyView() }
                else if i >= qs.count { result }
                else { question(qs[i]) }
            }
            .padding(.vertical, 8)
        }
        .onAppear { if qs.isEmpty { newQuiz() } }
        .onChange(of: mode) { newQuiz() }
        .onChange(of: store.category) { newQuiz() }
    }

    private func newQuiz() {
        typealias Item = (p: String, a: String, s: String)
        let items: [Item]
        switch mode {
        case .abc: items = letters.map { ("\($0.upper) \($0.lower.prefix(1))", $0.latin, $0.name) }
        case .grDe: items = store.pool.map { ($0.gr, $0.de, $0.gr) }
        case .deGr: items = store.pool.map { ($0.de, $0.gr, $0.gr) }
        }
        qs = items.shuffled().prefix(10).map { it in
            let wrong = items.filter { $0.a != it.a }.shuffled().prefix(3).map(\.a)
            return Q(prompt: it.p, answer: it.a, speak: it.s, promptGreek: mode != .deGr, answerGreek: mode == .deGr, options: ([it.a] + wrong).shuffled())
        }
        i = 0; score = 0; picked = nil
    }

    private func question(_ q: Q) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("Frage \(i + 1) von \(qs.count)").font(.caption.weight(.semibold)).textCase(.uppercase).foregroundStyle(.secondary)
                Spacer()
                Text("\(score) richtig").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            ProgressView(value: Double(i), total: Double(qs.count))
            Panel {
                HStack(spacing: 12) {
                    Text(q.prompt).font(q.promptGreek ? Theme.greek(36) : .title2.weight(.semibold)).multilineTextAlignment(.center).minimumScaleFactor(0.6)
                    if q.promptGreek { SpeakButton(text: q.speak) }
                }
                .frame(minHeight: 110)
            }
            VStack(spacing: 10) {
                ForEach(Array(q.options.enumerated()), id: \.offset) { k, o in
                    OptionButton(text: o, greek: q.answerGreek, state: state(k, o, q)) {
                        guard picked == nil else { return }
                        picked = k
                        if o == q.answer { score += 1 }
                        if q.answerGreek { Speaker.say(q.answer) }
                        store.touchStreak()
                    }
                }
            }
            if picked != nil {
                Button { i += 1; picked = nil } label: { Text(i + 1 < qs.count ? "Weiter" : "Ergebnis ansehen").frame(maxWidth: .infinity) }
                    .buttonStyle(.borderedProminent).controlSize(.large)
            }
        }
        .padding(.horizontal)
    }

    private func state(_ k: Int, _ o: String, _ q: Q) -> OptionButton.State {
        guard let p = picked else { return .idle }
        if o == q.answer { return .right }
        if k == p { return .wrong }
        return .dimmed
    }

    private var result: some View {
        Panel {
            VStack(spacing: 10) {
                Text("ERGEBNIS").font(.caption.weight(.semibold)).tracking(1).foregroundStyle(.secondary)
                Text("\(score) / \(qs.count)").font(Theme.greek(52))
                Text(score >= 9 ? "Εξαιρετικά! Ausgezeichnet!" : score >= 6 ? "Πολύ καλά! Sehr gut!" : "Σιγά σιγά – Schritt für Schritt.")
                    .font(.headline).multilineTextAlignment(.center)
                Button("Neue Runde") { newQuiz() }.buttonStyle(.borderedProminent).padding(.top, 4)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: Wortliste
struct WordListView: View {
    @State private var query = ""
    var body: some View {
        List {
            ForEach(Cat.allCases) { c in
                let ws = words.filter { $0.cat == c && matches($0) }
                if !ws.isEmpty {
                    Section(c.title) {
                        ForEach(ws) { w in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(w.gr).font(Theme.greek(21))
                                    Text("\(w.tr) · \(w.de)").font(.subheadline).foregroundStyle(.secondary)
                                }
                                Spacer()
                                SpeakButton(text: w.gr)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $query, prompt: "Wort suchen")
    }
    private func matches(_ w: Word) -> Bool {
        guard !query.isEmpty else { return true }
        let q = query.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        return [w.gr, w.tr, w.de].contains { $0.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil).contains(q) }
    }
}
