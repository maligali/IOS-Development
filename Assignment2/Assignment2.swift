import Foundation



// 1. Array Creation and Access
let fruits = ["Apple", "Banana", "Cherry", "Mango", "Orange"]
print("1. Third fruit:", fruits[2])


// 2. Set Creation and Manipulation
var favoriteNumbers: Set = [7, 13, 21, 42]
favoriteNumbers.insert(100)
print("2. Updated set:", favoriteNumbers)


// 3. Dictionary Creation and Access
let programmingLanguages = [
    "Swift": 2014,
    "Python": 1991,
    "Java": 1995
]
print("3. Swift release year:", programmingLanguages["Swift"]!)


// 4. Array Element Update
var colors = ["Red", "Blue", "Green", "Yellow"]
colors[1] = "Purple"
print("4. Updated colors:", colors)




// 1. Set Intersection
let firstSet: Set = [1, 2, 3, 4]
let secondSet: Set = [3, 4, 5, 6]
let intersection = firstSet.intersection(secondSet)
print("5. Intersection:", intersection)


// 2. Dictionary Update
var studentScores = [
    "Alice": 85,
    "Bob": 90,
    "Charlie": 78
]
studentScores.updateValue(95, forKey: "Bob")
print("6. Updated student scores:", studentScores)


// 3. Array Merge
let firstFruits = ["apple", "banana"]
let secondFruits = ["cherry", "date"]
let mergedFruits = firstFruits + secondFruits
print("7. Merged array:", mergedFruits)




// 1. Dictionary Key Addition
var countryPopulations = [
    "Kazakhstan": 20_000_000,
    "USA": 340_000_000,
    "Japan": 123_000_000
]
countryPopulations["Canada"] = 40_000_000
print("8. Updated country populations:", countryPopulations)


// 2. Set Union and Subtract
let animals1: Set = ["cat", "dog"]
let animals2: Set = ["dog", "mouse"]

let union = animals1.union(animals2)
let finalSet = union.subtracting(animals2)

print("9. Final set:", finalSet)


// 3. Nested Collection
let studentGrades = [
    "Alice": [85, 90, 78],
    "Bob": [88, 92, 95],
    "Charlie": [75, 80, 85]
]

print("10. Alice's second grade:", studentGrades["Alice"]![1])