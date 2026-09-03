import Cocoa
import MASShortcut

struct AppShortcutConflict {
    let shortcutName: String

    static func conflict(for shortcut: MASShortcut,
                         ignoringDefaultsKey ignoredDefaultsKey: String,
                         userDefaults: UserDefaults = .standard) -> AppShortcutConflict? {
        let identity = ShortcutCycle.ShortcutIdentity(shortcut)

        for action in WindowAction.active where action.name != ignoredDefaultsKey {
            guard let actionShortcut = ShortcutCycle.shortcut(for: action, userDefaults: userDefaults),
                  ShortcutCycle.ShortcutIdentity(actionShortcut) == identity
            else { continue }
            return AppShortcutConflict(shortcutName: action.displayName ?? action.name)
        }

        return nil
    }

    @discardableResult
    static func removeDuplicateAssignments(userDefaults: UserDefaults = .standard) -> [String] {
        let orderedDefaultsKeys = WindowAction.active.map(\.name)
        var seen = Set<ShortcutCycle.ShortcutIdentity>()
        var removed = [String]()

        for defaultsKey in orderedDefaultsKeys {
            guard let shortcut = ShortcutCycle.shortcut(forDefaultsKey: defaultsKey, userDefaults: userDefaults) else {
                continue
            }
            let identity = ShortcutCycle.ShortcutIdentity(shortcut)
            guard !seen.insert(identity).inserted else { continue }
            userDefaults.removeObject(forKey: defaultsKey)
            removed.append(defaultsKey)
        }

        return removed
    }

}

class AppShortcutValidator: MASShortcutValidator {
    private let defaultsKey: String
    private let userDefaults: UserDefaults
    private let allowSystemConflicts: Bool

    init(defaultsKey: String,
         userDefaults: UserDefaults = .standard,
         allowSystemConflicts: Bool = false) {
        self.defaultsKey = defaultsKey
        self.userDefaults = userDefaults
        self.allowSystemConflicts = allowSystemConflicts
        super.init()
    }

    override func isShortcutValid(_ shortcut: MASShortcut!) -> Bool {
        allowSystemConflicts || super.isShortcutValid(shortcut)
    }

    override func isShortcutAlreadyTaken(bySystem shortcut: MASShortcut!,
                                         explanation: AutoreleasingUnsafeMutablePointer<NSString?>!) -> Bool {
        if let conflict = AppShortcutConflict.conflict(for: shortcut,
                                                       ignoringDefaultsKey: defaultsKey,
                                                       userDefaults: userDefaults) {
            if explanation != nil {
                let format = NSLocalizedString(
                    "This shortcut is already assigned to %@.",
                    tableName: "Main",
                    value: "This shortcut is already assigned to %@.",
                    comment: "Duplicate shortcut assignment explanation"
                )
                explanation.pointee = String(format: format, conflict.shortcutName) as NSString
            }
            return true
        }
        return allowSystemConflicts
            ? false
            : super.isShortcutAlreadyTaken(bySystem: shortcut, explanation: explanation)
    }
}
