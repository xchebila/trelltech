import SwiftUI

struct WorkspacesView: View {
    @State private var searchText: String = ""
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    @State private var showingAddWorkspaceView = false
    @EnvironmentObject var authenticator: TrelloAuthenticator
    @State private var showingEditWorkspaceView = false
    @State private var selectedWorkspace: Workspace?
    
    var filteredWorkspaces: [Workspace] {
        if searchText.isEmpty {
            return trelloAPIManager.workspaces
        } else {
            return trelloAPIManager.workspaces.filter { workspace in
                return workspace.displayName.localizedCaseInsensitiveContains(searchText) ||
                workspace.desc.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image("epitrell-head")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .padding(.leading, 20)
                
                Spacer()
                
                Button(action: {
                    authenticator.logout()
                }) {
                    Text("Déconnexion")
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.trailing, 20)
                }
            }
            .padding(.top, -50)
            .padding(.bottom, -50)
            
            VStack {
                // MARK: - Top Section
                VStack(alignment: .leading) {
                    Text("Tâches du jour :")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 50)
                        .padding(.bottom, 5)
                    
                    Label {
                        Text("\(trelloAPIManager.workspaces.count) espaces de travail\(trelloAPIManager.workspaces.count != 1 ? "s" : "") disponible")
                    } icon: {
                        Image(systemName: "star.fill")
                            .font(.system(.footnote))
                            .foregroundColor(.yellow)
                    }
                    
                    SearchBarView(searchText: $searchText)
                    
                    HStack {
                        Text("Raccourcies Epitrell")
                            .font(.headline)
                        Spacer()
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 15) {
                            ForEach(avatars, id: \.self) { value in
                                VStack {
                                    CircularImageView(name: value, size: 52)
                                    Button(action: {
                                        if let url = URL(string: "https://gandalf.epitech.eu/my/") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        Text("Epitech") // Texte pour le bouton
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .frame(height: 75)
                    }
                    .padding(.bottom)


                }
                .padding(.horizontal)
                
                // Bottom Section with Swipe Actions
                VStack {
                    HStack {
                        Text("Espaces de travail")
                            .font(.system(size: 23))
                        Spacer()
                        Button("Créer un espace de travail") {
                            showingAddWorkspaceView = true
                        }
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .sheet(isPresented: $showingAddWorkspaceView) {
                            AddWorkspaceView(isPresented: self.$showingAddWorkspaceView)
                                .environmentObject(self.trelloAPIManager)
                        }
                    }
                    .padding(.all, 20)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredWorkspaces, id: \.id) { workspace in
                                ProjectItemView(workspace: workspace)
                                    .environmentObject(trelloAPIManager)
                                    .contextMenu {
                                        Button {
                                            selectedWorkspace = workspace
                                            trelloAPIManager.fetchWorkspaces()
                                            showingEditWorkspaceView = true
                                        } label: {
                                            Label("Modifier", systemImage: "pencil")
                                        }
                                        Button(role: .destructive) {
                                            trelloAPIManager.deleteWorkspace(id: workspace.id) { success in
                                                if success {
                                                    trelloAPIManager.fetchWorkspaces()
                                                }
                                            }
                                        } label: {
                                            Label("Supprimer", systemImage: "trash")
                                        }
                                    }
                            }
                            .sheet(isPresented: $showingEditWorkspaceView) {
                                if let workspaceToEdit = selectedWorkspace {
                                    EditWorkspaceView(workspace: workspaceToEdit, isPresented: $showingEditWorkspaceView)
                                        .environmentObject(trelloAPIManager)
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.white)
                .cornerRadius(25)
                .onAppear {
                    trelloAPIManager.fetchWorkspaces()
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color(red: 0/255, green: 126/255, blue: 199/255).opacity(0.2))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct WorkspacesView_Previews: PreviewProvider {
    static var previews: some View {
        let trelloAPIManager = TrelloAPIManager() // Simulated TrelloAPIManager
        let authenticator = TrelloAuthenticator() // Simulated TrelloAuthenticator
        
        return WorkspacesView()
            .environmentObject(trelloAPIManager)
            .environmentObject(authenticator)
    }
}
