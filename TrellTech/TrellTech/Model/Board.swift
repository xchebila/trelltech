//
//  Board.swift
//  TrellTech
//
//  Created by Xiam Chebila on 04/03/2024.
//

import Foundation

struct Board: Identifiable, Decodable {
    var id: String
    var name: String
    var desc: String
    var idOrganization: String? // Ajouté, optionnel si non présent pour tous les boards
}
