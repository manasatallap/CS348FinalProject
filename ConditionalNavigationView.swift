import SwiftUI

struct ConditionalNavigationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                if authViewModel.isAuthenticated {
                    CycleDataEntryView()
                } else {
                    ContentView()
                }
            }
        }
    }
}
