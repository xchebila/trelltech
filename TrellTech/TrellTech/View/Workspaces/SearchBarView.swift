//
//  SearchBarView.swift
//  Project Management App
//
//  Created by Ygal Nezri on 19/03/2024.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @StateObject var dataManager = TrelloAPIManager()
    
    var body: some View {
        HStack {
            TextField("Rechercher dans Epitrell", text: $searchText)
                .padding()
            
            
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("#007ec7")) // Couleur modifiée
                .font(.system(size: 22))
                .padding()
        }
        .background(Color(.white))
        .cornerRadius(8)
        .padding(.top, 20)
    }
}
