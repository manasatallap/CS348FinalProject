import Foundation

struct User {
    var username: String
    var password: String
    var birthdate: Date
    var name: String
}

// Function to create a new user data entry
func createUserEntry(username: String, password: String, birthdate: String, name: String) -> User? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd"
    guard let birthdate = dateFormatter.date(from: birthdate) else {
        print("Invalid birthdate format. Please use yyyy/MM/dd.")
        return nil
    }
    
    let newUser = User(username: username, password: password, birthdate: birthdate, name: name)
    // Here you would typically add the newUser to your database
    // For example: database.insert(newUser)
    return newUser
}

// Function to get user input from the command line
func getInput(prompt: String) -> String? {
    print(prompt, terminator: ": ")
    return readLine()
}

// Get user input
if let username = getInput(prompt: "Enter username"),
   let password = getInput(prompt: "Enter password"),
   let birthdate = getInput(prompt: "Enter birthdate (yyyy/MM/dd)"),
   let name = getInput(prompt: "Enter full name") {
    
    if let user = createUserEntry(username: username, password: password, birthdate: birthdate, name: name) {
        // Proceed with the new user data...
        print("User created successfully: \(user)")
    }
} else {
    print("Failed to get user input.")
}

