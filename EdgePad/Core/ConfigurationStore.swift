import Foundation

@MainActor
final class ConfigurationStore {
    static let shared = ConfigurationStore()
    private let key = "edgeConfiguration_v15"

    func load() -> AppProfilesConfiguration {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(AppProfilesConfiguration.self, from: data)
        else { return .default }
        return decoded
    }

    func save(_ configuration: AppProfilesConfiguration) {
        guard let data = try? JSONEncoder().encode(configuration) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}