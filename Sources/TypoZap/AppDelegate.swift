import Cocoa
import AppKit
import UserNotifications
import HotKey

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    private var statusItem: NSStatusItem!
    private var geminiService: GeminiService!
    private var clipboardManager: ClipboardManager!
    private var hotKey: HotKey?
    
    // API Key dialog properties
    private var currentAPIKeyInput: NSTextField?
    private var currentAPIKeyWindow: NSWindow?
    private var savedAPIKey: String?
    
    // MARK: - App Lifecycle
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize services
        geminiService = GeminiService()
        clipboardManager = ClipboardManager()
        
        // Request notification permissions (only if available)
        if #available(macOS 10.14, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let error = error {
                    print("Notification permission error: \(error)")
                }
            }
        }
        
        // Setup menu bar
        setupMenuBar()
        
        // Setup global hotkey
        setupGlobalHotkey()
        
        // Check for accessibility permissions
        checkAccessibilityPermissions()
        
        // Request API key if not set
        if !geminiService.hasValidAPIKey() {
            requestAPIKey()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup
        hotKey = nil
    }
    
    // MARK: - Setup Methods
    private func setupMenuBar() {
        // Create status item in menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set icon (using a simple text icon for now)
        if let button = statusItem.button {
            button.title = "🔤"
            button.font = NSFont.systemFont(ofSize: 16)
        }
        
        // Create menu
        let menu = NSMenu()
        
        // Add menu items
        menu.addItem(NSMenuItem(title: "Change Hotkey", action: #selector(changeHotkey), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Set API Key", action: #selector(setAPIKey), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Toggle Auto-Correct", action: #selector(toggleAutoCorrect), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    private func setupGlobalHotkey() {
        // Setup Option+T hotkey using HotKey library
        hotKey = HotKey(key: .t, modifiers: [.option])
        
        hotKey?.keyDownHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.handleHotkeyPressed()
            }
        }
    }
    
    private func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessEnabled {
            showAccessibilityAlert()
        }
    }
    
    // MARK: - Hotkey Handler
    private func handleHotkeyPressed() {
        // Simulate Command+C to copy selected text
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Press Command+C
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 8, keyDown: true) // 8 = C key
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        
        // Release Command+C
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 8, keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)
        
        // Wait a bit for the copy to complete, then process
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.processSelectedText()
        }
    }
    
    private func processSelectedText() {
        guard let selectedText = NSPasteboard.general.string(forType: .string),
              !selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showNotification(title: "No Text Selected", body: "Please select some text to correct.")
            return
        }
        
        // Store original clipboard content
        let originalClipboard = clipboardManager.getCurrentClipboard()
        
        // Show processing indicator
        showProcessingIndicator()
        
        // Send to Gemini for correction
        geminiService.correctGrammar(text: selectedText) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideProcessingIndicator()
                
                switch result {
                case .success(let correctedText):
                    self?.applyCorrection(correctedText, originalClipboard: originalClipboard)
                case .failure(let error):
                    self?.showNotification(title: "Correction Failed", body: error.localizedDescription)
                }
            }
        }
    }
    
    private func applyCorrection(_ correctedText: String, originalClipboard: String) {
        // Copy corrected text to clipboard
        clipboardManager.setClipboard(text: correctedText)
        
        // Simulate Command+V to paste
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Press Command+V
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true) // 9 = V key
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        
        // Release Command+V
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)
        
        // Restore original clipboard after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.clipboardManager.setClipboard(text: originalClipboard)
        }
        
        // Show success feedback
        showSuccessFeedback()
    }
    
    // MARK: - UI Feedback Methods
    private func showProcessingIndicator() {
        if let button = statusItem.button {
            button.title = "⏳"
        }
    }
    
    private func hideProcessingIndicator() {
        if let button = statusItem.button {
            button.title = "🔤"
        }
    }
    
    private func showSuccessFeedback() {
        if let button = statusItem.button {
            button.title = "✅"
            
            // Reset to normal icon after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                if let button = self?.statusItem.button {
                    button.title = "🔤"
                }
            }
        }
    }
    
    private func showNotification(title: String, body: String) {
        // Try to show notification using UserNotifications framework
        if #available(macOS 10.14, *) {
            let notification = UNMutableNotificationContent()
            notification.title = title
            notification.body = body
            notification.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: nil)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to show notification: \(error)")
                    // Fallback to alert if notification fails
                    DispatchQueue.main.async {
                        self.showAlert(title: title, body: body)
                    }
                }
            }
        } else {
            // Fallback to alert for older macOS versions
            showAlert(title: title, body: body)
        }
    }
    
    private func showAlert(title: String, body: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = body
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "TypoZap needs accessibility permissions to copy and paste text. Please grant permission in System Preferences > Security & Privacy > Privacy > Accessibility."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Later")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
    
    // MARK: - Menu Actions
    @objc private func changeHotkey() {
        // TODO: Implement hotkey change dialog
        showNotification(title: "Coming Soon", body: "Hotkey change feature will be available in a future update.")
    }
    
    @objc private func setAPIKey() {
        requestAPIKey()
    }
    
    @objc private func toggleAutoCorrect() {
        // TODO: Implement auto-correct toggle
        showNotification(title: "Coming Soon", body: "Auto-correct toggle feature will be available in a future update.")
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - Helper Methods
    private func requestAPIKey() {
        // Create a custom input dialog that definitely supports copy-paste
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 180),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Gemini API Key Required"
        window.center()
        window.isReleasedWhenClosed = false
        window.level = .modalPanel
        
        // Create the main view
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 450, height: 180))
        
        // Create title label
        let titleLabel = NSTextField(labelWithString: "Please enter your Gemini API key")
        titleLabel.frame = NSRect(x: 20, y: 130, width: 410, height: 24)
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        titleLabel.alignment = .center
        contentView.addSubview(titleLabel)
        
        // Create help text
        let helpText = NSTextField(labelWithString: "You can get one from https://ai.google.dev/gemini-api")
        helpText.frame = NSRect(x: 20, y: 110, width: 410, height: 20)
        helpText.font = NSFont.systemFont(ofSize: 12)
        helpText.textColor = NSColor.secondaryLabelColor
        helpText.alignment = .center
        contentView.addSubview(helpText)
        
        // Create input field with proper configuration for copy-paste
        let input = NSTextField(frame: NSRect(x: 20, y: 60, width: 410, height: 32))
        input.placeholderString = "Enter your Gemini API key here"
        input.isEditable = true
        input.isSelectable = true
        input.allowsEditingTextAttributes = false
        input.cell?.wraps = false
        input.cell?.isScrollable = true
        input.cell?.usesSingleLineMode = true
        input.font = NSFont.systemFont(ofSize: 14)
        input.backgroundColor = NSColor.textBackgroundColor
        input.textColor = NSColor.textColor
        
        // Ensure copy-paste works by setting up proper text field behavior
        input.cell?.sendsActionOnEndEditing = false
        
        contentView.addSubview(input)
        
        // Create buttons
        let saveButton = NSButton(frame: NSRect(x: 270, y: 15, width: 80, height: 32))
        saveButton.title = "Save"
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r" // Enter key
        saveButton.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(saveButton)
        
        let cancelButton = NSButton(frame: NSRect(x: 360, y: 15, width: 80, height: 32))
        cancelButton.title = "Cancel"
        cancelButton.bezelStyle = .rounded
        cancelButton.keyEquivalent = "\u{1b}" // Escape key
        cancelButton.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(cancelButton)
        
        // Set up button actions using closures for better control
        saveButton.target = self
        saveButton.action = #selector(saveAPIKeyFromDialog)
        
        cancelButton.target = self
        cancelButton.action = #selector(cancelAPIKeyFromDialog)
        
        // Store references for the actions using instance properties
        self.currentAPIKeyInput = input
        self.currentAPIKeyWindow = window
        
        // Make input field the first responder and select all text
        DispatchQueue.main.async {
            input.becomeFirstResponder()
            input.selectText(nil)
        }
        
        // Set the content view and show the window
        window.contentView = contentView
        window.makeKeyAndOrderFront(nil)
        
        // Use NSApp.runModal instead of semaphore to avoid blocking
        NSApp.runModal(for: window)
        
        // Process the result after modal is dismissed
        if let apiKey = savedAPIKey, !apiKey.isEmpty {
            geminiService.setAPIKey(apiKey)
            showNotification(title: "API Key Saved", body: "Your Gemini API key has been saved successfully.")
        }
        
        // Clean up
        window.close()
        self.currentAPIKeyInput = nil
        self.currentAPIKeyWindow = nil
        self.savedAPIKey = nil
    }
    
    @objc private func saveAPIKeyFromDialog() {
        guard let input = currentAPIKeyInput else {
            return
        }
        
        let apiKey = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !apiKey.isEmpty {
            // Store the result
            self.savedAPIKey = apiKey
        }
        
        // Stop the modal and return control
        NSApp.stopModal()
    }
    
    @objc private func cancelAPIKeyFromDialog() {
        // Stop the modal and return control
        NSApp.stopModal()
    }
}
