//
//  LoginView.swift
//  TrellTech
//
//  Created by Ygal Nezri on 19/03/2024.
//
 
import Foundation
import SwiftUI
 
struct LoginView: View {
    @EnvironmentObject var authenticator: TrelloAuthenticator
 
    var body: some View {
        ZStack {
            // Background image
            Image("Background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            Rectangle()
                .fill(Color.white.opacity(0.9))
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Logo centré en haut
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                
                Spacer()
                
                // Bouton "Se connecter à Trello"
                Button(action: {
                    authenticator.authenticate()
                }) {
                    Text("Se connecter avec Trello")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
                
                // Ou continuer avec
                HStack {
                    Text("Ou continuer avec :")
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.bottom, 15)
                                
                Spacer()
                
                Text("Un compte pour Epitrell, Gandalf, Epitech et plus.")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
                    .fontWeight(.bold)
                
                Text("En cas de problème contactez le support client.")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
                    .fontWeight(.bold)
                    
                    Spacer()
                }
            }
        }
    }
 
 
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(TrelloAuthenticator())
    }
}
