//
//  Workspace.swift
//  TrellTech
//
//  Created by Xiam Chebila on 04/03/2024.
//

import Foundation

struct Workspace: Identifiable, Decodable {
    var id: String
    var name: String
    var displayName: String
    var desc: String
    var url: String
    var membersCount: Int
    var idBoards: [String]
}

extension Workspace: Equatable {
    static func == (lhs: Workspace, rhs: Workspace) -> Bool {
        // Comparer les instances de Workspace en fonction de leurs propriétés
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.displayName == rhs.displayName &&
               lhs.desc == rhs.desc &&
               lhs.url == rhs.url &&
               lhs.membersCount == rhs.membersCount &&
               lhs.idBoards == rhs.idBoards
    }
}

