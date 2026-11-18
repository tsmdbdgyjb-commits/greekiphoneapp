import Foundation

enum Cat: String, CaseIterable, Identifiable, Codable {
    case gruss, zahl, essen, fam, alltag, verb
    var id: Self { self }
    var title: String {
        switch self {
        case .gruss: "Begrüßung"
        case .zahl: "Zahlen"
        case .essen: "Essen & Trinken"
        case .fam: "Familie"
        case .alltag: "Alltag"
        case .verb: "Verben"
        }
    }
}

struct Word: Identifiable, Hashable { let id: Int; let gr: String; let tr: String; let de: String; let cat: Cat }

private let rawWords: [(String, String, String, Cat)] = [
    ("Γεια σου", "jia su", "Hallo (du)", .gruss),
    ("Γεια σας", "jia sas", "Hallo (Sie / ihr)", .gruss),
    ("Καλημέρα", "kaliméra", "Guten Morgen", .gruss),
    ("Καλησπέρα", "kalispéra", "Guten Abend", .gruss),
    ("Καληνύχτα", "kaliníchta", "Gute Nacht", .gruss),
    ("Ευχαριστώ", "efcharistó", "Danke", .gruss),
    ("Παρακαλώ", "parakaló", "Bitte", .gruss),
    ("Ναι", "ne", "Ja", .gruss),
    ("Όχι", "óchi", "Nein", .gruss),
    ("Συγγνώμη", "signómi", "Entschuldigung", .gruss),
    ("Τι κάνεις;", "ti kánis?", "Wie geht es dir?", .gruss),
    ("Καλά", "kalá", "Gut", .gruss),
    ("Αντίο", "adío", "Auf Wiedersehen", .gruss),
    ("Με λένε…", "me léne…", "Ich heiße …", .gruss),
    ("Χάρηκα", "chárika", "Freut mich", .gruss),
    ("Τα λέμε", "ta léme", "Bis dann", .gruss),
    ("ένα", "éna", "eins", .zahl), ("δύο", "dío", "zwei", .zahl), ("τρία", "tría", "drei", .zahl),
    ("τέσσερα", "téssera", "vier", .zahl), ("πέντε", "pénde", "fünf", .zahl), ("έξι", "éxi", "sechs", .zahl),
    ("επτά", "eptá", "sieben", .zahl), ("οκτώ", "októ", "acht", .zahl), ("εννέα", "ennéa", "neun", .zahl),
    ("δέκα", "déka", "zehn", .zahl), ("είκοσι", "íkosi", "zwanzig", .zahl), ("εκατό", "ekató", "hundert", .zahl),
    ("το νερό", "to neró", "das Wasser", .essen), ("το ψωμί", "to psomí", "das Brot", .essen),
    ("το κρασί", "to krasí", "der Wein", .essen), ("ο καφές", "o kafés", "der Kaffee", .essen),
    ("το τυρί", "to tirí", "der Käse", .essen), ("η ελιά", "i eliá", "die Olive", .essen),
    ("το ψάρι", "to psári", "der Fisch", .essen), ("το κρέας", "to kréas", "das Fleisch", .essen),
    ("το γάλα", "to gála", "die Milch", .essen), ("τα φρούτα", "ta frúta", "das Obst", .essen),
    ("η ντομάτα", "i domáta", "die Tomate", .essen),
    ("ο λογαριασμός", "o logariasmós", "die Rechnung", .essen), ("νόστιμο", "nóstimo", "lecker", .essen),
    ("η μητέρα", "i mitéra", "die Mutter", .fam), ("ο πατέρας", "o patéras", "der Vater", .fam),
    ("ο αδερφός", "o aderfós", "der Bruder", .fam), ("η αδερφή", "i aderfí", "die Schwester", .fam),
    ("η γιαγιά", "i jiajiá", "die Oma", .fam), ("ο παππούς", "o papús", "der Opa", .fam),
    ("το παιδί", "to pedí", "das Kind", .fam), ("ο φίλος", "o fílos", "der Freund", .fam),
    ("η οικογένεια", "i ikojénia", "die Familie", .fam),
    ("το σπίτι", "to spíti", "das Haus", .alltag), ("η θάλασσα", "i thálassa", "das Meer", .alltag),
    ("ο ήλιος", "o ílios", "die Sonne", .alltag), ("ο δρόμος", "o drómos", "die Straße", .alltag),
    ("η πόλη", "i póli", "die Stadt", .alltag), ("σήμερα", "símera", "heute", .alltag),
    ("αύριο", "ávrio", "morgen", .alltag), ("χθες", "chthes", "gestern", .alltag),
    ("τώρα", "tóra", "jetzt", .alltag), ("Πού;", "pu?", "Wo?", .alltag),
    ("Πόσο κάνει;", "póso káni?", "Was kostet das?", .alltag),
    ("είμαι", "íme", "ich bin", .verb), ("έχω", "écho", "ich habe", .verb), ("θέλω", "thélo", "ich will", .verb),
    ("μιλάω", "miláo", "ich spreche", .verb), ("καταλαβαίνω", "katalavéno", "ich verstehe", .verb),
    ("Δεν καταλαβαίνω", "den katalavéno", "Ich verstehe nicht", .verb),
    ("τρώω", "tróo", "ich esse", .verb), ("πίνω", "píno", "ich trinke", .verb),
    ("πάω", "páo", "ich gehe", .verb), ("μένω", "méno", "ich wohne", .verb),
    ("αγαπάω", "agapáo", "ich liebe", .verb), ("μαθαίνω", "mathéno", "ich lerne", .verb),
]
let words: [Word] = rawWords.enumerated().map { Word(id: $0.offset, gr: $0.element.0, tr: $0.element.1, de: $0.element.2, cat: $0.element.3) }

struct Letter { let upper: String; let lower: String; let name: String; let latin: String; let sound: String }
let letters: [Letter] = [
    .init(upper: "Α", lower: "α", name: "Άλφα", latin: "Alfa", sound: "a wie in „Vater“"),
    .init(upper: "Β", lower: "β", name: "Βήτα", latin: "Vita", sound: "w wie in „Wasser“"),
    .init(upper: "Γ", lower: "γ", name: "Γάμμα", latin: "Gamma", sound: "weiches gh; vor e/i wie j"),
    .init(upper: "Δ", lower: "δ", name: "Δέλτα", latin: "Delta", sound: "stimmhaftes th, engl. „this“"),
    .init(upper: "Ε", lower: "ε", name: "Έψιλον", latin: "Epsilon", sound: "e wie in „Bett“"),
    .init(upper: "Ζ", lower: "ζ", name: "Ζήτα", latin: "Zita", sound: "stimmhaftes s wie „Sonne“"),
    .init(upper: "Η", lower: "η", name: "Ήτα", latin: "Ita", sound: "i"),
    .init(upper: "Θ", lower: "θ", name: "Θήτα", latin: "Thita", sound: "stimmloses th, engl. „think“"),
    .init(upper: "Ι", lower: "ι", name: "Γιώτα", latin: "Jota", sound: "i"),
    .init(upper: "Κ", lower: "κ", name: "Κάππα", latin: "Kappa", sound: "k ohne Hauch"),
    .init(upper: "Λ", lower: "λ", name: "Λάμδα", latin: "Lamda", sound: "l"),
    .init(upper: "Μ", lower: "μ", name: "Μι", latin: "Mi", sound: "m"),
    .init(upper: "Ν", lower: "ν", name: "Νι", latin: "Ni", sound: "n"),
    .init(upper: "Ξ", lower: "ξ", name: "Ξι", latin: "Xi", sound: "ks"),
    .init(upper: "Ο", lower: "ο", name: "Όμικρον", latin: "Omikron", sound: "o"),
    .init(upper: "Π", lower: "π", name: "Πι", latin: "Pi", sound: "p ohne Hauch"),
    .init(upper: "Ρ", lower: "ρ", name: "Ρο", latin: "Ro", sound: "gerolltes r"),
    .init(upper: "Σ", lower: "σ/ς", name: "Σίγμα", latin: "Sigma", sound: "stimmloses s; ς am Wortende"),
    .init(upper: "Τ", lower: "τ", name: "Ταυ", latin: "Taf", sound: "t ohne Hauch"),
    .init(upper: "Υ", lower: "υ", name: "Ύψιλον", latin: "Ypsilon", sound: "i"),
    .init(upper: "Φ", lower: "φ", name: "Φι", latin: "Fi", sound: "f"),
    .init(upper: "Χ", lower: "χ", name: "Χι", latin: "Chi", sound: "ch wie „Bach“, vor e/i wie „ich“"),
    .init(upper: "Ψ", lower: "ψ", name: "Ψι", latin: "Psi", sound: "ps"),
    .init(upper: "Ω", lower: "ω", name: "Ωμέγα", latin: "Omega", sound: "o"),
]
let combos: [(String, String, String)] = [
    ("αι", "e", "και (und) → ke"),
    ("ει, οι, υι", "i", "είναι (ist) → íne"),
    ("ου", "u", "μου (mein) → mu"),
    ("αυ / ευ", "af / ef, vor stimmhaften Lauten av / ev", "ευχαριστώ → efcharistó"),
    ("μπ", "b, im Wort oft mb", "μπύρα (Bier) → bíra"),
    ("ντ", "d, im Wort oft nd", "ντομάτα → domáta"),
    ("γκ / γγ", "g, im Wort oft ng", "Αγγλία → Anglía"),
    ("τσ", "ts", "τσάι (Tee) → tsái"),
    ("τζ", "ds", "τζάμι (Glasscheibe) → dsámi"),
]
