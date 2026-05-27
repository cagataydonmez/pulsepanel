import Foundation

public struct BoardStore {
    private let key = "pulsepanel.tiles.v1"

    public init() {}

    public func loadTiles() -> [AppTile] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return AppTile.samples
        }

        do {
            return try JSONDecoder().decode([AppTile].self, from: data)
        } catch {
            return AppTile.samples
        }
    }

    public func saveTiles(_ tiles: [AppTile]) {
        guard let data = try? JSONEncoder().encode(tiles) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
