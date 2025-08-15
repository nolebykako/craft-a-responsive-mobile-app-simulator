import Foundation
import SwiftUI

// API Specification for Craft a Responsive Mobile App Simulator

struct SimulatorAPI {
    let baseURL = "https://craftsimulator.com/api/v1"
    
    enum Endpoints {
        case devices
        case screens(deviceId: String)
        case interactions(deviceId: String, screenId: String)
        
        var stringValue: String {
            switch self {
            case .devices:
                return "/devices"
            case .screens(let deviceId):
                return "/devices/\(deviceId)/screens"
            case .interactions(let deviceId, let screenId):
                return "/devices/\(deviceId)/screens/\(screenId)/interactions"
            }
        }
    }
    
    func fetchDevices(completion: @escaping ([Device]) -> Void) {
        guard let url = URL(string: baseURL + Endpoints.devices.stringValue) else {
            fatalError("Invalid URL")
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching devices: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }
            do {
                let devices = try JSONDecoder().decode([Device].self, from: data)
                completion(devices)
            } catch {
                print("Error parsing devices: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func fetchScreens(for device: Device, completion: @escaping ([Screen]) -> Void) {
        let endpoint = Endpoints.screens(deviceId: device.id)
        guard let url = URL(string: baseURL + endpoint.stringValue) else {
            fatalError("Invalid URL")
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching screens: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }
            do {
                let screens = try JSONDecoder().decode([Screen].self, from: data)
                completion(screens)
            } catch {
                print("Error parsing screens: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func sendInteraction(on device: Device, for screen: Screen, interaction: Interaction, completion: @escaping () -> Void) {
        let endpoint = Endpoints.interactions(deviceId: device.id, screenId: screen.id)
        guard let url = URL(string: baseURL + endpoint.stringValue) else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(interaction)
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Error sending interaction: \(error.localizedDescription)")
                return
            }
            completion()
        }.resume()
    }
}

struct Device: Codable, Identifiable {
    let id = UUID()
    var name: String
    var screenSize: CGSize
}

struct Screen: Codable, Identifiable {
    let id = UUID()
    var deviceId: String
    var name: String
    var layout: [UIView]
}

struct Interaction: Codable {
    var screenId: String
    var timestamp: Date
    var action: String
    var coordinates: CGPoint
}