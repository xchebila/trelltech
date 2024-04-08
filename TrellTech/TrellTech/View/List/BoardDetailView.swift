import SwiftUI

struct BoardDetailView: View {
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    var boardId: String
    @State private var lists: [TrelloList] = []
    @State private var cardsByList: [String: [Card]] = [:]
    @State private var isAddCardPresented: Bool = false
    @State private var isAddListPresented: Bool = false
    @State private var selectedListId: String?
    @State private var allCardsLoaded: Bool = false
    @State private var selectedCardForEdit: Card? = nil
    @State private var isEditCardPresented: Bool = false
    @State private var newName: String = ""
    @State private var isCardEditing: Bool = false
    @State private var isEditingListName: Bool = false
    @State private var editingListName: String = String()
    @State private var showingDeleteCardAlert = false
    @State private var cardToDelete: Card?
    @State private var showingArchiveListAlert = false
    @State private var listToArchive: TrelloList?
    @State private var showingInviteMemberView = false


    var body: some View {
        List {
            ForEach($lists, id: \.id) { $list in
                Section(header: HStack {
                    if list.isEditingListName ?? false { // Utiliser une valeur par défaut si `isEditingListName` est nil
                        TextField("Nouveau nom", text: Binding<String>(
                            get: { list.name },
                            set: { list.name = $0 }
                        ), onCommit: {
                            // Mettre à jour le nom de la liste lorsque l'édition est terminée
                            list.isEditingListName = false
                            self.trelloAPIManager.updateList(id: list.id, newName: list.name) { success in
                                if success {
                                    self.loadBoardDetails()
                                }
                            }
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(list.name)
                            .onTapGesture {
                                list.isEditingListName = true
                            }
                    }
                    Spacer()

                    Button(action: {
                        // Sélectionner la liste pour ajouter une carte
                        self.selectedListId = list.id
                        // Afficher la vue pour ajouter une carte
                        self.isAddCardPresented = true
                    }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.green)
                    }
                    Button(action: {
                        // Archiver la liste
                        self.trelloAPIManager.archiveList(listId: list.id) { success in
                            if success {
                                // Recharger les détails du tableau après l'archivage de la liste
                                self.loadBoardDetails()
                            }
                        }
                    }) {
                        Image(systemName: "archivebox")
                            .foregroundColor(.red)
                    }
                }) {
                    if let cards = cardsByList[list.id] {
                        ForEach(cards, id: \.id) { card in
                            Text(card.name)
                                .contextMenu {
                                    Button(action: {
                                        print("Début de la récupération des détails de la carte: \(card.id)")
                                        self.prepareEditCardView(cardId: card.id)
                                    }) {
                                        Label("Modifier", systemImage: "pencil")
                                    }

                                    Button(role: .destructive) {
                                        self.cardToDelete = card
                                        self.showingDeleteCardAlert = true
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                        }
                    } else {
                        Text("Aucune carte disponible").foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("Détails du tableau")
        
        .alert("Supprimer la carte ?", isPresented: $showingDeleteCardAlert) {
            Button("Annuler", role: .cancel) { }
            Button("Supprimer", role: .destructive) {
                if let cardToDelete = self.cardToDelete {
                    self.deleteCard(cardToDelete)
                }
            }
        } message: {
            Text("Êtes-vous sûr de vouloir supprimer cette carte ? Cette action est irréversible.")
        }
        
        .navigationBarItems(trailing:
            HStack {
                Button(action: {
                    self.showingInviteMemberView = true
                }) {
                    Image(systemName: "person.badge.plus")
                }

                Button(action: {
                    // Afficher la vue pour ajouter une carte
                    self.isAddListPresented = true
                }) {
                    Image(systemName: "plus")
                }
            })
        .onAppear {
            print("Chargement des détails du tableau")
            self.loadBoardDetails()
        }
        .sheet(isPresented: Binding(
            get: { self.isAddCardPresented && self.allCardsLoaded },
            set: { _ in self.isAddCardPresented = false }
        )) {
            // Afficher la vue de création de carte uniquement si une liste est sélectionnée
            if let selectedListId = self.selectedListId {
                AddCardView(listId: selectedListId, isPresented: self.$isAddCardPresented) {
                    // Recharger les détails du tableau après l'ajout d'une nouvelle carte
                    self.loadBoardDetails()
                }
                .environmentObject(self.trelloAPIManager)
            }
        }
        .sheet(isPresented: $isEditCardPresented) {
            if let selectedCard = selectedCardForEdit, let listId = selectedListId {
                EditCardView(card: selectedCard, listId: listId, fetchBoardDetails: self.loadBoardDetails)
                    .environmentObject(self.trelloAPIManager)
            }
        }

        .sheet(isPresented: $isAddListPresented) {
            AddListView(boardId: self.boardId, isPresented: self.$isAddListPresented, onAddList: loadBoardDetails)
                .environmentObject(self.trelloAPIManager)
        }
        .sheet(isPresented: $showingInviteMemberView) {
            InviteMemberView(boardId: self.boardId)
                .environmentObject(self.trelloAPIManager)
        }

    }


    private func loadBoardDetails() {
        print("Début du chargement des listes et des cartes pour le tableau \(boardId)")
        trelloAPIManager.fetchLists(forBoardId: boardId) { fetchedLists in
            print("Listes récupérées pour le tableau: \(fetchedLists.map { $0.name })")
            self.lists = fetchedLists
            self.cardsByList = [:]
            self.allCardsLoaded = false
            
            let dispatchGroup = DispatchGroup()
            
            for list in fetchedLists {
                dispatchGroup.enter()
                self.trelloAPIManager.fetchCards(forListId: list.id) { fetchedCards in
                    print("Cartes récupérées pour la liste \(list.name): \(fetchedCards.map { $0.name })")
                    DispatchQueue.main.async {
                        self.cardsByList[list.id] = fetchedCards
                        dispatchGroup.leave()
                        
                        // Vérifier si la carte sélectionnée est dans les cartes chargées
                        if let selectedCardId = self.selectedCardForEdit?.id,
                           fetchedCards.contains(where: { $0.id == selectedCardId }) {
                            print("Préparation de la vue de modification pour la carte avec l'ID: \(selectedCardId)")
                            self.prepareEditCardView(cardId: selectedCardId)
                        }
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                print("Toutes les requêtes sont terminées. Mise à jour de l'interface utilisateur.")
                self.allCardsLoaded = true // Mettre à jour l'état une fois que toutes les requêtes sont terminées
            }
        }
    }

    private func prepareEditCardView(cardId: String) {
        guard let card = cardsByList.values.flatMap({ $0 }).first(where: { $0.id == cardId }) else {
            print("Carte non trouvée pour l'ID: \(cardId)")
            return
        }
        // Mettre à jour la carte sélectionnée et présenter la vue de modification
        print("Détails de la carte prêts pour l'édition: \(card)")
        self.selectedCardForEdit = card
        self.isEditCardPresented = true
        print("isEditCardPresented set to true")

        print("selectedCardForEdit mis à jour: \(self.selectedCardForEdit)")

    }


    private func archiveList(_ list: TrelloList) {
        trelloAPIManager.archiveList(listId: list.id) { success in
            if success {
                self.loadBoardDetails()
            }
        }
    }


    private func deleteCard(_ card: Card) {
        trelloAPIManager.deleteCard(id: card.id) { success in
            if success {
                self.loadBoardDetails()
            }
        }
    }
}
