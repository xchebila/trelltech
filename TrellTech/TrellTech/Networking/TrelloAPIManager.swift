import Foundation
import KeychainSwift

class TrelloAPIManager: ObservableObject {
    @Published var workspaces: [Workspace] = []
    @Published var boards: [Board] = []
    private let keychain = KeychainSwift()

    private var apiKey: String {
        "64c5dbc250b11aa454b2c0a074a14462"
    }
    
    private var token: String? {
        keychain.get("oauthToken")
    }
    
    private func constructURL(for path: String) -> URL? {
        guard let token = token else { return nil }
        // Vérifier si l'URL a déjà des paramètres (contient un '?')
        let separator = path.contains("?") ? "&" : "?"
        return URL(string: "https://api.trello.com/1/\(path)\(separator)key=\(apiKey)&token=\(token)")
    }


    func fetchWorkspaces() {
        guard let url = constructURL(for: "members/me/organizations") else {
            print("Invalid URL or Token not found for fetching workspaces")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching workspaces: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let workspaces = try JSONDecoder().decode([Workspace].self, from: data)
                DispatchQueue.main.async {
                    self?.workspaces = workspaces
                    print("Fetched Workspaces: \(workspaces)")
                }
            } catch {
                print("Decoding error for workspaces: \(error)")
            }
        }.resume()
    }

    
    func createWorkspace(name: String, desc: String, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "organizations") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyParameters = [
            "displayName": name,
            "desc": desc
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error with creating workspace")
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }


    func updateWorkspace(workspaceId: String, newName: String, newDesc: String, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "organizations/\(workspaceId)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let bodyParameters = [
            "displayName": newName,
            "desc": newDesc
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Sending PUT Request to: \(url)")
        print("With body: \(bodyParameters)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with updating workspace: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response data: \(responseString)")
            }
        }
        task.resume()
    }


    func deleteWorkspace(id: String, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "organizations/\(id)") else {
            print("Invalid URL for deleting workspace")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error deleting workspace")
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }
    
    func fetchBoards(completion: @escaping ([Board]) -> Void) {
        guard let url = constructURL(for: "members/me/boards") else {
            print("Invalid URL for fetching boards")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error while fetching boards: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            do {
                let boards = try JSONDecoder().decode([Board].self, from: data)
                DispatchQueue.main.async {
                    completion(boards) // Passing the fetched boards to the callback
                    print("Fetched Boards: \(boards)")
                }
            } catch {
                print("Decoding error for boards: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }

    
    func createBoard(workspaceId: String, name: String, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "boards") else {
            print("Invalid URL for creating board")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let bodyParameters = [
            "name": name,
            "idOrganization": workspaceId
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            completion(false)
            return
        }
        
        // Perform the URLRequest
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error creating board")
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }



    func updateBoard(id: String, newName: String, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "boards/\(id)") else {
            print("Invalid URL for updating board")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create a dictionary to hold your PUT request's body content
        let bodyParameters = [
            "name": newName
        ]
        
        // Attempt to serialize your dictionary into JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            completion(false)
            return
        }
        
        // Perform the URLRequest
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error updating board")
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }

    
    func deleteBoard(id: String, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "boards/\(id)") else {
            print("Invalid URL for deleting board")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error deleting board")
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }

    
    func fetchLists(forBoardId boardId: String, completion: @escaping ([TrelloList]) -> Void) {
        guard let url = constructURL(for: "boards/\(boardId)/lists") else {
            print("Invalid URL for fetching lists")
            completion([])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error while fetching lists: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            do {
                let lists = try JSONDecoder().decode([TrelloList].self, from: data)
                DispatchQueue.main.async {
                    completion(lists)
                }
            } catch {
                print("Decoding error for lists: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
        task.resume()
    }

    
    func createList(boardId: String, name: String, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "lists?name=\(name)&idBoard=\(boardId)") else {
            print("Invalid URL for creating list")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error creating list")
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }

    func updateList(id: String, newName: String, completion: @escaping (Bool) -> Void) {
        // Assurez-vous que l'URL est correctement construite sans ajouter le nom dans les paramètres de l'URL.
        guard let url = constructURL(for: "lists/\(id)") else {
            print("Invalid URL for updating list")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Construire le corps de la requête avec le nouveau nom de la liste
        let bodyParameters = ["name": newName]
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters, options: [])
        
        // Confirmer l'URL et le nouveau nom pour le débogage
        print("Updating list with URL: \(url.absoluteString)")
        print("New name for the list: \(newName)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error updating list. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                completion(false)
                return
            }
            // Confirmer que la requête a réussi
            print("Successfully updated list with ID: \(id) to newName: \(newName)")
            completion(true)
        }
        task.resume()
    }

    func archiveList(listId: String, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "lists/\(listId)/closed?value=true") else {
            print("Invalid URL for archiving list")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Imprimer l'URL de la requête pour le débogage
        print("Attempting to archive list with URL: \(url.absoluteString)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Imprimer l'erreur si la requête échoue
                print("Error archiving list: \(error.localizedDescription)")
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("No response received")
                completion(false)
                return
            }

            if httpResponse.statusCode == 200 {
                print("Successfully archived list with ID: \(listId)")
                completion(true)
            } else {
                // Imprimer le code de statut HTTP si la requête ne réussit pas
                print("Error archiving list. Status code: \(httpResponse.statusCode)")
                completion(false)
            }
        }
        task.resume()
    }

    func fetchCards(forListId listId: String, completion: @escaping ([Card]) -> Void) {
        guard let url = constructURL(for: "lists/\(listId)/cards") else {
            print("Invalid URL for fetching cards")
            completion([])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Unknown error while fetching cards")
                completion([]) // Même chose ici en cas d'erreur
                return
            }
            
            do {
                let cards = try JSONDecoder().decode([Card].self, from: data)
                DispatchQueue.main.async {
                    completion(cards) // Utilisez la fonction de rappel pour transmettre les cartes récupérées
                }
            } catch {
                print("Decoding error for cards: \(error)")
                completion([]) // En cas d'erreur de décodage
            }
        }
        task.resume()
    }

    func fetchCardDetails(cardId: String, completion: @escaping (Result<Card, Error>) -> Void) {
        guard let url = constructURL(for: "cards/\(cardId)") else {
            let error = NSError(domain: "com.votreapp.TrelloAPIManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for fetching card details"])
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    let unknownError = NSError(domain: "com.votreapp.TrelloAPIManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error while fetching card details"])
                    completion(.failure(unknownError))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase // Si nécessaire, selon la convention de nommage des clés JSON
                let card = try decoder.decode(Card.self, from: data)
                completion(.success(card))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    func createCard(listId: String, name: String, desc: String? = nil, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "cards") else {
            print("Invalid URL for creating card")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var bodyParameters = [
            "name": name,
            "idList": listId
        ]
        
        if let desc = desc {
            bodyParameters["desc"] = desc
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error creating card")
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }


    func updateCard(id: String, newName: String, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "cards/\(id)?name=\(newName)") else {
            print("Invalid URL for updating card")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error updating card")
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }

    func deleteCard(id: String, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "cards/\(id)") else {
            print("Invalid URL for deleting card")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error deleting card")
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }
    
    func assignMemberToCard(cardId: String, memberId: String, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "cards/\(cardId)/idMembers?value=\(memberId)") else {
            print("Invalid URL for assigning member to card")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error assigning member to card")
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }
    
    func inviteMemberToBoard(boardId: String, email: String, fullName: String, completion: @escaping (Bool) -> Void) {
        guard let url = constructURL(for: "boards/\(boardId)/members?email=\(email)") else {
            print("Invalid URL for inviting member to board")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let bodyParameters = ["fullName": fullName]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyParameters, options: []) else {
            print("Error creating JSON data for inviting member")
            completion(false)
            return
        }

        request.httpBody = jsonData
        print("Inviting member with URL: \(url)")
        print("Body: \(String(data: jsonData, encoding: .utf8) ?? "")")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error inviting member to board: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error inviting member to board. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                completion(false)
                return
            }
            print("Successfully invited member to board with ID: \(boardId)")
            completion(true)
        }
        task.resume()
    }

    func fetchMembersForBoard(boardId: String, completion: @escaping ([Member]) -> Void) {
        guard let url = constructURL(for: "boards/\(boardId)/members") else {
            print("Invalid URL for fetching board members")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Unknown error while fetching board members")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            do {
                let members = try JSONDecoder().decode([Member].self, from: data)
                DispatchQueue.main.async {
                    completion(members)
                }
            } catch {
                print("Decoding error for board members: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }


}
