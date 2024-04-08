//
//  AddWorkspaceView.swift
//  TrellTech
//
//  Created by Xiam Chebila on 19/03/2024.
//

import Foundation
import SwiftUI

struct AddWorkspaceView: View {
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    @State private var workspaceName: String = ""
    @State private var workspaceDesc: String = "" // Ajoutez un état pour la description
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nom de l'espace de travail")) {
                    TextField("Saisissez le nom de l'espace de travail", text: $workspaceName)
                }
                
                Section(header: Text("Description de l'espace de travail (optionnel)")) {
                    TextField("Saisissez la description de l'espace de travail (optionnel)", text: $workspaceDesc)
                }
                
                Section {
                    Button("Créer l'espace de travail") {
                        createWorkspace()
                    }
                }
            }
            .navigationBarTitle("Ajouter un espace de travail", displayMode: .inline)
            .navigationBarItems(trailing: Button("Annuler") {
                self.isPresented = false
            })
        }
    }
    
    private func createWorkspace() {
        trelloAPIManager.createWorkspace(name: workspaceName, desc: workspaceDesc) { success in
            if success {
                print("L'espace de travail à été créer avec succés")
                DispatchQueue.main.async {
                    trelloAPIManager.fetchWorkspaces()
                }
            } else {
                print("Échec lors de la création de l'espace de travail")
            }
            self.isPresented = false
        }
    }
}
