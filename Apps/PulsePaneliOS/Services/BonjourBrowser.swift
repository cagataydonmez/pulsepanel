import Foundation
import Network
import PulsePanelProtocol

public final class BonjourBrowser: @unchecked Sendable {
    private var browser: NWBrowser?
    private let queue = DispatchQueue(label: "PulsePanel.BonjourBrowser")
    public var onUpdate: (@Sendable ([MacIdentity]) -> Void)?

    public init() {}

    public func start() {
        let descriptor = NWBrowser.Descriptor.bonjour(type: "_pulsepanel._tcp", domain: "local.")
        let browser = NWBrowser(for: descriptor, using: .tcp)
        self.browser = browser

        browser.browseResultsChangedHandler = { [weak self] results, _ in
            let macs = results.compactMap { result -> MacIdentity? in
                guard case let .service(name, type, domain, _) = result.endpoint else { return nil }
                return MacIdentity(
                    id: UUID(uuidString: name) ?? UUID(),
                    name: name,
                    serviceName: "\(type).\(domain)"
                )
            }
            self?.onUpdate?(macs)
        }

        browser.start(queue: queue)
    }

    public func stop() {
        browser?.cancel()
        browser = nil
    }
}
