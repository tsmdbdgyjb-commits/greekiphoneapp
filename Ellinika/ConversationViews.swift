import SwiftUI

struct ConversationsView: View {
    @Environment(Store.self) private var store
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink { TutorSetupView() } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "sparkles").font(.title2).foregroundStyle(Theme.olive).frame(width: 36)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Freies Gespräch mit Eleni").font(.headline)
                                Text("KI-Gesprächspartnerin: antwortet auf Griechisch, übersetzt und korrigiert deine Fehler.")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                } header: { Text("Frei sprechen") }
                Section {
                    ForEach(dialogs) { d in
                        NavigationLink { DialogView(dialog: d) } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(d.title).font(.headline)
                                    Text(d.setting).font(.subheadline).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if store.saved.dialogsDone.contains(d.id) {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: { Text("Übungsdialoge") } footer: { Text("Wähle in jeder Situation die passende Antwort. Funktioniert ohne Internet.") }
            }
            .navigationTitle("Gespräche")
        }
    }
}

// MARK: Übungsdialog
struct Bubble: View {
    let gr: String; let de: String; let mine: Bool; var name: String? = nil
    var body: some View {
        HStack {
            if mine { Spacer(minLength: 40) }
            VStack(alignment: .leading, spacing: 4) {
                if let name { Text(name.uppercased()).font(.caption2.weight(.semibold)).tracking(0.6).foregroundStyle(.secondary) }
                HStack(alignment: .top, spacing: 8) {
                    Text(gr).font(Theme.greek(20))
                    if !mine { SpeakButton(text: gr).scaleEffect(0.8) }
                }
                Text(de).font(.footnote).foregroundStyle(.secondary)
            }
            .padding(12)
            .background(mine ? Theme.oliveSoft : Theme.surface, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(mine ? Theme.olive.opacity(0.5) : Theme.line))
            if !mine { Spacer(minLength: 40) }
        }
    }
}

struct DialogView: View {
    let dialog: Dialog
    @Environment(Store.self) private var store
    @State private var step = 0
    @State private var options: [Phrase] = []
    @State private var wrongPicked: Phrase?
    @State private var showGerman = true

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    Text(dialog.setting).font(.subheadline).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(0..<min(step + 1, dialog.steps.count), id: \.self) { s in
                        let st = dialog.steps[s]
                        Bubble(gr: st.partner.gr, de: st.partner.de, mine: false, name: dialog.partnerName)
                        if s < step { Bubble(gr: st.correct.gr, de: st.correct.de, mine: true) }
                    }
                    if step >= dialog.steps.count {
                        Panel {
                            VStack(spacing: 8) {
                                Text("Μπράβο!").font(Theme.greek(36))
                                Text("Dialog geschafft.").font(.headline)
                                Button("Nochmal von vorn") { step = 0; prepare() }.buttonStyle(.borderedProminent)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DEINE ANTWORT").font(.caption.weight(.semibold)).tracking(0.8).foregroundStyle(.secondary)
                            ForEach(options, id: \.self) { o in
                                OptionButton(text: showGerman ? "\(o.gr)\n\(o.de)" : o.gr, greek: !showGerman, state: o == wrongPicked ? .wrong : .idle) {
                                    choose(o)
                                }
                            }
                            if let w = wrongPicked {
                                Text("„\(w.de)“ passt hier nicht. Versuch es nochmal.").font(.subheadline).foregroundStyle(.red)
                            }
                        }
                        .padding(.top, 8)
                    }
                    Color.clear.frame(height: 1).id("end")
                }
                .padding()
            }
            .onChange(of: step) { withAnimation { proxy.scrollTo("end") } }
        }
        .background(Theme.bg)
        .navigationTitle(dialog.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Toggle(isOn: $showGerman) { Text("Hilfe") }.toggleStyle(.button)
        }
        .onAppear { prepare(); Speaker.say(dialog.steps[0].partner.gr) }
    }

    private func prepare() {
        wrongPicked = nil
        guard step < dialog.steps.count else { return }
        let s = dialog.steps[step]
        options = ([s.correct] + s.wrong).shuffled()
    }

    private func choose(_ o: Phrase) {
        let s = dialog.steps[step]
        if o == s.correct {
            Speaker.say(o.gr)
            step += 1
            prepare()
            if step < dialog.steps.count {
                let next = dialog.steps[step].partner.gr
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { Speaker.say(next) }
            } else {
                store.recordDialog(dialog.id)
            }
        } else {
            wrongPicked = o
        }
    }
}
