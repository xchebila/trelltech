import SwiftUI

struct EditCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    var card: Card
    var listId: String
    var fetchBoardDetails: () -> Void
    @State private var cardName: String
    var isPresentedModally: Bool

    init(card: Card, listId: String, fetchBoardDetails: @escaping () -> Void, isPresentedModally: Bool = true) {
        self.card = card
        self.listId = listId
        self.fetchBoardDetails = fetchBoardDetails
        self.isPresentedModally = isPresentedModally
        _cardName = State(initialValue: card.name)
    }

    var body: some View {
        Group {
            if isPresentedModally {
                NavigationView {
                    cardEditForm
                }
            } else {
                cardEditForm
            }
        }
    }

    var cardEditForm: some View {
        Form {
            Section {
                TextField("Nom de la carte", text: $cardName)
            }

            Button("Sauvegarder") {
                trelloAPIManager.updateCard(id: card.id, newName: cardName) { success in
                    if success {
                        fetchBoardDetails()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationTitle("Modification de la carte")
        .navigationBarItems(trailing: Button("Annuler") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}
