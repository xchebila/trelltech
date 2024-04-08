import SwiftUI

struct EditWorkspaceView: View {
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    @Binding var isPresented: Bool
    var workspace: Workspace
    
    @State private var workspaceName: String = ""
    @State private var workspaceDesc: String = ""
    
    init(workspace: Workspace, isPresented: Binding<Bool>) {
        self.workspace = workspace
        self._isPresented = isPresented
        self._workspaceName = State(initialValue: workspace.displayName)
        self._workspaceDesc = State(initialValue: workspace.desc)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nom de l'espace de travail")) {
                    TextField("Saisissez le nom de l'espace de travail", text: $workspaceName)
                }
                
                Section(header: Text("Description de l'espace de travail")) {
                    TextField("Saisissez la description de l'espace de travail", text: $workspaceDesc)
                }
                
                Button("Enregistrer") {
                    trelloAPIManager.updateWorkspace(workspaceId: workspace.id, newName: workspaceName, newDesc: workspaceDesc) { success in
                        if success {
                            isPresented = false
                            trelloAPIManager.fetchWorkspaces()
                        }
                    }
                }
            }
            .navigationTitle("Modifier l'espace de travail")
            .navigationBarItems(trailing: Button("Annuler") {
                isPresented = false
            })
        }
    }
}
