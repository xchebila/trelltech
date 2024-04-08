import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authenticator: TrelloAuthenticator
    @State private var showSuccessView = true
    @StateObject var dataManager = TrelloAPIManager()
    @State private var showWebView = false
    @State private var authRequest: URLRequest?

    var body: some View {
        NavigationView {
            if authenticator.isAuthenticated {
                if showSuccessView {
                    SuccessView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.showSuccessView = false
                                self.dataManager.fetchWorkspaces()
                            }
                        }
                } else {
                    WorkspacesView()
                        .environmentObject(dataManager)
                }
            } else {
                LoginView()
                }
            }
        }
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(TrelloAuthenticator())
    }
}
