import SwiftUI
import OAuthSwift

@main
struct TrellTechApp: App {
    @StateObject var authenticator = TrelloAuthenticator()
    @StateObject var trelloAPIManager = TrelloAPIManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authenticator)
                .environmentObject(trelloAPIManager)
                .onOpenURL { url in
                    print("TrellTechApp: Ouverture de l'URL : \(url.absoluteString)")
                    if url.host == "oauth-callback" {
                        OAuthSwift.handle(url: url)
                        print("TrellTechApp: URL de callback OAuthSwift gérée.")
                    } else {
                        print("TrellTechApp: L'URL ne correspond pas au callback attendu.")
                    }
                }
        }
    }
}
