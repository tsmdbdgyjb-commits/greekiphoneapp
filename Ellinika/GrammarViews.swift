import SwiftUI

struct GrammarListView: View {
    @Environment(Store.self) private var store
    var body: some View {
        NavigationStack {
            List(lessons) { l in
                NavigationLink(value: l.id) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(l.title).font(.headline)
                            Text(l.subtitle).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let best = store.saved.grammarBest[l.id] {
                            Text("\(best)/\(l.exercises.count)")
                                .font(.caption.weight(.semibold).monospacedDigit())
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(best == l.exercises.count ? Color.green.opacity(0.18) : Theme.oliveSoft, in: Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Grammatik")
            .navigationDestination(for: String.self) { id in
                if let l = lessons.first(where: { $0.id == id }) { LessonView(lesson: l) }
            }
        }
    }
}

struct LessonView: View {
    let lesson: Lesson
    @State private var practicing = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if practicing {
                    ExerciseRunner(lesson: lesson) { practicing = false }
                } else {
                    Text(lesson.intro).font(.body)
                    ForEach(lesson.tables.indices, id: \.self) { ti in table(lesson.tables[ti]) }
                    if let tip = lesson.tip {
                        Label { Text(tip).font(.subheadline) } icon: { Image(systemName: "lightbulb").foregroundStyle(Theme.olive) }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.oliveSoft, in: RoundedRectangle(cornerRadius: 12))
                    }
                    Button { practicing = true } label: {
                        Label("\(lesson.exercises.count) Übungen starten", systemImage: "pencil.and.list.clipboard").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent).controlSize(.large)
                }
            }
            .padding()
        }
        .background(Theme.bg)
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func table(_ t: GTable) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t.title.uppercased()).font(.caption.weight(.semibold)).tracking(0.8).foregroundStyle(.secondary)
            VStack(spacing: 0) {
                ForEach(t.rows.indices, id: \.self) { r in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        ForEach(t.rows[r].indices, id: \.self) { c in
                            let s = t.rows[r][c]
                            Text(s)
                                .font(isGreek(s) ? Theme.greek(19) : .subheadline)
                                .fontWeight(r == 0 && t.rows[r][0].isEmpty ? .semibold : .regular)
                                .foregroundStyle(isGreek(s) ? Color.primary : Color.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if t.rows[r].contains(where: isGreek) {
                            SpeakButton(text: t.rows[r].filter(isGreek).first ?? "").scaleEffect(0.8)
                        }
                    }
                    .padding(.vertical, 8).padding(.horizontal, 12)
                    if r < t.rows.count - 1 { Divider() }
                }
            }
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line))
        }
    }

    private func isGreek(_ s: String) -> Bool {
        s.unicodeScalars.contains { (0x0370...0x03FF).contains($0.value) || (0x1F00...0x1FFF).contains($0.value) }
    }
}

struct ExerciseRunner: View {
    let lesson: Lesson
    let onClose: () -> Void
    @Environment(Store.self) private var store
    @State private var order: [Int] = []
    @State private var options: [[String]] = []
    @State private var i = 0
    @State private var picked: String?
    @State private var score = 0

    var body: some View {
        VStack(spacing: 16) {
            if order.isEmpty { EmptyView() }
            else if i >= order.count { result }
            else { exercise(lesson.exercises[order[i]], opts: options[i]) }
        }
        .onAppear(perform: start)
    }

    private func start() {
        order = Array(lesson.exercises.indices).shuffled()
        options = order.map { let e = lesson.exercises[$0]; return ([e.answer] + e.wrong).shuffled() }
        i = 0; score = 0; picked = nil
    }

    private func exercise(_ e: Exercise, opts: [String]) -> some View {
        let filled = e.sentence.replacingOccurrences(of: "___", with: picked == nil ? "＿＿＿" : e.answer)
        return VStack(spacing: 14) {
            HStack {
                Text("Übung \(i + 1) von \(order.count)").font(.caption.weight(.semibold)).textCase(.uppercase).foregroundStyle(.secondary)
                Spacer()
                Text("\(score) richtig").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            ProgressView(value: Double(i), total: Double(order.count))
            Panel {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Text(filled).font(Theme.greek(28)).multilineTextAlignment(.center).minimumScaleFactor(0.6)
                        if picked != nil { SpeakButton(text: filled) }
                    }
                    Text(e.german).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
                .frame(minHeight: 120)
            }
            ForEach(opts, id: \.self) { o in
                OptionButton(text: o, greek: true, state: state(o, e)) {
                    guard picked == nil else { return }
                    picked = o
                    if o == e.answer { score += 1 }
                }
            }
            if let p = picked {
                if p != e.answer {
                    Text("Richtig ist: \(e.answer)").font(.subheadline.weight(.semibold)).foregroundStyle(.red)
                }
                Button { i += 1; picked = nil; if i >= order.count { store.recordGrammar(lesson.id, score: score) } } label: {
                    Text(i + 1 < order.count ? "Weiter" : "Ergebnis ansehen").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent).controlSize(.large)
            }
        }
    }

    private func state(_ o: String, _ e: Exercise) -> OptionButton.State {
        guard let p = picked else { return .idle }
        if o == e.answer { return .right }
        return o == p ? .wrong : .dimmed
    }

    private var result: some View {
        Panel {
            VStack(spacing: 10) {
                Text("\(score) / \(order.count)").font(Theme.greek(52))
                Text(score == order.count ? "Τέλεια! Alles richtig." : "Gut gemacht! Wiederhole die Lektion, bis alles sitzt.")
                    .font(.headline).multilineTextAlignment(.center)
                HStack {
                    Button("Zur Erklärung", action: onClose).buttonStyle(.bordered)
                    Button("Nochmal üben", action: start).buttonStyle(.borderedProminent)
                }
                .padding(.top, 4)
            }
        }
    }
}
