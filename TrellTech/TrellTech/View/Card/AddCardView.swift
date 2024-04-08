import SwiftUI

struct AddCardView: View {
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    var listId: String
    @Binding var isPresented: Bool
    @State private var cardName: String = ""
    var onCardAdded: (() -> Void)? // Ajout de la closure de complétion

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Saisissez le nom de la carte", text: $cardName)
                    Button("Ajouter") {
                        print("Tentative d'ajout d'une nouvelle carte avec le nom : \(cardName) à la liste \(listId)")
                        addNewCard()
                    }
                }
            }
            .navigationBarTitle("Ajouter une nouvelle carte", displayMode: .inline)
            .navigationBarItems(trailing: Button("Annuler") {
                print("Annulation de l'ajout d'une nouvelle carte")
                self.isPresented = false
            })
        }
        .onAppear {
            print("AddCardView apparaît pour la liste: \(listId)")
        }
    }

    private func addNewCard() {
        trelloAPIManager.createCard(listId: listId, name: cardName) { success in
            if success {
                print("La carte à été créer avec succés")
                DispatchQueue.main.async {
                    self.isPresented = false
                    self.onCardAdded?()
                }
            } else {
                print("Échec lors de la création de la carte")
            }
        }
    }
}
