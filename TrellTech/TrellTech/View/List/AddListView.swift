import SwiftUI

struct AddListView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    var boardId: String
    @Binding var isPresented: Bool
    @State private var listName: String = ""
    var onAddList: () -> Void = {} // Callback à appeler après l'ajout d'une liste


    var body: some View {
        NavigationView {
            Form {
                TextField("Saisissez le nom de de la liste", text: $listName)
            }
            .navigationBarTitle("Ajouter une liste", displayMode: .inline)
            .navigationBarItems(leading: Button("Annuler") {
                self.dismiss()
            }, trailing: Button("Sauvegarder") {
                self.saveList()
            })
        }
    }
    
    private func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func saveList() {
        guard !listName.isEmpty else { return }
        trelloAPIManager.createList(boardId: boardId, name: listName) { success in
            if success {
                DispatchQueue.main.async {
                    self.isPresented = false
                    self.onAddList() // Appeler le callback après la fermeture de la vue
                }
            }
        }
    }
}
