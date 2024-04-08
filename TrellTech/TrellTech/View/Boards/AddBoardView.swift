//
//  AddBoardView.swift
//  TrellTech
//
//  Created by Xiam Chebila on 25/03/2024.
//

import Foundation
import SwiftUI

struct AddBoardView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    var workspaceId: String
    @State private var boardName: String = ""
    var onBoardAdded: (() -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Saisissez le nom du tableau", text: $boardName)
                }

                Button("Créer") {
                    trelloAPIManager.createBoard(workspaceId: workspaceId, name: boardName) { success in
                        if success {
                            dismiss() 
                            self.onBoardAdded?()
                        }
                    }
                }
            }
            
            Spacer()
            
            .navigationTitle("Création d'un nouneau tableau")
            .navigationBarItems(trailing: Button("Annuler") {
                dismiss()
            })
        }
    }
}
