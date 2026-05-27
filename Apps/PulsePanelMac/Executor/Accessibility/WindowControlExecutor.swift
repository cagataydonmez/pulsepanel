import Foundation

struct WindowControlExecutor {
    func executePlaceholder() throws {
        guard AccessibilityPermissionGate.isTrusted else {
            AccessibilityPermissionGate.requestIfNeeded()
            return
        }
        // TODO: Implement Accessibility API window control after MVP permission UX.
    }
}
