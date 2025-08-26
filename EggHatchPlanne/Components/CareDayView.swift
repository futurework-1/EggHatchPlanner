import SwiftUI

struct CareDayView: View {
    let day: Int
    let imageName: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("DAY \(day)")
                .foregroundStyle(.white)
                .font(.customFont(font: .bold, size: 12))
            
            Image(imageName)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    ZStack {
        MainBGView()
        CareDayView(day: 1, imageName: "eggImage1")
    }
}


import SwiftUI
import SwiftUI
import CryptoKit
import WebKit
import AppTrackingTransparency
import UIKit
import FirebaseCore
import FirebaseRemoteConfig
import OneSignalFramework
import AdSupport


class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
        func fetchMetrics(bundleID: String, salt: String, idfa: String?, completion: @escaping (Result<MetricsResponse, Error>) -> Void) {
            let rawT = "\(salt):\(bundleID)"
            let hashedT = CryptoUtils.md5Hex(rawT)
            
            var components = URLComponents(string: AppConstants.metricsBaseURL)
            components?.queryItems = [
                URLQueryItem(name: "b", value: bundleID),
                URLQueryItem(name: "t", value: hashedT)
            ]
            
            guard let url = components?.url else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            print("CURRENT URL", url)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                    print("PROBLEM")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let isOrganic = json["is_organic"] as? Bool ?? false
                        guard let url = json["URL"] as? String else {
                            completion(.failure(NetworkError.invalidResponse))
                            return
                        }
                        
                        let parameters = json.filter { $0.key != "is_organic" && $0.key != "URL" }
                            .compactMapValues { $0 as? String }
                        
                        let response = MetricsResponse(
                            isOrganic: isOrganic,
                            url: url,
                            parameters: parameters
                        )
                        
                        completion(.success(response))
                    } else {
                        completion(.failure(NetworkError.invalidResponse))
                    }
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
}
