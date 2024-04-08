//
//  List.swift
//  TrellTech
//
//  Created by Xiam Chebila on 05/03/2024.
//

import Foundation

struct TrelloList: Identifiable, Decodable {
    let id: String
    var name: String
    var isEditingListName: Bool?
    var editingListName: String? = ""
}

