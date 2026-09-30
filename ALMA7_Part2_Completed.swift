// =============================================================
// Station ALMA-7, Part II: The Teleporter Incident
// Completed solution
// =============================================================

// MARK: - STARTER DATA

func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge", oxygen: 78),
    (deck: "lab", oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo", oxygen: 12),
    (deck: "medbay", oxygen: 90),
    (deck: "engine", oxygen: 41)
]

let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur", deck: "engine", oxygen: 62),
    (name: "Dana", deck: "lab", oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan", deck: "cargo", oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: Level 1 · The Deck Register

enum Deck: String, CaseIterable {
    case bridge
    case lab
    case cargo
    case medbay
    case engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab: return 3
        case .engine: return 4
        case .cargo: return 5
        }
    }
}

for deck in Deck.allCases {
    print("Deck \(deck.rawValue): priority \(deck.evacuationPriority)")
}

enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = min(max(mass / 500, 0), 3)
        return AlarmLevel(rawValue: step) ?? .green
    }
}

print("Alarm 0 kg: \(AlarmLevel.level(forTotalMass: 0))")
print("Alarm 940 kg: \(AlarmLevel.level(forTotalMass: 940))")
print("Alarm 4000 kg: \(AlarmLevel.level(forTotalMass: 4000))")

// MARK: Level 2 · The Manifest

enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    guard let tag = parts.first else {
        return .unknown(raw: line)
    }

    switch tag {
    case "crate":
        guard parts.count == 3,
              let id = Int(parts[1]),
              let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .crate(id: id, massKg: mass)

    case "container":
        guard parts.count == 3,
              let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .container(code: parts[1], massKg: mass)

    case "livestock":
        guard parts.count == 4,
              let count = Int(parts[2]),
              let massPerUnit = Int(parts[3]) else {
            return .unknown(raw: line)
        }
        return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnit)

    default:
        return .unknown(raw: line)
    }
}

func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case let .crate(_, massKg):
        return massKg
    case let .container(_, massKg):
        return massKg
    case let .livestock(_, count, massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

var totalManifestMass = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    totalManifestMass += mass(of: entry)
    if case .unknown = entry {
        unknownCount += 1
    }
}
let A = totalManifestMass
print("Manifest unknown lines: \(unknownCount)")
print("A (total manifest mass): \(A) kg")

// MARK: Level 3 · Crew Snapshots

struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

var crewRoster: [CrewSnapshot] = []
for record in crewData {
    if let deck = Deck(rawValue: record.deck) {
        crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    } else {
        print("Warning: unknown deck \(record.deck) for \(record.name); skipped.")
    }
}

for member in crewRoster {
    print("Crew: \(member.name), deck: \(member.deck.rawValue), oxygen: \(member.oxygen)")
}

func drainedCopy(_ member: CrewSnapshot) -> CrewSnapshot {
    var changed = member
    changed.breathe(10)
    return changed
}

func drainedInout(_ member: inout CrewSnapshot) {
    member.breathe(10)
}

if let original = crewRoster.first {
    var copy = original
    print("Value copy BEFORE: original oxygen = \(original.oxygen), copy oxygen = \(copy.oxygen)")
    copy.breathe(10)
    print("Value copy AFTER: original oxygen = \(original.oxygen), copy oxygen = \(copy.oxygen)")

    print("Plain function BEFORE: original oxygen = \(original.oxygen)")
    let changedCopy = drainedCopy(original)
    print("Plain function AFTER: original oxygen = \(original.oxygen), returned copy oxygen = \(changedCopy.oxygen)")

    var inoutCopy = original
    print("inout BEFORE: copy oxygen = \(inoutCopy.oxygen)")
    drainedInout(&inoutCopy)
    print("inout AFTER: copy oxygen = \(inoutCopy.oxygen)")
}

// MARK: Level 4 · The Teleport Pod

final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // CrewSnapshot is a struct with memberwise initialization; this class declares its own init.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else {
            return false
        }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let currentOccupant = occupant else {
            return nil
        }
        chargeLevel -= 20
        occupant = nil
        return currentOccupant
    }

    deinit {
        print("deinit fired for pod \(id)")
    }
}

let podP1 = TeleportPod(id: "P-1", chargeLevel: 100)

if let timur = crewRoster.first(where: { $0.name == "Timur" }) {
    print("Load Timur: \(podP1.load(timur)), charge = \(podP1.chargeLevel)")
    _ = podP1.fire()
    print("Fire Timur: charge = \(podP1.chargeLevel)")
}

if let dana = crewRoster.first(where: { $0.name == "Dana" }) {
    print("Load Dana: \(podP1.load(dana)), charge = \(podP1.chargeLevel)")
    _ = podP1.fire()
    print("Fire Dana: charge = \(podP1.chargeLevel)")
}

if let nurlan = crewRoster.first(where: { $0.name == "Nurlan" }) {
    print("Load Nurlan: \(podP1.load(nurlan)), charge = \(podP1.chargeLevel)")
    _ = podP1.fire()
    print("Fire Nurlan: charge = \(podP1.chargeLevel)")
}

_ = podP1.fire()
print("Fire empty pod: charge = \(podP1.chargeLevel)")
let C = podP1.chargeLevel
print("C (final pod charge): \(C)")

let podReferenceA = podP1
podReferenceA.chargeLevel = 10
print("Reference type: podP1 charge = \(podP1.chargeLevel)")
print("Reference type: podReferenceA charge = \(podReferenceA.chargeLevel)")

if let originalCrew = crewRoster.first {
    var crewCopy = originalCrew
    crewCopy.oxygen = 0
    print("Value type: original crew oxygen = \(originalCrew.oxygen)")
    print("Value type: copied crew oxygen = \(crewCopy.oxygen)")
}

// A class shares reference identity; a struct assignment creates an independent value.

// MARK: Level 5 · Station Systems

final class Station {
    let callSign: String
    var hullIntegrity: Int {
        willSet {
            print("Hull integrity transition: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            hullIntegrity = min(max(hullIntegrity, 0), 100)
        }
    }
    var oxygenByDeck: [Deck: Int]

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        var lines: [String] = []
        for (deck, oxygen) in oxygenByDeck {
            lines.append("\(deck.rawValue): \(oxygen)")
        }
        lines.sort()
        return lines.joined(separator: ", ")
    }()

    var totalOxygen: Int {
        var total = 0
        for oxygen in oxygenByDeck.values {
            total += oxygen
        }
        return total
    }

    var averageOxygen: Int {
        get {
            guard !oxygenByDeck.isEmpty else { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Deck.allCases {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, hullIntegrity: Int, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        self.oxygenByDeck = [:]
        for reading in readings {
            if let deck = Deck(rawValue: reading.deck) {
                self.oxygenByDeck[deck] = reading.oxygen
            }
        }
    }
}

let station = Station(callSign: "ALMA-7", hullIntegrity: 100, readings: deckReadings)
let B = station.averageOxygen
print("B (starting average oxygen): \(B)")
print("Diagnostics not accessed yet; no scan should have run before this line.")
print("First diagnostics: \(station.fullDiagnostics)")
print("Second diagnostics: \(station.fullDiagnostics)")

station.hullIntegrity = 130
print("Hull after 130: \(station.hullIntegrity)")
station.hullIntegrity = -40
print("Hull after -40: \(station.hullIntegrity)")
station.hullIntegrity = 55
print("Hull after 55: \(station.hullIntegrity)")

// didSet changes the stored value directly; assigning from inside didSet does not recursively trigger didSet.

// MARK: Level 6 · Incident Reports

// Report 1: expected roster oxygen to decrease, but loop variable is a copy of each struct.
var reportRoster = crewRoster
for var member in reportRoster {
    member.oxygen -= 10
}
print("Report 1 actual: \(reportRoster[0].oxygen)")

// Fix: mutate the array element through its index.
for index in reportRoster.indices {
    reportRoster[index].oxygen -= 10
}
print("Report 1 fixed: \(reportRoster[0].oxygen)")

// Report 2: expected podA to stay at 100, but classes have reference semantics.
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print("Report 2 actual: podA = \(podA.chargeLevel), podB = \(podB.chargeLevel)")

// Fix: create a separate object when an independent pod is needed.
let podFixedA = TeleportPod(id: "A", chargeLevel: 100)
let podFixedB = TeleportPod(id: "B", chargeLevel: 100)
podFixedB.chargeLevel = 0
print("Report 2 fixed: podFixedA = \(podFixedA.chargeLevel), podFixedB = \(podFixedB.chargeLevel)")

// Report 3: expected add() to compile, but a non-mutating struct method cannot change stored properties.
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var logbook = Logbook()
logbook.add("teleporter checked")
print("Report 3 fixed: entries = \(logbook.entries.count)")
print("Report 3 fixed entry: \(logbook.entries[0])")

// Report 4: struct let freezes the whole value; class let freezes the reference, not the object's mutable properties.
let snapshot = CrewSnapshot.rookie(named: "Dana")
// snapshot.oxygen = 40   // Error: cannot assign to property: 'snapshot' is a 'let' constant

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
print("Report 4 fixed/actual: snapshot oxygen = \(snapshot.oxygen), pod charge = \(pod.chargeLevel)")

// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {
    // private blocks all access to the stored entry list from outside FlightRecorder.
    private var entries: [String] = []

    // private(set) blocks external writes while allowing external reads of the state.
    private(set) var isSealed = false

    // internal allows normal access from elsewhere in this module.
    var entryCount: Int {
        return entries.count
    }

    // internal allows outside code to read a formatted transcript.
    var transcript: String {
        return entries.joined(separator: "\n")
    }

    // internal allows adding through the controlled method only.
    func add(_ entry: String) {
        guard !isSealed else { return }
        entries.append(entry)
    }

    // internal allows outside code to seal the recorder, but not unseal it.
    func seal() {
        isSealed = true
    }

    // fileprivate allows the free function in this file to inspect the private data indirectly.
    fileprivate func auditEntries() -> [String] {
        return entries
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    return recorder.auditEntries().joined(separator: " | ")
}

let recorder = FlightRecorder()
recorder.add("Transfer started")
recorder.add("Crew manifest verified")
print("Recorder entries: \(recorder.entryCount)")
print("Recorder transcript: \(recorder.transcript)")
print("Audit: \(auditTranscript(of: recorder))")
recorder.seal()
recorder.add("This entry must not be added")
print("Sealed recorder entries: \(recorder.entryCount)")
// recorder.entries.removeAll()   // Error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false       // Error: cannot assign to property: 'isSealed' setter is inaccessible

// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("D (alarm raw value): \(D)")
print("INTEGRITY CODE: \(integrityCode)")

// MARK: Bonus

var retainedPod: TeleportPod?
do {
    let temporaryPod = TeleportPod(id: "BONUS", chargeLevel: 50)
    retainedPod = temporaryPod
    let sameReference = temporaryPod
    print("Inside block: same identity = \(temporaryPod === sameReference)")
    print("Inside block: second reference retained")
}
print("After block: deinit has not fired because retainedPod still holds the pod")
retainedPod = nil
print("After releasing retainedPod: deinit fires when the last reference is released")

func samePod(_ first: TeleportPod, _ second: TeleportPod) -> Bool {
    return first === second
}

let identityPodA = TeleportPod(id: "X", chargeLevel: 100)
let identityPodB = identityPodA
let identityPodC = TeleportPod(id: "X", chargeLevel: 100)
print("Identity A/B: \(samePod(identityPodA, identityPodB))")
print("Identity A/C: \(samePod(identityPodA, identityPodC))")
// CrewSnapshot cannot be used with === because it is a struct/value type, not a class/reference type.

// MARK: Defense Questions
/*
1. CrewSnapshot is a struct whose stored properties have default values only where needed, so Swift provides a memberwise
   initializer. TeleportPod is a class with its own initialization requirements, so we write init(id:chargeLevel:) ourselves.

2. mutating allows a struct method to change self or its stored properties. Struct methods are non-mutating by default because
   structs have value semantics. Classes use reference semantics, so class instance methods can mutate properties without mutating.

3. For a struct, let makes the entire value immutable, so snapshot.oxygen = 40 is an error. For a class, let makes the reference
   itself constant: pod cannot be made to refer to another TeleportPod, but pod.chargeLevel can still change because the object is mutable.

4. A lazy property must be var because its value is initialized later, on first access, and that stored value has to be written.
   Lazy changes behaviour when initialization has side effects or depends on state that may change before the first access; for
   example, a lazy diagnostics property can see the station's current oxygen readings only when diagnostics are first requested.

5. private would be too strict for auditEntries because auditTranscript is a free function outside FlightRecorder. fileprivate lets
   that helper be called from anywhere in the same source file while keeping it inaccessible from other files/modules.

Bonus. deinit runs when the last strong reference to a class instance is released. In the block above, the second reference is kept
   in retainedPod, so leaving the do block does not destroy the pod. deinit fires when retainedPod is set to nil. The === operator
   compares identity of class instances; CrewSnapshot cannot use === because it is a struct/value type.
*/
