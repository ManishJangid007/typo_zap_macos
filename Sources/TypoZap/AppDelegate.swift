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
    
    // Tone selection properties
    private var selectedTone: String = "default"
    private let toneKey = "selectedTone"
    
    // MARK: - App Lifecycle
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 TypoZap launching...")
        print("🔍 App bundle path: \(Bundle.main.bundlePath)")
        print("🔍 App resource path: \(Bundle.main.resourcePath ?? "nil")")
        
        // Initialize services
        geminiService = GeminiService()
        clipboardManager = ClipboardManager()
        
        // Load selected tone from UserDefaults
        selectedTone = UserDefaults.standard.string(forKey: toneKey) ?? "default"
        print("🎭 Loaded tone: \(selectedTone)")
        
        // Request notification permissions (only if available)
        if #available(macOS 10.14, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let error = error {
                    print("Notification permission error: \(error)")
                }
            }
        }
        
        // Setup menu bar
        print("🎨 Setting up menu bar...")
        setupMenuBar()
        
        // Setup global hotkey
        print("⌨️ Setting up global hotkey...")
        setupGlobalHotkey()
        
        // Check for accessibility permissions
        print("🔐 Checking accessibility permissions...")
        checkAccessibilityPermissions()
        
        // Request API key if not set
        if !geminiService.hasValidAPIKey() {
            print("🔑 Requesting API key...")
            requestAPIKey()
        }
        
        print("✅ TypoZap launch complete!")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup
        hotKey = nil
    }
    
    // MARK: - Setup Methods
    private func setupMenuBar() {
        // Create status item in menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set custom icon if available, otherwise fall back to emoji
        if let button = statusItem.button {
            // Debug bundle information
            print("🔍 Bundle main path: \(Bundle.main.bundlePath)")
            print("🔍 Bundle resource path: \(Bundle.main.resourcePath ?? "nil")")
            
            // Try multiple methods to load the custom icon
            var iconLoaded = false
            
            // Method 1: Try NSImage(named:) first (Apple's recommended approach)
            if let icon = NSImage(named: "TypoZap") {
                print("✅ Successfully loaded icon using NSImage(named:)")
                iconLoaded = true
                configureIconForMenuBar(icon, button: button)
            }
            // Method 2: Try loading from file path
            else if let iconPath = Bundle.main.path(forResource: "TypoZap", ofType: "icns") {
                print("🔍 Found icon at: \(iconPath)")
                if let icon = NSImage(contentsOfFile: iconPath) {
                    print("✅ Successfully loaded custom icon from file")
                    iconLoaded = true
                    configureIconForMenuBar(icon, button: button)
                } else {
                    print("❌ Failed to load icon from path: \(iconPath)")
                }
            } else {
                print("⚠️ Icon file not found in bundle")
                // List all resources in bundle
                if let resources = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: nil) {
                    print("📁 Available resources: \(resources.map { $0.lastPathComponent })")
                }
            }
            
            // Fallback to emoji if no icon loaded
            if !iconLoaded {
                fallbackToEmojiIcon(button)
            }
        }
        
        // Create menu
        let menu = NSMenu()
        
        // Add menu items
        menu.addItem(NSMenuItem(title: "TypoZap is running", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        // Show current hotkey so users don't forget
        menu.addItem(NSMenuItem(title: "Current Hotkey: ⌥+T", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        // Add tone selection submenu
        let toneMenu = NSMenu()
        let toneMenuItem = NSMenuItem(title: "Tone: \(selectedTone.capitalized)", action: nil, keyEquivalent: "")
        
        // Add tone options
        let availableTones = geminiService.getAvailableTones()
        for tone in availableTones {
            let toneItem = NSMenuItem(title: tone.title.capitalized, action: #selector(selectTone), keyEquivalent: "")
            toneItem.target = self
            toneItem.representedObject = tone.title
            toneItem.state = (tone.title == selectedTone) ? .on : .off
            toneMenu.addItem(toneItem)
        }
        
        toneMenuItem.submenu = toneMenu
        menu.addItem(toneMenuItem)
        
        // Add tone description
        if let currentTone = geminiService.getToneByTitle(selectedTone) {
            let descriptionItem = NSMenuItem(title: currentTone.description, action: nil, keyEquivalent: "")
            descriptionItem.isEnabled = false
            menu.addItem(descriptionItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Set API Key", action: #selector(setAPIKey), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    private func fallbackToEmojiIcon(_ button: NSStatusBarButton) {
        button.title = "🔤"
        button.font = NSFont.systemFont(ofSize: 16)
        button.image = nil
    }
    
    private func loadIconFromBundle(_ iconName: String) -> NSImage? {
        // Try to load icon from bundle resources
        if let iconPath = Bundle.main.path(forResource: iconName, ofType: "icns") {
            if let icon = NSImage(contentsOfFile: iconPath) {
                // Configure the icon with different sizes based on type
                switch iconName {
                case "TypoZap":
                    icon.size = NSSize(width: 22, height: 22) // Main icon: 20% larger
                case "loader", "completed":
                    icon.size = NSSize(width: 25, height: 25) // Status icons: 39% larger
                default:
                    icon.size = NSSize(width: 22, height: 22) // Default size
                }
                
                icon.isTemplate = true // Makes it work better with system themes
                print("✅ Successfully loaded \(iconName) icon with size: \(icon.size)")
                return icon
            } else {
                print("❌ Failed to load \(iconName) icon from path: \(iconPath)")
            }
        } else {
            print("⚠️ \(iconName).icns not found in bundle")
        }
        return nil
    }
    
    private func configureIconForMenuBar(_ icon: NSImage, button: NSStatusBarButton) {
        // Configure the icon properly for menu bar
        icon.size = NSSize(width: 22, height: 22) // Increased by 20% from 18x18
        icon.isTemplate = true // Makes it work better with system themes
        
        button.image = icon
        button.imagePosition = .imageLeft
        button.imageScaling = .scaleProportionallyDown
        button.title = "" // Clear title when using image
        
        print("🎨 Icon configured with size: \(icon.size), template: \(icon.isTemplate)")
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
        print("🔐 Checking accessibility permissions...")
        print("🔍 App bundle identifier: \(Bundle.main.bundleIdentifier ?? "nil")")
        print("🔍 App bundle path: \(Bundle.main.bundlePath)")
        print("🔍 Process ID: \(ProcessInfo.processInfo.processIdentifier)")
        
        // Check if we're running from Applications folder
        let isFromApplications = Bundle.main.bundlePath.hasPrefix("/Applications/")
        print("🔍 Running from Applications folder: \(isFromApplications)")
        
        // First check without prompting to see current status
        let checkOptions = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let currentStatus = AXIsProcessTrustedWithOptions(checkOptions as CFDictionary)
        print("🔐 Current accessibility status: \(currentStatus)")
        
        if currentStatus {
            print("✅ Accessibility permissions already granted")
            return
        }
        
        // Only prompt if permissions are not granted
        print("⚠️ Accessibility permissions not granted, prompting user...")
        let promptOptions = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let promptResult = AXIsProcessTrustedWithOptions(promptOptions as CFDictionary)
        print("🔐 Prompt result: \(promptResult)")
        
        if !promptResult {
            showAccessibilityAlert()
        }
    }
    
    // MARK: - Hotkey Handler
    private func handleHotkeyPressed() {
        print("🔥 Hotkey pressed! Starting text correction process...")
        
        // Check accessibility permissions first
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        print("🔐 Accessibility enabled: \(accessEnabled)")
        
        if !accessEnabled {
            print("❌ Accessibility not enabled - text replacement will fail!")
            showNotification(title: "Accessibility Required", body: "Please grant accessibility permissions in System Preferences > Security & Privacy > Privacy > Accessibility")
            return
        }
        
        // Simulate Command+C to copy selected text
        print("📋 Attempting to simulate Command+C...")
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Press Command+C
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 8, keyDown: true) // 8 = C key
        keyDown?.flags = .maskCommand
        let postResult = keyDown?.post(tap: .cghidEventTap)
        print("📋 Command+C keyDown posted: \(postResult != nil)")
        
        // Release Command+C
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 8, keyDown: false)
        keyUp?.flags = .maskCommand
        let postResult2 = keyUp?.post(tap: .cghidEventTap)
        print("📋 Command+C keyUp posted: \(postResult2 != nil)")
        
        print("📋 Command+C executed, waiting for clipboard...")
        
        // Wait a bit for the copy to complete, then process
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.processSelectedText()
        }
    }
    
    private func processSelectedText() {
        print("📝 Processing selected text...")
        
        // Check clipboard content
        let clipboardContent = NSPasteboard.general.string(forType: .string)
        print("📋 Clipboard content: '\(clipboardContent ?? "nil")'")
        
        guard let selectedText = clipboardContent,
              !selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("❌ No valid text found in clipboard")
            showNotification(title: "No Text Selected", body: "Please select some text to correct.")
            return
        }
        
        print("✅ Valid text found: '\(selectedText)'")
        
        // Store original clipboard content
        let originalClipboard = clipboardManager.getCurrentClipboard()
        print("📋 Original clipboard stored: '\(originalClipboard)'")
        
        // Show processing indicator
        showProcessingIndicator()
        
        // Send to Gemini for correction
        print("🤖 Sending text to Gemini for correction with tone: \(selectedTone)...")
        geminiService.correctGrammar(text: selectedText, tone: selectedTone) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideProcessingIndicator()
                
                switch result {
                case .success(let correctedText):
                    print("✅ Gemini correction successful: '\(correctedText)'")
                    self?.applyCorrection(correctedText, originalClipboard: originalClipboard)
                case .failure(let error):
                    print("❌ Gemini correction failed: \(error)")
                    self?.showNotification(title: "Correction Failed", body: error.localizedDescription)
                }
            }
        }
    }
    
    private func applyCorrection(_ correctedText: String, originalClipboard: String) {
        print("📝 Applying correction: '\(correctedText)'")
        
        // Copy corrected text to clipboard
        clipboardManager.setClipboard(text: correctedText)
        print("📋 Corrected text copied to clipboard")
        
        // Verify clipboard was set
        let verifyClipboard = NSPasteboard.general.string(forType: .string)
        print("📋 Clipboard verification: '\(verifyClipboard ?? "nil")'")
        
        // Wait a bit longer for clipboard to be ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            print("📋 Attempting to simulate Command+V...")
            
            // Simulate Command+V to paste
            let source = CGEventSource(stateID: .combinedSessionState)
            
            // Press Command+V
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true) // 9 = V key
            keyDown?.flags = .maskCommand
            let postResult = keyDown?.post(tap: .cghidEventTap)
            print("📋 Command+V keyDown posted: \(postResult != nil)")
            
            // Release Command+V
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
            keyUp?.flags = .maskCommand
            let postResult2 = keyUp?.post(tap: .cghidEventTap)
            print("📋 Command+V keyUp posted: \(postResult2 != nil)")
            
            print("📋 Command+V executed")
            
            // Restore original clipboard after a longer delay to ensure paste completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.clipboardManager.setClipboard(text: originalClipboard)
                print("📋 Original clipboard restored")
            }
            
            // Show success feedback
            self?.showSuccessFeedback()
        }
    }
    
    // MARK: - Alternative Text Replacement Methods
    private func tryAlternativeTextReplacement(_ correctedText: String, originalClipboard: String) {
        print("🔄 Trying alternative text replacement method...")
        
        // Method 1: Try using NSPasteboard with a different approach
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(correctedText, forType: .string)
        
        // Try to trigger paste using a different event method
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Use a different event source
            let source = CGEventSource(stateID: .hidSystemState)
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true)
            keyDown?.flags = .maskCommand
            keyDown?.post(tap: .cghidEventTap)
            
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
            keyUp?.flags = .maskCommand
            keyUp?.post(tap: .cghidEventTap)
            
            print("🔄 Alternative Command+V executed")
            
            // Restore clipboard
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.clipboardManager.setClipboard(text: originalClipboard)
                self.showSuccessFeedback()
            }
        }
    }
    
    // MARK: - UI Feedback Methods
    private func showProcessingIndicator() {
        if let button = statusItem.button {
            print("⏳ Showing processing indicator")
            // Show custom loader icon
            if let loaderIcon = loadIconFromBundle("loader") {
                button.image = loaderIcon
                button.title = ""
                print("🎨 Loader icon displayed")
            } else {
                // Fallback to emoji if custom icon fails
                button.title = "⏳"
                button.image = nil
                print("⚠️ Using emoji fallback for loader")
            }
        }
    }
    
    private func hideProcessingIndicator() {
        if let button = statusItem.button {
            print("🔄 Hiding processing indicator, restoring normal icon")
            // Restore normal icon
            restoreNormalIcon(button)
        }
    }
    
    private func showSuccessFeedback() {
        if let button = statusItem.button {
            print("✅ Showing success feedback")
            // Show custom completed icon
            if let completedIcon = loadIconFromBundle("completed") {
                button.image = completedIcon
                button.title = ""
                print("🎨 Completed icon displayed")
            } else {
                // Fallback to emoji if custom icon fails
                button.title = "✅"
                button.image = nil
                print("⚠️ Using emoji fallback for success")
            }
            
            // Reset to normal icon after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                if let button = self?.statusItem.button {
                    print("🔄 Restoring normal icon after success")
                    self?.restoreNormalIcon(button)
                }
            }
        }
    }
    
    private func restoreNormalIcon(_ button: NSStatusBarButton) {
        // Try to restore custom icon with multiple methods
        var iconRestored = false
        
        // Method 1: Try NSImage(named:) first
        if let icon = NSImage(named: "TypoZap") {
            print("🎨 Restoring custom icon using NSImage(named:)")
            iconRestored = true
            configureIconForMenuBar(icon, button: button)
        }
        // Method 2: Try loading from file path
        else if let iconPath = Bundle.main.path(forResource: "TypoZap", ofType: "icns"),
                let icon = NSImage(contentsOfFile: iconPath) {
            print("🎨 Restoring custom icon from file")
            iconRestored = true
            configureIconForMenuBar(icon, button: button)
        }
        
        if !iconRestored {
            print("🔤 Falling back to emoji icon")
            button.title = "🔤"
            button.image = nil
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
    @objc private func setAPIKey() {
        requestAPIKey()
    }
    
    @objc private func selectTone(_ sender: NSMenuItem) {
        guard let toneTitle = sender.representedObject as? String else { return }
        
        selectedTone = toneTitle
        UserDefaults.standard.set(toneTitle, forKey: toneKey)
        print("🎭 Selected tone: \(toneTitle)")
        
        // Update menu to reflect new selection
        setupMenuBar()
        
        // Show notification
        if let tone = geminiService.getToneByTitle(toneTitle) {
            showNotification(title: "Tone Changed", body: "Now using \(toneTitle.capitalized) tone: \(tone.description)")
        }
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
        let pasteButton = NSButton(frame: NSRect(x: 20, y: 15, width: 80, height: 32))
        pasteButton.title = "Paste Key"
        pasteButton.bezelStyle = .rounded
        pasteButton.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(pasteButton)
        
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
        pasteButton.target = self
        pasteButton.action = #selector(pasteAPIKeyFromClipboard)
        
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
    
    @objc private func pasteAPIKeyFromClipboard() {
        guard let input = currentAPIKeyInput else {
            return
        }
        
        // Get the API key from clipboard
        if let clipboardText = NSPasteboard.general.string(forType: .string) {
            let trimmedText = clipboardText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedText.isEmpty {
                input.stringValue = trimmedText
                print("📋 API key pasted from clipboard: \(String(trimmedText.prefix(10)))...")
                
                // Show a brief success message
                showNotification(title: "Key Pasted", body: "API key has been pasted from clipboard")
            } else {
                print("⚠️ Clipboard is empty or contains only whitespace")
                showNotification(title: "Clipboard Empty", body: "No valid text found in clipboard")
            }
        } else {
            print("❌ No text found in clipboard")
            showNotification(title: "No Text", body: "No text found in clipboard")
        }
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
