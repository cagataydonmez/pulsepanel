import AppKit
import Foundation
import PulsePanelProtocol

struct URLLauncher {
    private let allowedSchemes = Set(["http", "https", "mailto"])

    func open(_ url: URL) async throws {
        guard let scheme = url.scheme?.lowercased(),
              allowedSchemes.contains(scheme) else {
            throw ProtocolError(
                code: .urlNotAllowed,
                message: "This URL type is not allowed yet."
            )
        }
        NSWorkspace.shared.open(url)
    }
}
