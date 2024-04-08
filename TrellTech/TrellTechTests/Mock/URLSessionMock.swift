//
//  URLSessionMock.swift
//  TrellTechTests
//
//  Created by Xiam Chebila on 12/03/2024.
//

import Foundation

class URLSessionMock: URLSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let data = self.data
        let response = self.response
        let error = self.error
        
        let task: URLSessionDataTaskProtocol = URLSessionDataTaskMock {
            completionHandler(data, response, error)
        }
        
        return task as! URLSessionDataTask // Bien que pas idéal, ce cast est nécessaire ici pour respecter la signature de la méthode. Assurez-vous de ne l'utiliser que dans un contexte de test.
    }
}
