//
//  SuccesView.swift
//  TrellTech
//
//  Created by Ygal Nezri on 04/03/2024.
//
 
import Foundation
import SwiftUI
 
struct SuccessView: View {
    var body: some View {
        VStack {
            Image("Auth-Ok")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .padding()
            
            Text("Authentification réussie !")
                .font(.title)
                .padding()
            
            Text("Vous allez être redirigé automatiquement vers l'application... Merci patienter.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .foregroundColor(.black)
    }
}
 
 
#if DEBUG
struct SuccesView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessView()
    }
}
#endif
