//
//  APIManager.swift
//  testPrilka
//
//  Created by Сергей on 03.10.2024.
//

import Foundation
import FirebaseDatabase
import FirebaseAnalytics

protocol APIManagerProtocol {
    func getUrlFromDB(completion: @escaping (String?) -> Void)
    func decodeJsonData(data: Data, completion: @escaping (URL) -> Void)
}

final class APIManager: APIManagerProtocol {
    
    
    var ref: DatabaseReference!
    var deviceData: [String: String] = [:]
    
    func setRefParameters() {
        ref = Database.database(url: "https://test-963df-default-rtdb.europe-west1.firebasedatabase.app").reference()
    }
    
    func getDeviceData() {
        guard let appInstanceId = Analytics.appInstanceID(),
        let bundleId = Bundle.main.bundleIdentifier else { return }
        let devModel = UIDevice.current.model
        let osVersion = UIDevice.current.systemVersion
        let uid = UUID().uuidString
        let data = [ "app_instance_id" : appInstanceId,
                     "bundle" : bundleId,
                     "devModel" : devModel,
                     "osVersion" : osVersion,
                     "uid" : uid]
        self.deviceData = data
    }
    
    func getUrlFromDB(completion: @escaping  (String?) -> Void) {
        setRefParameters()
        getDeviceData()
        
        ref.observeSingleEvent(of: .value) { snapshot  in
            guard let value = snapshot.value as? [String : String],
                  let url1 = value["url1"],
                  let url2 = value["url2"],
                  let data = self.encodeDeviceDataToBase64(data: self.deviceData) else {
                completion(nil)
                return
            }
            
            let url = "https://" + url1 + url2 + "?data=" + data
            completion(url)
            
        } withCancel: { error in
            print(error.localizedDescription)
            completion(nil)
        }
        }
    
    func encodeDeviceDataToBase64(data: [String: String]) -> String? {
        let queryItems = data.map { URLQueryItem(name: $0.key, value: $0.value) }
        var components = URLComponents()
        components.queryItems = queryItems
        
        guard let queryString = components.query?.data(using: .utf8) else {
            return nil
        }
        return queryString.base64EncodedString()
    }
    
    func decodeJsonData(data: Data, completion: @escaping (URL) -> Void) {
        do {
            let decodedData = try JSONDecoder().decode(Urls.self, from: data)
            let completedUrlString = "https://" + decodedData.veins + decodedData.tells
            if let completedUrl = URL(string: completedUrlString) {
                UserDefaults.standard.set(completedUrl, forKey: "webViewURL")
                completion(completedUrl)
            }
            
        } catch let error as NSError {
            print(error)
            completion(URL(string: Constants.gameUrl)!)
        }
    }
}
