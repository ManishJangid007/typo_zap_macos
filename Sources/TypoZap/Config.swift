import Foundation

struct Config {
    
    // MARK: - App Information
    static let appName = "TypoZap"
    static let appVersion = "1.0.0"
    static let bundleIdentifier = "com.typozap.app"
    
    // MARK: - Hotkey Configuration
    static let defaultHotkey = "⌥+T"
    static let hotkeyKey = Key.t
    static let hotkeyModifiers: [Modifier] = [.option]
    
    // MARK: - Gemini API Configuration
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"
    static let geminiModel = "gemini-pro"
    static let maxTokens = 1024
    static let temperature = 0.1
    
    // MARK: - UI Configuration
    static let iconNormal = "🔤"
    static let iconProcessing = "⏳"
    static let iconSuccess = "✅"
    static let iconError = "❌"
    
    // MARK: - Timing Configuration
    static let copyDelay: TimeInterval = 0.1
    static let pasteDelay: TimeInterval = 0.2
    static let successIconDuration: TimeInterval = 1.0
    
    // MARK: - Keychain Configuration
    static let keychainService = "com.typozap.gemini"
    static let keychainAccount = "api_key"
    
    // MARK: - Notification Configuration
    static let notificationTimeout: TimeInterval = 3.0
    
    // MARK: - Error Messages
    static let errorMessages = [
        "noAPIKey": "No API key found. Please set your Gemini API key.",
        "invalidURL": "Invalid URL for API request.",
        "noData": "No data received from API.",
        "invalidResponse": "Invalid response from API.",
        "accessibilityRequired": "TypoZap needs accessibility permissions to copy and paste text.",
        "noTextSelected": "Please select some text to correct."
    ]
}

// MARK: - Enums for Configuration
enum Key: String, CaseIterable {
    case p = "p"
    case t = "t"
    case c = "c"
    case v = "v"
    
    var displayName: String {
        return self.rawValue.uppercased()
    }
}

enum Modifier: String, CaseIterable {
    case command = "⌘"
    case option = "⌥"
    case control = "⌃"
    case shift = "⇧"
    
    var displayName: String {
        return self.rawValue
    }
}
