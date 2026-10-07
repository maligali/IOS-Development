// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Power Cell

// A class is appropriate because the same mutable cell can be shared by reference.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(100, max(0, charge))
    }

    func level() -> Int { charge }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, charge >= amount else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(100, charge + amount)
    }
}

let cell = PowerCell(charge: 80)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

class Drone {
    let id: String
    let cell: PowerCell
    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }
    var statusLine: String { "\(id): \(cell.level())% \(cell.level().powerBar)" }
    func performTask() -> Int { 0 }

    // final prevents subclasses from changing the shift ritual.
    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String { "seam welded by \(id)" }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override var statusLine: String { super.statusLine + " [scanner]" }
    override func performTask() -> Int { 15 }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder": return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo": return CargoDrone(id: id, cell: cell)
    default: return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Warning: skipped unknown drone kind \(record.kind) (\(record.id)).")
    }
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    if rounds > 0 {
        for _ in 0..<rounds {
            for drone in fleet {
                total += drone.runOnce()
            }
        }
    }
    return total
}

let A = runShift(fleet, rounds: 3)

for drone in fleet {
    print(drone.statusLine)
}

var B = 0
var C = 0
for drone in fleet {
    B += drone.cell.level()
    if drone.cell.level() >= drone.powerCost {
        C += 1
    }
}
print("Remaining charge: \(B)")
print("Drones able to run one more task: \(C)")


// MARK: Level 4 · Diagnostics

protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

extension Drone: Rechargeable {
    // Classes have reference semantics, so mutating is not written here.
    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let componentID: String
    var chargeLevel: Int

    var statusCode: Int { chargeLevel.healthStatusCode }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(100, chargeLevel + amount)
    }
}

// [Drone] could never hold SensorModule because sensors are structs, not Drone subclasses.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components {
        lines.append(component.diagnose())
    }
    return lines.joined(separator: "\n")
}


// MARK: Level 5 · Shared Behaviour

extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }
}

// The Health Rule lives exactly once, here.
extension Int {
    var healthStatusCode: Int {
        let value = Swift.max(0, Swift.min(100, self))
        if value < 20 { return 2 }
        if value < 50 { return 1 }
        return 0
    }

    var powerBar: String {
        let value = Swift.max(0, Swift.min(100, self))
        let full = value / 10
        return String(repeating: "#", count: full) +
               String(repeating: ".", count: 10 - full)
    }
}

extension Drone: Diagnosable {
    var componentID: String { id }
    var statusCode: Int { cell.level().healthStatusCode }
}

extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { signalStrength.healthStatusCode }

    func diagnose() -> String {
        "\(componentID): legacy beacon code \(statusCode)"
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(componentID: record.id, chargeLevel: record.charge))
}

var diagnosticComponents: [Diagnosable] = []
for drone in fleet { diagnosticComponents.append(drone) }
for sensor in sensors { diagnosticComponents.append(sensor) }
diagnosticComponents.append(beacon)

print(diagnosticsReport(diagnosticComponents))

var D = 0
for component in diagnosticComponents {
    D += component.statusCode
}

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Level 6 · Incident Reports
/*
Report 1:
PatchDrone compiles. It can override performTask() if desired.

Report 2:
HeavyWelder does not compile because WelderDrone is final.
Fix: remove final from WelderDrone if subclassing is required.

Report 3:
A Drone-typed value cannot directly call weldSeam(), because that member
belongs only to WelderDrone. Fix:
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}
as? returns an optional because the runtime cast may fail.

Report 4:
It prints "generic component". label() is only in the protocol extension,
not a protocol requirement, so a protocol-typed value uses the extension
implementation. Add func label() -> String to Labelled to get dynamic
dispatch to Thruster's implementation.
*/


// MARK: Bonus
/*
Runtime approach: make direct Drone use trap with preconditionFailure().
Compile-time approach: expose a protocol abstraction instead of a concrete
base class. A protocol + structs avoids inheritance, while the class design
is convenient here because drones share mutable PowerCell reference state.
*/


// MARK: - ================= DEFENSE QUESTIONS =================
/*
1. A class has reference semantics, so changing referenced state does not
require mutating. A struct has value semantics, so a mutating method is needed.

2. Inheritance can share stored state and superclass implementation.
Protocols can be adopted by unrelated classes and structs.

3. final prevents subclassing a final class or overriding a final member.
final runOnce() protects the common shift ritual from being changed.

4. label() was not a protocol requirement; it existed only in the extension.
Therefore the protocol-typed value used the extension implementation.
*/
