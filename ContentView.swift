import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authViewModel: AuthViewModel
    @FetchRequest(entity: User1.entity(), sortDescriptors: [], predicate: nil) var users: FetchedResults<User1>

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isShowingSignUp = false
    @State private var isChangingPassword = false
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var passwordChangeError = false
    @State private var isAuthenticated = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Login") {
                    login()
                }
                .padding()
                Button("Change Password") {
                    isChangingPassword.toggle()
                }
                .padding()
                NavigationLink(destination: SignUpView(), isActive: $isShowingSignUp) {
                    Text("Don't have an account? Sign Up")
                }
                .padding()
                List {
                    ForEach(users, id: \.self) { user in
                        Text(user.username ?? "Unknown Username")
                        Button("Delete") {
                            deleteUser(user)
                        }
                    }
                }
                Spacer()
                NavigationLink(destination: ContentView(), isActive: $isAuthenticated) { EmptyView() }
            }
            .navigationTitle("Login")
            .alert(isPresented: $passwordChangeError) {
                Alert(title: Text("Error"), message: Text("Password change failed"), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $isChangingPassword) {
                ChangePasswordView()
            }
        }
    }

    private func login() {
        let predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)
        let filteredUsers = users.filter { predicate.evaluate(with: $0) }
        if let user = filteredUsers.first {
            print("Login successful")
            isAuthenticated = true
            authViewModel.currentUser = user
            authViewModel.isAuthenticated = true
        } else {
            print("Login failed")
        }
    }


    private func deleteUser(_ user: User1) {
        viewContext.delete(user)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting user: \(error.localizedDescription)")
        }
    }
}
