//
//  BoardView.swift
//  TrellTech
//
//  Created by Xiam Chebila on 04/03/2024.
//

import SwiftUI

struct BoardView: View {
    let title: String
    let cards: [String] // Remplacez par le type approprié si vous avez un modèle pour les cartes

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)

            // Ici, vous pourriez lister les cartes ou créer une vue dédiée pour les cartes
            ForEach(cards, id: \.self) { card in
                Text(card)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.bottom, 5)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

// Un aperçu pour le développement et le test dans Xcode
struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(title: "Sample Board", cards: ["Card 1", "Card 2", "Card 3"])
    }
}
