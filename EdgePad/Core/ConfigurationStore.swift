import Foundation

@MainActor
final class ConfigurationStore {
    static let shared = ConfigurationStore()
    private let key = "edgeConfiguration"

    func load() -> EdgeConfiguration {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(EdgeConfiguration.self, from: data)
        else { return .default }
        return decoded
    }

    func save(_ configuration: EdgeConfiguration) {
        guard let data = try? JSONEncoder().encode(configuration) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}