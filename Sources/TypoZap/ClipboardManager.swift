import Foundation
import AppKit

class ClipboardManager {
    
    // MARK: - Properties
    private let pasteboard = NSPasteboard.general
    
    // MARK: - Clipboard Operations
    func getCurrentClipboard() -> String {
        return pasteboard.string(forType: .string) ?? ""
    }
    
    func setClipboard(text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    func restoreClipboard(text: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setClipboard(text: text)
        }
    }
    
    // MARK: - Clipboard State Management
    func hasTextInClipboard() -> Bool {
        guard let text = pasteboard.string(forType: .string) else { return false }
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func getClipboardTypes() -> [NSPasteboard.PasteboardType] {
        return pasteboard.types ?? []
    }
    
    // MARK: - Utility Methods
    func clearClipboard() {
        pasteboard.clearContents()
    }
    
    func copyToClipboard(text: String, type: NSPasteboard.PasteboardType = .string) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: type)
    }
}
