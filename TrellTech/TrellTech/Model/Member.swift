//
//  Member.swift
//  TrellTech
//
//  Created by Xiam Chebila on 26/03/2024.
//

import Foundation

struct Member: Codable, Identifiable {
    var id: String
    var fullName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "fullName" // Utilisez la clé exacte selon la réponse de l'API Trello
    }
}
