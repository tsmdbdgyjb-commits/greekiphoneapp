import SwiftUI

struct AlphabetView: View {
    @Environment(Store.self) private var store
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tippe auf einen Buchstaben, um seinen Namen zu hören. Lange drücken markiert ihn als gelernt (\(store.saved.letters.count)/24).")
                        .font(.subheadline).foregroundStyle(.secondary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                        ForEach(letters.indices, id: \.self) { i in cell(i) }
                    }
                    Text("Buchstabenkombinationen").font(.title2.weight(.semibold)).padding(.top, 8)
                    VStack(spacing: 0) {
                        ForEach(combos.indices, id: \.self) { i in
                            let c = combos[i]
                            HStack(alignment: .firstTextBaseline, spacing: 12) {
                                Text(c.0).font(Theme.greek(22)).frame(width: 90, alignment: .leading)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(c.1).font(.subheadline.weight(.semibold))
                                    Text(c.2).font(.footnote).foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            if i < combos.count - 1 { Divider() }
                        }
                    }
                    .padding(.horizontal, 14)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line))
                    Text("Betonung").font(.title2.weight(.semibold)).padding(.top, 8)
                    Text("Jedes mehrsilbige Wort trägt einen Akzent (΄) auf der betonten Silbe. Er kann die Bedeutung ändern: πότε (wann) und ποτέ (nie). Das griechische Fragezeichen sieht aus wie ein Semikolon: Τι κάνεις;")
                        .font(.body)
                }
                .padding()
            }
            .background(Theme.bg)
            .navigationTitle("Alphabet")
        }
    }

    private func cell(_ i: Int) -> some View {
        let l = letters[i]
        let known = store.saved.letters.contains(i)
        return VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text("\(l.upper) \(l.lower)").font(Theme.greek(34))
                Spacer()
                if known { Image(systemName: "checkmark.seal.fill").foregroundStyle(Theme.olive) }
            }
            Text("\(l.name) · \(l.latin)").font(.subheadline.weight(.semibold))
            Text(l.sound).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(known ? Theme.oliveSoft : Theme.surface, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(known ? Theme.olive : Theme.line))
        .contentShape(Rectangle())
        .onTapGesture { Speaker.say(l.name) }
        .onLongPressGesture { store.toggleLetter(i) }
    }
}
