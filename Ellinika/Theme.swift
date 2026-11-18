import SwiftUI
import UIKit
import AVFoundation

enum Theme {
    static func dyn(_ light: UIColor, _ dark: UIColor) -> Color {
        Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? dark : light })
    }
    static let olive = dyn(UIColor(red: 0.373, green: 0.435, blue: 0.133, alpha: 1), UIColor(red: 0.710, green: 0.769, blue: 0.416, alpha: 1))
    static let oliveSoft = olive.opacity(0.16)
    static let sea = dyn(UIColor(red: 0.114, green: 0.361, blue: 0.525, alpha: 1), UIColor(red: 0.498, green: 0.714, blue: 0.863, alpha: 1))
    static let bg = dyn(UIColor(red: 0.953, green: 0.957, blue: 0.937, alpha: 1), UIColor(red: 0.071, green: 0.086, blue: 0.106, alpha: 1))
    static let surface = dyn(.white, UIColor(red: 0.106, green: 0.129, blue: 0.157, alpha: 1))
    static let line = Color.secondary.opacity(0.25)
    static func greek(_ size: CGFloat) -> Font { .system(size: size, design: .serif) }
}

@MainActor
enum Speaker {
    static let synth = AVSpeechSynthesizer()
    static func say(_ text: String) {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        let u = AVSpeechUtterance(string: text.replacingOccurrences(of: "…", with: "").replacingOccurrences(of: "___", with: ""))
        u.voice = AVSpeechSynthesisVoice(language: "el-GR")
        u.rate = 0.42
        synth.stopSpeaking(at: .immediate)
        synth.speak(u)
    }
}

struct SpeakButton: View {
    let text: String
    var body: some View {
        Button { Speaker.say(text) } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 38, height: 38)
                .background(Theme.sea.opacity(0.15), in: Circle())
                .foregroundStyle(Theme.sea)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Aussprache anhören")
    }
}

struct Panel<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.line))
    }
}

struct CategoryChips: View {
    @Binding var selection: Cat?
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip("Alle", selection == nil) { selection = nil }
                ForEach(Cat.allCases) { c in chip(c.title, selection == c) { selection = c } }
            }
            .padding(.horizontal)
        }
    }
    private func chip(_ t: String, _ on: Bool, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(t)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(on ? Theme.oliveSoft : Color.clear, in: Capsule())
                .overlay(Capsule().stroke(on ? Theme.olive : Theme.line))
                .foregroundStyle(on ? Color.primary : Color.secondary)
        }
        .buttonStyle(.plain)
    }
}

struct OptionButton: View {
    enum State { case idle, right, wrong, dimmed }
    let text: String
    var greek = false
    var state: State = .idle
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(greek ? Theme.greek(21) : .body.weight(.medium))
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                if state == .right { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                if state == .wrong { Image(systemName: "xmark.circle.fill").foregroundStyle(.red) }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(bg, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(border))
            .opacity(state == .dimmed ? 0.5 : 1)
        }
        .buttonStyle(.plain)
    }
    private var bg: Color {
        switch state { case .right: .green.opacity(0.15); case .wrong: .red.opacity(0.13); default: Theme.surface }
    }
    private var border: Color {
        switch state { case .right: .green; case .wrong: .red; default: Theme.line }
    }
}
