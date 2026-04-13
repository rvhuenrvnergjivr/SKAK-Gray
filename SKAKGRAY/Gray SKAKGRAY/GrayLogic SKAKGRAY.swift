//
//  GrayLogic.swift
//  
//
//  Created by Tehnichka on 29.10.2025.
//

import Foundation

class GrayLogic {
    var grayLink: String
    
    init(grayLink: String) {
        self.grayLink = grayLink
        var urlString = UserDefaults.standard.string(forKey: "urlString")
        
        if urlString == nil || (urlString ?? "").isEmpty {

            
            Task {
                let urlString = grayLink // URL з можливим редіректом
                    UserDefaults.standard.set(grayLink, forKey: "urlString")
            }
        }
    }
}


// Делегат для відстеження редіректів
private class RedirectHandler: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        // Приймаємо редірект
        completionHandler(request)
    }
}
