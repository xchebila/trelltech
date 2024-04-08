import SwiftUI

struct BoardView: View {
    var workspace: Workspace
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    @State private var boards: [Board] = []
    @State private var showingAddBoardView = false
    @State private var showingEditBoardView = false
    @State private var selectedBoardForEdit: Board?

    var body: some View {
        NavigationView {
            List {
                ForEach(boards, id: \.id) { board in
                    NavigationLink(destination: BoardDetailView(boardId: board.id).environmentObject(trelloAPIManager)) {
                        Text(board.name)
                    }
                    .contextMenu {
                        Button(action: {
                            fetchBoardsForWorkspace()
                            selectedBoardForEdit = board
                            showingEditBoardView = true
                        }) {
                            Label("Modifier", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: {
                            trelloAPIManager.deleteBoard(id: board.id) { success in
                                if success {
                                    fetchBoardsForWorkspace() // Refresh the list of boards
                                }
                            }
                        }) {
                               Label("Supprimer", systemImage: "trash")
                           }
                        
                    }
                }
            }
            .navigationTitle(workspace.displayName)
            .navigationBarItems(trailing: Button(action: {
                showingAddBoardView = true // Affiche la vue pour ajouter une board
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddBoardView) {
                AddBoardView(workspaceId: workspace.id) {
                    fetchBoardsForWorkspace()
                }
                .environmentObject(trelloAPIManager)
            }
            .sheet(isPresented: $showingEditBoardView) {
                if let boardToEdit = selectedBoardForEdit {
                    EditBoardView(board: boardToEdit, fetchBoardsForWorkspace: fetchBoardsForWorkspace)
                        .environmentObject(trelloAPIManager)
                }
            }
            .onAppear {
                fetchBoardsForWorkspace()
            }
        }
    }

    private func fetchBoardsForWorkspace() {
        trelloAPIManager.fetchBoards { boards in
            let filteredBoards = boards.filter { $0.idOrganization == self.workspace.id }
            DispatchQueue.main.async {
                self.boards = filteredBoards
            }
        }
    }
}
