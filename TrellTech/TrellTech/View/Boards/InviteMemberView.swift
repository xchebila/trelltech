import SwiftUI

struct InviteMemberView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    var boardId: String
    @State private var email: String = ""
    @State private var fullName: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Adresse e-mail", text: $email)
                TextField("Nom complet (optionnel)", text: $fullName)
                
                Button("Inviter") {
                    trelloAPIManager.inviteMemberToBoard(boardId: boardId, email: email, fullName: fullName) { success in
                        if success {
                            dismiss()
                        } else {
                            // Gérer l'erreur ici
                        }
                    }
                }
            }
            .navigationTitle("Inviter un membre")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}
