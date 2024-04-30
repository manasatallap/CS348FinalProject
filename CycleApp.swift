import SwiftUI
import CoreData

@main
struct CycleApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                CycleDataEntryView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(authViewModel)
            } else {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(authViewModel)
            }
        }
    }
}


class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User1?
}




