# TrellTech

TrellTech est une application de gestion de projet inspirée de Trello, utilisant l'API Trello pour créer, gérer et visualiser des workspaces, boards, listes et cartes. Elle permet aux utilisateurs de s'authentifier via Trello et d'interagir directement avec leurs données Trello depuis l'application.

## Fonctionnalités

- Authentification OAuth avec Trello.
- Gestion des workspaces : créer, lire, mettre à jour, supprimer.
- Gestion des boards : créer, lire, mettre à jour, supprimer.
- Gestion des listes et cartes : créer, lire, mettre à jour, supprimer.
- Interface utilisateur intuitive pour interagir avec les workspaces, boards, listes, et cartes.

## Prérequis

- iOS 13.0 ou supérieur / macOS 10.15 ou supérieur
- Xcode 12.0 ou supérieur
- Un compte Trello pour l'authentification et l'accès aux données

## Installation

Clonez ce dépôt et ouvrez le fichier `TrellTech.xcodeproj` avec Xcode :

```bash
git clone https://github.com/EpitechMscProPromo2026/T-DEV-600-MAR_2.git
cd TrellTech
open TrellTech.xcodeproj
````

## Configuration

Avant de lancer l'application, assurez-vous d'ajouter votre clé API et votre token OAuth de Trello dans le fichier `TrelloAuthenticator.swift`.

## Lancement

1. Ouvrez le projet dans Xcode.
2. Sélectionnez un simulateur ou un dispositif connecté.
3. Appuyez sur le bouton Run (▶️) d'Xcode pour construire et exécuter l'application.

## Structure du Projet

- `TrellTechApp.swift` : Point d'entrée de l'application.
- `TrelloAuthenticator.swift` : Gère l'authentification OAuth avec Trello.
- `TrelloAPIManager.swift` : Interface avec l'API Trello pour gérer les données.
- `ContentView.swift` : Vue principale de l'application.
- `SuccessView.swift` : Vue affichée après une authentification réussie.
- `WorkspaceView.swift` : Vue détaillée pour un workspace spécifique.
- `WorkspacesView.swift` : Vue listant tous les workspaces de l'utilisateur.
- `Workspace.swift` : Modèle de données pour un workspace.
- `Board.swift` : Modèle de données pour un board.
- `List.swift` : Modèle de données pour une liste.
- `Card.swift` : Modèle de données pour une carte.

## Contribution

Les contributions sont les bienvenues. Pour contribuer, veuillez forker le dépôt, créer une branche pour votre fonctionnalité, et soumettre une pull request.

## Licence

Ce projet est distribué sous la Licence MIT. Voir le fichier `LICENSE` pour plus d'informations.

