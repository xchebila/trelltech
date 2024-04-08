import Foundation
import OAuthSwift
import KeychainSwift

class TrelloAuthenticator: ObservableObject {
    @Published var isAuthenticated = false
    private var oauthswift: OAuth1Swift?
    private let keychain = KeychainSwift()

    init() {
        self.oauthswift = OAuth1Swift(
            consumerKey: "64c5dbc250b11aa454b2c0a074a14462",
            consumerSecret: "b9700b43ed2b354f53b48b98d46e772534ce8ae44794224f4eb2ebb3023f6979",
            requestTokenUrl: "https://trello.com/1/OAuthGetRequestToken",
            authorizeUrl: "https://trello.com/1/OAuthAuthorizeToken?scope=read,write,account",
            accessTokenUrl: "https://trello.com/1/OAuthGetAccessToken"
        )
        checkTokenValidity()
    }

    func authenticate() {
        print("Début de l'authentification")
        let callbackURL = "trelltechapp://oauth-callback/trello"
        oauthswift?.authorize(withCallbackURL: URL(string: callbackURL)!) { result in
            switch result {
            case .success(let (credential, _, _)):
                print("Authentification réussie, Token: \(credential.oauthToken)")
                self.keychain.set(credential.oauthToken, forKey: "oauthToken")
                self.keychain.set(credential.oauthTokenSecret, forKey: "oauthTokenSecret")
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            case .failure(let error):
                print("Échec de l'authentification : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                }
            }
        }
    }


    func checkTokenValidity() {
        print("Vérification de la validité du token")
        guard let oauthToken = keychain.get("oauthToken"),
              let oauthTokenSecret = keychain.get("oauthTokenSecret") else {
            print("Token ou Token Secret non trouvés dans le Keychain")
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
            return
        }

        print("Token: \(oauthToken), Token Secret: \(oauthTokenSecret)")

        self.oauthswift?.client.credential.oauthToken = oauthToken
        self.oauthswift?.client.credential.oauthTokenSecret = oauthTokenSecret

        self.oauthswift?.client.get("https://api.trello.com/1/members/me?key=64c5dbc250b11aa454b2c0a074a14462&token=\(oauthToken)") { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    // Optionally, you can delete invalid tokens here
                    self.logout()
                }
            }
        }
    }

    func logout() {
        keychain.delete("oauthToken")
        keychain.delete("oauthTokenSecret")
        self.isAuthenticated = false
    }
}
