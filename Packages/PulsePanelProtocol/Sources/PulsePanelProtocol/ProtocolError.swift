import Foundation

public enum ProtocolErrorCode: String, Codable, Sendable {
    case invalidFrame
    case unsupportedVersion
    case unauthorizedDevice
    case permissionDenied
    case invalidCommand
    case appNotFound
    case shortcutFailed
    case urlNotAllowed
    case commandFailed
    case macUnavailable
}

public struct ProtocolError: Codable, Error, Hashable, Sendable {
    public let code: ProtocolErrorCode
    public let message: String
    public let recoverySuggestion: String?

    public init(
        code: ProtocolErrorCode,
        message: String,
        recoverySuggestion: String? = nil
    ) {
        self.code = code
        self.message = message
        self.recoverySuggestion = recoverySuggestion
    }
}
