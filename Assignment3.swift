// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          let value = Int(parts.1),
          !parts.0.isEmpty,
          value >= 0 || parts.0 == "TEMP"
    else {
        return nil
    }

    return (sensor: parts.0, value: value)
}

// Tests
print("parseReading 1:", parseReading("O2:87") as Any)
print("parseReading 2:", parseReading("TEMP:-12") as Any)
print("parseReading 3:", parseReading("RAD:-1") as Any)
print("parseReading 4:", parseReading(":55") as Any)


// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0

    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }

    return (valid: valid, invalidCount: invalidCount)
}

let parsedLog = parseLog(rawLog)
let parsedLogTest = parseLog(["O2:50", "BROKEN"])
print("parseLog 1:", parsedLog.valid)
print("parseLog 2: invalid =", parsedLog.invalidCount)
print("parseLog test 2:", parsedLogTest)

let A = parsedLog.invalidCount


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var selected: [Reading] = []

    for reading in readings {
        if isIncluded(reading) {
            selected.append(reading)
        }
    }

    return selected
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []

    for reading in readings {
        result.append(reading.value)
    }

    return result
}

let o2Readings = select(parsedLog.valid) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)

print("select 1:", o2Readings)
print("select 2:", o2Values)


// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else {
        return nil
    }

    var minValue = first
    var maxValue = first
    var sum = 0

    for value in values {
        if value < minValue {
            minValue = value
        }

        if value > maxValue {
            maxValue = value
        }

        sum += value
    }

    return (min: minValue, max: maxValue, average: Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

// Tests
print("stats array 1:", stats(of: [3, 8, 1]) as Any)
print("stats array 2:", stats(of: []) as Any)
print("stats variadic 1:", stats(3, 8, 1) as Any)
print("stats variadic 2:", stats() as Any)

let B = Int(stats(of: o2Values)?.average ?? 0)


// 2.3 · The Closure Ladder (5 sorts, then compare results in code)

let sorted1 = parsedLog.valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})

let sorted2 = parsedLog.valid.sorted(by: { (a, b) in
    return a.value > b.value
})

let sorted3 = parsedLog.valid.sorted(by: { a, b in
    a.value > b.value
})

let sorted4 = parsedLog.valid.sorted(by: {
    $0.value > $1.value
})

let sorted5 = parsedLog.valid.sorted {
    $0.value > $1.value
}

var closureLadderMatches = sorted1.count == sorted2.count &&
                            sorted2.count == sorted3.count &&
                            sorted3.count == sorted4.count &&
                            sorted4.count == sorted5.count

if closureLadderMatches {
    for index in 0..<sorted1.count {
        if sorted1[index].sensor != sorted2[index].sensor ||
           sorted1[index].value != sorted2[index].value ||
           sorted2[index].sensor != sorted3[index].sensor ||
           sorted2[index].value != sorted3[index].value ||
           sorted3[index].sensor != sorted4[index].sensor ||
           sorted3[index].value != sorted4[index].value ||
           sorted4[index].sensor != sorted5[index].sensor ||
           sorted4[index].value != sorted5[index].value {
            closureLadderMatches = false
            break
        }
    }
}

print("Closure ladder 1:", sorted1)
print("Closure ladder 2:", sorted2)
print("Closure ladder 3:", sorted3)
print("Closure ladder 4:", sorted4)
print("Closure ladder 5:", sorted5)
print("All five closure results match:", closureLadderMatches)


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int {
    t + 5
}

func coolDown(_ t: Int) -> Int {
    t - 3
}

func hold(_ t: Int) -> Int {
    t
}

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

// Tests
print("heatUp 1:", heatUp(10))
print("heatUp 2:", heatUp(20))
print("coolDown 1:", coolDown(30))
print("coolDown 2:", coolDown(24))
print("hold 1:", hold(20))
print("hold 2:", hold(24))
print("chooseProtocol 1:", chooseProtocol(for: 10)(10))
print("chooseProtocol 2:", chooseProtocol(for: 30)(30))


// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temperature = start
    var steps = 0

    while (temperature < 18 || temperature > 24) && steps < maxSteps {
        let selectedProtocol = chooseProtocol(for: temperature)
        temperature = selectedProtocol(temperature)
        steps += 1
    }

    return (finalTemp: temperature,
            steps: steps,
            isStable: temperature >= 18 && temperature <= 24)
}

// Tests
print("runUntilStable 1:", runUntilStable(from: 31))
print("runUntilStable 2:", runUntilStable(from: -100, maxSteps: 5))

let temperatureReadings = select(parsedLog.valid) {
    $0.sensor == "TEMP"
}
let lowestTemperature = stats(of: values(of: temperatureReadings))?.min ?? 0
let C = runUntilStable(from: lowestTemperature).steps


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

// Tests
print("oxygenLevel 1:", oxygenLevel(of: crew[0]) as Any)
print("oxygenLevel 2:", oxygenLevel(of: crew[1]) as Any)
print("oxygenLevel 3:", oxygenLevel(of: crew[2]) as Any)
print("oxygenLevel 4:", oxygenLevel(of: crew[3]) as Any)


// 4.2
func status(of member: CrewMember) -> String {
    guard let module = member.module else {
        return "\(member.name): no data (open space)"
    }

    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(module.name))"
    }

    let condition = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(condition)"
}

for member in crew {
    print(status(of: member))
}


// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else {
        return 0
    }

    let transferable = min(amount, source, 100 - target)
    guard transferable > 0 else {
        return 0
    }

    source -= transferable
    target += transferable

    return transferable
}

var labOxygen = lab.oxygenTank?.level ?? 0
var habOxygen = hab.oxygenTank?.level ?? 0

let transferred = transferOxygen(from: &labOxygen, to: &habOxygen, amount: 30)

if let labTank = lab.oxygenTank {
    labTank.level = labOxygen
}

if let habTank = hab.oxygenTank {
    habTank.level = habOxygen
}

print("transferOxygen 1: transferred =", transferred)
print("transferOxygen 2: Lab =", labOxygen, "Hab =", habOxygen)

var testSource = 5
var testTarget = 98
let secondTransfer = transferOxygen(from: &testSource, to: &testTarget, amount: 10)
print("transferOxygen test 2: transferred =", secondTransfer, "source =", testSource, "target =", testTarget)

let D = habOxygen


// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []

    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }

        found.append(member)
    }

    found.sort { $0.priority < $1.priority }

    var result: [String] = []
    for member in found {
        result.append(member.name)
    }

    return result
}

// Tests
print("evacuationOrder 1:", evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
print("evacuationOrder 2:", evacuationOrder("Nurlan", "Timur", "Aigerim", roster: roster))


// MARK: Level 5 · The Saboteur's Logbook
// Problems in the original code:
// 1. member.module! crashes if the crew member has no module.
//    Example: Nurlan has module == nil, so accessing module! traps at runtime.
// 2. member.module!.oxygenTank! crashes if the module exists but has no oxygen tank.
//    Example: Dana is in Dock, whose oxygenTank is nil.
// 3. oxygenLevel(of: member)! crashes when there is no oxygen data.
//    Example: Dana and Nurlan both produce nil.
// 4. result! crashes when nobody is critical, because result is still nil.
//    Example: a crew array where every member has oxygen >= 20 or no oxygen data.
// 5. The loop keeps replacing result, so the function returns the LAST critical
//    member instead of the FIRST critical member.
//    This is a logic bug, even when no force unwrap crashes.
// 6. The original return type is String, but a correct "no critical member"
//    result needs to be String?, because there may be no matching member.

func reportOxygen(for member: CrewMember) -> String {
    guard let module = member.module,
          let tank = module.oxygenTank
    else {
        return "\(member.name): no data"
    }

    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member) else {
            continue
        }

        if level < 20 {
            return member.name
        }
    }

    return nil
}

// Tests
print("reportOxygen 1:", reportOxygen(for: crew[0]))
print("reportOxygen 2:", reportOxygen(for: crew[1]))
print("reportOxygen 3:", reportOxygen(for: crew[3]))

print("firstCritical 1:", firstCritical(in: crew) as Any)

let secondCritical = CrewMember(
    name: "TestCritical",
    role: "Technician",
    priority: 5,
    module: Module(name: "Test", oxygenTank: Tank(level: 10))
)

let multipleCritical = [secondCritical, crew[2]]
print("firstCritical 2 (logic-bug test):", firstCritical(in: multipleCritical) as Any)

let safeCrew = [
    CrewMember(
        name: "Safe",
        role: "Engineer",
        priority: 1,
        module: Module(name: "Safe", oxygenTank: Tank(level: 50))
    )
]
print("firstCritical 3 (no critical member):", firstCritical(in: safeCrew) as Any)


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0

    return { oxygen in
        if oxygen < threshold {
            count += 1
            print("Alarm #\(count) → true")
            return true
        }

        return false
    }
}

let alarm = makeAlarm(threshold: 20)
print("alarm test 1:", alarm(12))
print("alarm test 2:", alarm(40))
print("alarm test 3:", alarm(5))


// MARK: - ================= DEFENSE QUESTIONS =================
/*
1. guard let vs if let beyond syntax:
   guard is for a condition that must be true to continue. Its else block
   must leave the current scope. This keeps the main code unindented.
   Example: guard let member = roster[name] else { continue }.

2. Why can't you pass [Int] to stats(_ values: Int...)?:
   Int... means a variadic parameter that accepts separate Int arguments,
   not one [Int] array. stats(1, 2, 3) works; stats([1, 2, 3]) does not.
   The array version has a different signature: stats(of: [Int]).

3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?:
   The same variable cannot be passed as two simultaneous inout arguments.
   This prevents overlapping mutable access and ambiguous changes to the
   same storage during one function call.

4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?:
   oxygenLevel returns Int?, so ?? needs another Int on the right side.
   "no data" is a String. For example:
   let level = oxygenLevel(of: dana) ?? 0

5. Full type of chooseProtocol and how to read it:
   (Int) -> (Int) -> Int
   It takes an Int and returns a function whose type is (Int) -> Int.
   In this task, chooseProtocol(for:) takes a temperature and returns
   the selected temperature-changing protocol.

Bonus. Where does the alarm counter live after makeAlarm returns?:
   The returned closure captures the local variable count. Swift keeps
   the captured storage alive as long as the closure needs it, so count
   still exists after makeAlarm has returned.
*/