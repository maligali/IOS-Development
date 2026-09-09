let firstName = "Malika"
let lastName = "Jumagaliyeva"

let birthYear = 2006
let currentYear = 2026
let age = currentYear - birthYear

let isStudent = true
let height = 1.53

let hobby = "solving sudoku"
let numberOfHobbies = 5
let favoriteNumber = 21
let isHobbyCreative = false

let futureGoals = "I want to achieve a successful career."

let studentStatus: String

if isStudent {
    studentStatus = "I am currently a student"
} else {
    studentStatus = "I am not currently a student"
}

let hobbyStatus: String

if isHobbyCreative {
    hobbyStatus = "is a creative hobby"
} else {
    hobbyStatus = "is not a creative hobby"
}

let lifeStory = "My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear). \(studentStatus). My height is \(height) meters. I enjoy \(hobby), which \(hobbyStatus). I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber). In the future, \(futureGoals)"

print(lifeStory)