import SwiftUI
import WebKit

struct ProjectItemView: View {
    let workspace: Workspace
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    @State private var showingCopiedMessage = false // Pour contrôler l'affichage du message "Lien copié"
    @State private var showingWebView = false // Pour contrôler l'affichage de la WebView

    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: BoardView(workspace: workspace).environmentObject(trelloAPIManager)) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(workspace.desc)
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                        
                        Spacer()
                        
                        Text("\(workspace.membersCount) membre\(workspace.membersCount != 1 ? "s" : "")")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 5)
                    
                    Text(workspace.displayName)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    Spacer(minLength: 20)
                    
                    HStack {
                        Button("Inviter des membres") {
                            self.showingWebView = true // Déclenche l'affichage de la WebView
                        }
                        .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Button(action: {
                            self.copyToClipboard(text: workspace.url)
                            self.showingCopiedMessage = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.showingCopiedMessage = false
                            }
                        }) {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing, 10) // Ajoute de l'espace à droite
                        
                        if showingCopiedMessage {
                            Text("Lien copié")
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.trailing, 10)

                                
                        }
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                .frame(height: 150)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showingWebView) { // Affiche la WebView dans une feuille
            WebView(url: URL(string: workspace.url) ?? URL(string: "https://www.example.com")!)
        }
    }

    private func copyToClipboard(text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #endif
        print("Lien copié : \(text)")
    }
}

// Définition de la WebView
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
