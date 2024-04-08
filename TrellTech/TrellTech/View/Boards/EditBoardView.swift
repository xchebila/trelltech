//
//  EditBoardView.swift
//  TrellTech
//
//  Created by Xiam Chebila on 25/03/2024.
//

import Foundation
import SwiftUI

struct EditBoardView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    var board: Board
    var fetchBoardsForWorkspace: () -> Void // Déclaration de la fonction de rappel
    @State private var boardName: String

    init(board: Board, fetchBoardsForWorkspace: @escaping () -> Void) {
        self.board = board
        self.fetchBoardsForWorkspace = fetchBoardsForWorkspace 
        _boardName = State(initialValue: board.name)
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Saisissez le nom du tableau", text: $boardName)
                }

                Button("Sauvegarder") {
                    trelloAPIManager.updateBoard(id: board.id, newName: boardName) { success in
                        if success {
                            dismiss()
                            fetchBoardsForWorkspace() // Appel de la fonction de rappel après avoir sauvegardé
                        }
                    }
                }
            }
            .navigationTitle("Modification du tableau")
            .navigationBarItems(trailing: Button("Annuler") {
                dismiss()
            })
        }
    }
}
