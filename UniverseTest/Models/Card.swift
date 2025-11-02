//
//  Model.swift
//  UniverseTest
//
//  Created by Veronika Petrushka on 30/10/2025.
//

import Foundation


struct CardsResponse: Codable {
    let items: [ItemResponse]
}

struct ItemResponse: Codable {
    let id: Int
    let question: String
    let answers: [String]
}
