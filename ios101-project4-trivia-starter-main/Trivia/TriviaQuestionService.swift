//
//  ViewController.swift
//  Trivia
//
//  Created by rtiwari6 on 10/5/23.
//

import Foundation

class TriviaQuestionService {
    
    typealias QuestionFetchCompletion = ([TriviaQuestion]?, Error?) -> Void
    
    private let baseURL = "https://opentdb.com/api.php"
    
    func fetchQuestions(amount: Int, completion: @escaping QuestionFetchCompletion) {
        
        if var urlComponents = URLComponents(string: baseURL) {
            urlComponents.queryItems = [
                URLQueryItem(name: "amount", value: String(amount))
            ]
           
            if let url = urlComponents.url {
                let session = URLSession.shared
                let dataTask = session.dataTask(with: url) { (data, response, error) in
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                    }
                    if let data = data {
                        let responseString = String(data: data, encoding: .utf8)
                        print("Response Data: \(responseString ?? "No data")")
                    }
                                        
                    if let error = error {
                        completion(nil, error)
                    } else if let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let questionsResponse = try decoder.decode(TriviaQuestionResponse.self, from: data)
                            let questions = questionsResponse.results
                            completion(questions, nil)
                        } catch {
                            completion(nil, error)
                        }
                    } else {
                        completion(nil, NSError(domain: "TriviaQuestionService", code: 0, userInfo: nil))
                    }
                }
                dataTask.resume()
            } else {
                completion(nil, NSError(domain: "TriviaQuestionService", code: 0, userInfo: nil))
            }
        }
    }
}
