/// RectangleStatusItem.swift

import Cocoa

class RectangleStatusItem {
    static let instance = RectangleStatusItem()
    static let autosaveName = "co.serp.rectangleclone.statusItem"
    
    private var nsStatusItem: NSStatusItem?
    private var added: Bool = false
    public var statusMenu: NSMenu? {
        didSet {
            nsStatusItem?.menu = statusMenu
        }
    }
    private init() {}
    
    public func refreshVisibility() {
        if Defaults.hideMenuBarIcon.enabled {
            remove()
        } else {
            add()
        }
    }
    
    public func openMenu() {
        if !added {
            add()
        }
        nsStatusItem?.button?.performClick(self)
        refreshVisibility()
    }
    
    private func add() {
        added = true
        nsStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        nsStatusItem?.autosaveName = Self.autosaveName
        nsStatusItem?.menu = self.statusMenu
        nsStatusItem?.button?.image = NSImage(named: "StatusTemplate")
        // Visibility is controlled only by the in-app preference. Allowing
        // system removal gives macOS a second persisted hidden-state source
        // that can make a fresh candidate identity unreachable.
        nsStatusItem?.behavior = []
        nsStatusItem?.isVisible = true
    }
    
    private func remove() {
        added = false
        guard let nsStatusItem = nsStatusItem else { return }
        NSStatusBar.system.removeStatusItem(nsStatusItem)
    }
    
}
