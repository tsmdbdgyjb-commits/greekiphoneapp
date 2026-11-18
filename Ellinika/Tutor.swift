import SwiftUI
import Security

// MARK: API-Schlüssel im Schlüsselbund
enum Keychain {
    private static let service = "app.ellinika.anthropic-key"
    static func get() -> String? {
        let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service,
                                kSecReturnData as String: true, kSecMatchLimit as String: kSecMatchLimitOne]
        var out: AnyObject?
        guard SecItemCopyMatching(q as CFDictionary, &out) == errSecSuccess, let d = out as? Data else { return nil }
        return String(data: d, encoding: .utf8)
    }
    static func set(_ value: String?) {
        let base: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service]
        SecItemDelete(base as CFDictionary)
        guard let value, !value.isEmpty else { return }
        var add = base
        add[kSecValueData as String] = Data(value.utf8)
        SecItemAdd(add as CFDictionary, nil)
    }
}

// MARK: Claude API (Messages, raw HTTP – es gibt kein offizielles Swift-SDK)
struct ChatMsg: Identifiable { let id = UUID(); let role: String; let text: String; var hidden = false }

enum TutorError: LocalizedError {
    case api(Int, String), refusal, empty
    var errorDescription: String? {
        switch self {
        case .api(401, _): "Der API-Schlüssel wurde abgelehnt. Prüfe ihn über das Schlüssel-Symbol oben rechts."
        case .api(429, _): "Gerade zu viele Anfragen. Warte einen Moment und sende die Nachricht erneut."
        case .api(let code, let msg): "Fehler \(code): \(msg)"
        case .refusal: "Auf diese Nachricht kann Eleni nicht antworten. Formuliere sie bitte anders."
        case .empty: "Die Antwort war leer. Sende die Nachricht bitte erneut."
        }
    }
}

enum TutorAPI {
    static func reply(history: [ChatMsg], system: String, key: String) async throws -> String {
        var req = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        req.httpMethod = "POST"
        req.timeoutInterval = 120
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        req.setValue(key, forHTTPHeaderField: "x-api-key")
        req.setValue("2026-10-21", forHTTPHeaderField: "anthropic-version")
        req.setValue("server-side-fallback-2026-07-01", forHTTPHeaderField: "anthropic-beta")
        let body: [String: Any] = [
            "model": "claude-opus-5-5",
            "max_tokens": 16000,
            "system": system,
            "output_config": ["effort": "low"],
            "fallbacks": "default",
            "messages": history.map { ["role": $0.role, "content": $0.text] },
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, resp) = try await URLSession.shared.data(for: req)
        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
        let status = (resp as? HTTPURLResponse)?.statusCode ?? 0
        guard status == 200 else {
            let msg = (json["error"] as? [String: Any])?["message"] as? String ?? "Unbekannter Fehler"
            throw TutorError.api(status, msg)
        }
        if json["stop_reason"] as? String == "refusal" { throw TutorError.refusal }
        let blocks = json["content"] as? [[String: Any]] ?? []
        let text = blocks.filter { $0["type"] as? String == "text" }.compactMap { $0["text"] as? String }
            .joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { throw TutorError.empty }
        return text
    }

    static func systemPrompt(level: String, topic: String) -> String {
        """
        Du bist Eleni, eine freundliche Griechischlehrerin aus Thessaloniki. Du führst mit einer deutschsprachigen Person ein Gespräch auf Neugriechisch, damit sie Sprechen und Schreiben übt.
        Niveau der Person: \(level). Thema des Gesprächs: \(topic).

        So antwortest du:
        - Schreib auf Griechisch, kurz (ein bis drei Sätze), und ende meist mit einer Frage, damit das Gespräch weitergeht.
        - Passe Wortschatz und Grammatik an das Niveau an. Bei A1 nur sehr einfache Sätze im Präsens.
        - Darunter eine eigene Zeile, die mit „DE:“ beginnt, mit der deutschen Übersetzung deiner Antwort.
        - Enthält die letzte Nachricht der Person Fehler, füge eine Zeile hinzu, die mit „Korrektur:“ beginnt: die korrigierte griechische Fassung und eine sehr kurze Erklärung auf Deutsch. Ohne Fehler lässt du diese Zeile weg. Fehlende Akzente erwähnst du nur nebenbei.
        - Schreibt die Person auf Deutsch, zeig ihr in der Korrektur-Zeile, wie man das auf Griechisch sagt, und mach dann auf Griechisch weiter.
        - Verwende kein Markdown, keine Aufzählungen und keine Emojis.
        """
    }
}

// MARK: Einrichtung
struct TutorSetupView: View {
    static let levels = ["A1 – Anfänger", "A2 – Grundkenntnisse", "B1 – Mittelstufe"]
    static let topics = ["Sich vorstellen", "Im Café bestellen", "Urlaub in Griechenland", "Familie und Freunde", "Mein Alltag", "Freies Thema"]
    @AppStorage("tutorLevel") private var level = levels[0]
    @AppStorage("tutorTopic") private var topic = topics[0]
    @State private var hasKey = Keychain.get() != nil
    @State private var showKey = false

    var body: some View {
        Form {
            Section("Dein Niveau") {
                Picker("Niveau", selection: $level) { ForEach(Self.levels, id: \.self) { Text($0) } }.pickerStyle(.inline).labelsHidden()
            }
            Section("Thema") {
                Picker("Thema", selection: $topic) { ForEach(Self.topics, id: \.self) { Text($0) } }.pickerStyle(.inline).labelsHidden()
            }
            Section {
                if hasKey {
                    NavigationLink { TutorChatView(level: level, topic: topic) } label: {
                        Label("Gespräch beginnen", systemImage: "bubble.left.and.text.bubble.right").font(.headline)
                    }
                    Button("API-Schlüssel ändern") { showKey = true }
                } else {
                    Button { showKey = true } label: { Label("API-Schlüssel hinterlegen", systemImage: "key") }
                }
            } footer: {
                Text("Eleni nutzt Claude von Anthropic. Dafür brauchst du einen eigenen API-Schlüssel von console.anthropic.com. Er wird nur im Schlüsselbund dieses iPhones gespeichert. Jede Nachricht verursacht geringe Kosten auf deinem Anthropic-Konto.")
            }
        }
        .navigationTitle("Gespräch mit Eleni")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showKey) { KeySheet { hasKey = Keychain.get() != nil } }
    }
}

struct KeySheet: View {
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var key = ""
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("sk-ant-…", text: $key).textInputAutocapitalization(.never).autocorrectionDisabled()
                } footer: { Text("Den Schlüssel erstellst du unter console.anthropic.com → API Keys.") }
                if Keychain.get() != nil {
                    Button("Gespeicherten Schlüssel löschen", role: .destructive) { Keychain.set(nil); onSave(); dismiss() }
                }
            }
            .navigationTitle("API-Schlüssel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { Keychain.set(key.trimmingCharacters(in: .whitespacesAndNewlines)); onSave(); dismiss() }
                        .disabled(key.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: Chat
struct TutorChatView: View {
    let level: String
    let topic: String
    @Environment(Store.self) private var store
    @State private var messages: [ChatMsg] = []
    @State private var input = ""
    @State private var loading = false
    @State private var error: String?
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages.filter { !$0.hidden }) { m in
                            if m.role == "assistant" { TutorBubble(text: m.text) } else { UserBubble(text: m.text) }
                        }
                        if loading {
                            HStack { ProgressView(); Text("Eleni schreibt …").font(.subheadline).foregroundStyle(.secondary); Spacer() }
                        }
                        if let error {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(error).font(.subheadline).foregroundStyle(.red)
                                Button("Erneut senden") { Task { await send() } }.buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Color.clear.frame(height: 1).id("end")
                    }
                    .padding()
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: messages.count) { withAnimation { proxy.scrollTo("end") } }
                .onChange(of: loading) { withAnimation { proxy.scrollTo("end") } }
            }
            Divider()
            HStack(alignment: .bottom, spacing: 10) {
                TextField("Schreib auf Griechisch …", text: $input, axis: .vertical)
                    .lineLimit(1...4)
                    .focused($focused)
                    .padding(10)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.line))
                Button {
                    let t = input.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !t.isEmpty else { return }
                    messages.append(ChatMsg(role: "user", text: t))
                    input = ""
                    Task { await send() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill").font(.system(size: 34))
                }
                .disabled(loading || input.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal).padding(.vertical, 8)
            .background(Theme.bg)
        }
        .background(Theme.bg)
        .navigationTitle("Eleni · \(topic)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard messages.isEmpty else { return }
            messages.append(ChatMsg(role: "user", text: "Beginne bitte das Gespräch zum Thema „\(topic)“ mit einer Begrüßung und einer ersten Frage.", hidden: true))
            await send()
        }
    }

    private func send() async {
        guard let key = Keychain.get() else { error = "Kein API-Schlüssel hinterlegt."; return }
        loading = true; error = nil
        defer { loading = false }
        do {
            let text = try await TutorAPI.reply(history: messages, system: TutorAPI.systemPrompt(level: level, topic: topic), key: key)
            messages.append(ChatMsg(role: "assistant", text: text))
            store.touchStreak()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

struct UserBubble: View {
    let text: String
    var body: some View {
        HStack {
            Spacer(minLength: 50)
            Text(text).font(Theme.greek(18))
                .padding(12)
                .background(Theme.oliveSoft, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.olive.opacity(0.5)))
        }
    }
}

struct TutorBubble: View {
    let text: String
    private var parts: (greek: String, german: String?, correction: String?) {
        var g: [String] = [], d: String?, c: String?
        for line in text.components(separatedBy: "\n") {
            let t = line.trimmingCharacters(in: .whitespaces)
            if t.isEmpty { continue }
            if t.hasPrefix("DE:") { d = String(t.dropFirst(3)).trimmingCharacters(in: .whitespaces) }
            else if t.hasPrefix("Korrektur:") { c = String(t.dropFirst(10)).trimmingCharacters(in: .whitespaces) }
            else { g.append(t) }
        }
        return (g.joined(separator: "\n"), d, c)
    }
    var body: some View {
        let p = parts
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                if let c = p.correction {
                    Label { Text(c).font(.subheadline) } icon: { Image(systemName: "pencil.line").foregroundStyle(.orange) }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.13), in: RoundedRectangle(cornerRadius: 10))
                }
                HStack(alignment: .top, spacing: 8) {
                    Text(p.greek).font(Theme.greek(19)).textSelection(.enabled)
                    Spacer(minLength: 0)
                    SpeakButton(text: p.greek).scaleEffect(0.8)
                }
                if let d = p.german { Text(d).font(.footnote).foregroundStyle(.secondary) }
            }
            .padding(12)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.line))
            Spacer(minLength: 30)
        }
    }
}
