//
//  viewModel.swift
//  testPrilka
//
//  Created by Сергей on 03.10.2024.
//

import SwiftUI

final class ViewModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    @Published var isFirstLaunch = false
    
    var url: URL?
    
    var apiManager: APIManagerProtocol {
        return APIManager()
    }
    
    func checkFirstLaunch() {
        let hasLaucnhedBefore = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if hasLaucnhedBefore == false {
            isFirstLaunch = true
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
        } else {
            isFirstLaunch = false
        }
    }
    
    func getURL(completion: @escaping (URL) -> Void) {
        apiManager.getUrlFromDB { url in
            
            guard url != nil,
                  let stringUrl = url,
                  let url = URL(string: stringUrl) else {
                completion(URL(string: Constants.gameUrl)!)
                return }
            let task = URLSession.shared.dataTask(with: url) { data , response , error in
                if let data = data {
                    self.apiManager.decodeJsonData(data: data) {   url in
                        self.sendNTFQuestionToUser()
                        completion(url)
                    }
                } else {
                    completion(URL(string: Constants.gameUrl)!)
                    self.sendNTFQuestionToUser()
                }
            }
            task.resume()
        }
    }
    
    func sendNTFQuestionToUser() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
    }
    
   
}
