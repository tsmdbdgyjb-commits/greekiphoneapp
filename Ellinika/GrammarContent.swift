import Foundation

struct Exercise { let sentence: String; let german: String; let answer: String; let wrong: [String] }
struct GTable { let title: String; let rows: [[String]] }
struct Lesson: Identifiable {
    let id: String; let title: String; let subtitle: String
    let intro: String; let tables: [GTable]; let tip: String?
    let exercises: [Exercise]
}

let lessons: [Lesson] = [
    Lesson(id: "artikel", title: "Der bestimmte Artikel", subtitle: "ο, η, το – männlich, weiblich, sächlich",
        intro: "Griechische Nomen haben drei Geschlechter wie im Deutschen. Das Geschlecht erkennst du meist an der Endung.",
        tables: [GTable(title: "Artikel im Nominativ", rows: [["", "Singular", "Plural"], ["männlich", "ο", "οι"], ["weiblich", "η", "οι"], ["sächlich", "το", "τα"]]),
                 GTable(title: "Typische Endungen", rows: [["männlich", "-ος, -ας, -ης", "ο δρόμος, ο πατέρας"], ["weiblich", "-α, -η", "η θάλασσα, η πόλη"], ["sächlich", "-ο, -ι, -μα", "το νερό, το σπίτι, το όνομα"]])],
        tip: "Das Geschlecht stimmt oft nicht mit dem Deutschen überein: η θάλασσα ist weiblich, das Meer sächlich.",
        exercises: [
            .init(sentence: "___ δρόμος", german: "die Straße", answer: "ο", wrong: ["η", "το"]),
            .init(sentence: "___ θάλασσα", german: "das Meer", answer: "η", wrong: ["ο", "το"]),
            .init(sentence: "___ σπίτι", german: "das Haus", answer: "το", wrong: ["ο", "η"]),
            .init(sentence: "___ πατέρας", german: "der Vater", answer: "ο", wrong: ["η", "το"]),
            .init(sentence: "___ πόλη", german: "die Stadt", answer: "η", wrong: ["ο", "το"]),
            .init(sentence: "___ νερό", german: "das Wasser", answer: "το", wrong: ["ο", "η"]),
            .init(sentence: "___ όνομα", german: "der Name", answer: "το", wrong: ["ο", "η"]),
            .init(sentence: "___ φίλοι", german: "die Freunde", answer: "οι", wrong: ["τα", "ο"]),
            .init(sentence: "___ παιδιά", german: "die Kinder", answer: "τα", wrong: ["οι", "το"]),
        ]),
    Lesson(id: "eimai", title: "είμαι – sein", subtitle: "Das wichtigste Verb, unregelmäßig",
        intro: "Personalpronomen lässt man im Griechischen meist weg, weil die Verbendung die Person schon zeigt: είμαι heißt allein schon „ich bin“.",
        tables: [GTable(title: "Präsens", rows: [["εγώ", "είμαι", "ich bin"], ["εσύ", "είσαι", "du bist"], ["αυτός / αυτή / αυτό", "είναι", "er / sie / es ist"], ["εμείς", "είμαστε", "wir sind"], ["εσείς", "είστε", "ihr seid / Sie sind"], ["αυτοί / αυτές / αυτά", "είναι", "sie sind"]])],
        tip: "εσείς ist auch die höfliche Anrede: Είστε από την Ελλάδα; – Sind Sie aus Griechenland?",
        exercises: [
            .init(sentence: "Εγώ ___ από τη Γερμανία.", german: "Ich bin aus Deutschland.", answer: "είμαι", wrong: ["είναι", "είσαι"]),
            .init(sentence: "Εσύ ___ φοιτητής;", german: "Bist du Student?", answer: "είσαι", wrong: ["είμαι", "είστε"]),
            .init(sentence: "Η Μαρία ___ δασκάλα.", german: "Maria ist Lehrerin.", answer: "είναι", wrong: ["είμαι", "είμαστε"]),
            .init(sentence: "Εμείς ___ φίλοι.", german: "Wir sind Freunde.", answer: "είμαστε", wrong: ["είστε", "είναι"]),
            .init(sentence: "Εσείς ___ κουρασμένοι;", german: "Seid ihr müde?", answer: "είστε", wrong: ["είσαι", "είμαστε"]),
            .init(sentence: "Τα παιδιά ___ στο σπίτι.", german: "Die Kinder sind zu Hause.", answer: "είναι", wrong: ["είστε", "είμαι"]),
        ]),
    Lesson(id: "verbA", title: "Verben auf -ω", subtitle: "έχω, θέλω, μένω, πίνω …",
        intro: "Die meisten Verben enden in der Grundform (1. Person) auf -ω. Den Stamm erhältst du, wenn du -ω abschneidest, dann hängst du die Endungen an.",
        tables: [GTable(title: "έχω – haben", rows: [["εγώ", "έχω", "-ω"], ["εσύ", "έχεις", "-εις"], ["αυτός", "έχει", "-ει"], ["εμείς", "έχουμε", "-ουμε"], ["εσείς", "έχετε", "-ετε"], ["αυτοί", "έχουν", "-ουν"]])],
        tip: "Statt -ουν hört man im Alltag oft -ουνε: έχουνε.",
        exercises: [
            .init(sentence: "Εγώ ___ έναν αδερφό.", german: "Ich habe einen Bruder.", answer: "έχω", wrong: ["έχει", "έχεις"]),
            .init(sentence: "Εσύ ___ καφέ;", german: "Willst du Kaffee?", answer: "θέλεις", wrong: ["θέλω", "θέλουμε"]),
            .init(sentence: "Η Άννα ___ στην Αθήνα.", german: "Anna wohnt in Athen.", answer: "μένει", wrong: ["μένω", "μένετε"]),
            .init(sentence: "Εμείς ___ νερό.", german: "Wir trinken Wasser.", answer: "πίνουμε", wrong: ["πίνετε", "πίνουν"]),
            .init(sentence: "Εσείς ___ παιδιά;", german: "Haben Sie Kinder?", answer: "έχετε", wrong: ["έχουμε", "έχεις"]),
            .init(sentence: "Αυτοί ___ ελληνικά.", german: "Sie lernen Griechisch.", answer: "μαθαίνουν", wrong: ["μαθαίνει", "μαθαίνετε"]),
            .init(sentence: "Ο Νίκος ___ κρασί.", german: "Nikos trinkt Wein.", answer: "πίνει", wrong: ["πίνεις", "πίνω"]),
        ]),
    Lesson(id: "verbB", title: "Verben auf -άω", subtitle: "μιλάω, αγαπάω, πάω …",
        intro: "Eine zweite große Gruppe betont die Endung: -άω. Die Betonung bleibt auf der Endung.",
        tables: [GTable(title: "μιλάω – sprechen", rows: [["εγώ", "μιλάω", "-άω"], ["εσύ", "μιλάς", "-άς"], ["αυτός", "μιλάει", "-άει"], ["εμείς", "μιλάμε", "-άμε"], ["εσείς", "μιλάτε", "-άτε"], ["αυτοί", "μιλάνε", "-άνε"]])],
        tip: "Daneben gibt es Kurzformen: μιλώ, μιλά, μιλούν. Beide sind richtig.",
        exercises: [
            .init(sentence: "Εγώ ___ λίγα ελληνικά.", german: "Ich spreche ein bisschen Griechisch.", answer: "μιλάω", wrong: ["μιλάς", "μιλάνε"]),
            .init(sentence: "Εσύ ___ γερμανικά;", german: "Sprichst du Deutsch?", answer: "μιλάς", wrong: ["μιλάει", "μιλάτε"]),
            .init(sentence: "Ο Γιώργος ___ πολύ.", german: "Giorgos redet viel.", answer: "μιλάει", wrong: ["μιλάω", "μιλάμε"]),
            .init(sentence: "Εμείς ___ την Ελλάδα.", german: "Wir lieben Griechenland.", answer: "αγαπάμε", wrong: ["αγαπάτε", "αγαπάει"]),
            .init(sentence: "Εσείς ___ αγγλικά;", german: "Sprechen Sie Englisch?", answer: "μιλάτε", wrong: ["μιλάμε", "μιλάς"]),
            .init(sentence: "Πού ___;", german: "Wohin gehst du?", answer: "πας", wrong: ["πάω", "πάνε"]),
        ]),
    Lesson(id: "fragen", title: "Fragen und Verneinung", subtitle: "δεν, τι, πού, πώς, πότε …",
        intro: "Verneint wird mit δεν direkt vor dem Verb. Das griechische Fragezeichen sieht aus wie ein Semikolon: ;",
        tables: [GTable(title: "Fragewörter", rows: [["τι", "was"], ["πού", "wo / wohin"], ["πώς", "wie"], ["πότε", "wann"], ["ποιος / ποια / ποιο", "wer / welche(r)"], ["γιατί", "warum"], ["πόσο", "wie viel"]]),
                 GTable(title: "Verneinung", rows: [["Θέλω καφέ.", "Ich will Kaffee."], ["Δεν θέλω καφέ.", "Ich will keinen Kaffee."]])],
        tip: "Achte auf den Akzent: πού (wo) ist eine Frage, που ohne Akzent heißt „der/die/das“ im Relativsatz.",
        exercises: [
            .init(sentence: "___ μένεις;", german: "Wo wohnst du?", answer: "Πού", wrong: ["Τι", "Πότε"]),
            .init(sentence: "___ σε λένε;", german: "Wie heißt du?", answer: "Πώς", wrong: ["Πού", "Γιατί"]),
            .init(sentence: "___ θέλεις;", german: "Was möchtest du?", answer: "Τι", wrong: ["Ποιος", "Πώς"]),
            .init(sentence: "___ έρχεσαι;", german: "Wann kommst du?", answer: "Πότε", wrong: ["Πόσο", "Τι"]),
            .init(sentence: "___ κάνει;", german: "Wie viel kostet das?", answer: "Πόσο", wrong: ["Πότε", "Πού"]),
            .init(sentence: "___ καταλαβαίνω.", german: "Ich verstehe nicht.", answer: "Δεν", wrong: ["Όχι", "Μη"]),
            .init(sentence: "___ είναι αυτός;", german: "Wer ist das?", answer: "Ποιος", wrong: ["Πώς", "Πού"]),
        ]),
    Lesson(id: "plural", title: "Plural der Nomen", subtitle: "οι δρόμοι, οι πόλεις, τα σπίτια",
        intro: "Die Pluralendung hängt von Geschlecht und Singularendung ab. Diese Muster decken die meisten Wörter ab.",
        tables: [GTable(title: "Muster", rows: [["-ος → -οι", "ο δρόμος → οι δρόμοι"], ["-ας → -ες", "ο πατέρας → οι πατέρες"], ["-α → -ες", "η θάλασσα → οι θάλασσες"], ["-η → -εις", "η πόλη → οι πόλεις"], ["-ο → -α", "το νερό → τα νερά"], ["-ι → -ια", "το σπίτι → τα σπίτια"], ["-μα → -ματα", "το όνομα → τα ονόματα"]])],
        tip: nil,
        exercises: [
            .init(sentence: "ο δρόμος → οι ___", german: "die Straßen", answer: "δρόμοι", wrong: ["δρόμες", "δρόμα"]),
            .init(sentence: "η πόλη → οι ___", german: "die Städte", answer: "πόλεις", wrong: ["πόλες", "πόλοι"]),
            .init(sentence: "το σπίτι → τα ___", german: "die Häuser", answer: "σπίτια", wrong: ["σπίτες", "σπίτοι"]),
            .init(sentence: "η θάλασσα → οι ___", german: "die Meere", answer: "θάλασσες", wrong: ["θάλασσοι", "θάλασσα"]),
            .init(sentence: "ο πατέρας → οι ___", german: "die Väter", answer: "πατέρες", wrong: ["πατέροι", "πατέρια"]),
            .init(sentence: "το βουνό → τα ___", german: "die Berge", answer: "βουνά", wrong: ["βουνοί", "βουνές"]),
            .init(sentence: "το όνομα → τα ___", german: "die Namen", answer: "ονόματα", wrong: ["όνομες", "ονόμια"]),
        ]),
]
