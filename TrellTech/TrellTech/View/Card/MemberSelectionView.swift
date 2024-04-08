//
//  MemberSelectionView.swift
//  TrellTech
//
//  Created by Xiam Chebila on 26/03/2024.
//

import Foundation
import SwiftUI

struct MemberSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var boardId: String
    @EnvironmentObject var trelloAPIManager: TrelloAPIManager
    @State private var members: [Member] = []
    @State private var selectedMembers: Set<String> = []

    var body: some View {
        List(members, id: \.id) { member in
            HStack {
                Text(member.fullName)
                Spacer()
                if selectedMembers.contains(member.id) {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if selectedMembers.contains(member.id) {
                    selectedMembers.remove(member.id)
                } else {
                    selectedMembers.insert(member.id)
                }
            }
        }
        .onAppear {
            trelloAPIManager.fetchMembersForBoard(boardId: boardId) { fetchedMembers in
                members = fetchedMembers
            }
        }
        .navigationTitle("Sélectionner un membre")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Assigner") {
                    // Code pour assigner les membres sélectionnés à une carte
                    dismiss()
                }
            }
        }
    }
}

