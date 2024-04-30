import SwiftUI
import CoreData

struct SignUpView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Sign Up") {
                signUp()
            }
            .padding()
            Spacer()
        }
        .navigationTitle("Sign Up")
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Sign Up"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func signUp() {
        guard !username.isEmpty && !password.isEmpty else {
            alertMessage = "Username and password cannot be empty."
            showingAlert = true
            return
        }

        let newUser = User1(context: viewContext)
        newUser.username = username
        newUser.password = password

        do {
            try viewContext.save()
            alertMessage = "User saved to Core Data."
            showingAlert = true
            username = ""
            password = ""
        } catch {
            alertMessage = "Error saving user data: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}
