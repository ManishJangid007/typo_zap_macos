# TypoZap 🔤

A macOS menu bar utility that automatically corrects grammar and spelling using Google's Gemini AI API. Simply press **Option+T** to grab selected text, send it for correction, and paste the improved version back.

## ✨ Features

- **Global Hotkey**: Press `⌥+T` from anywhere to correct selected text
- **AI-Powered**: Uses Google's Gemini API for intelligent grammar correction
- **Seamless Integration**: Works with any text field or application
- **Secure**: API keys stored securely in macOS Keychain
- **Menu Bar App**: Lightweight, always accessible from the top menu bar
- **Smart Clipboard Management**: Preserves your original clipboard contents

## 🚀 Quick Start

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later (for building)
- Gemini API key from [Google AI Studio](https://ai.google.dev/gemini-api)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd typo_zap
   ```

2. **Install using the installation script (Recommended)**
   ```bash
   ./install.sh
   ```
   
   This will:
   - Build the project
   - Create a proper macOS app bundle
   - Install to your Applications folder
   - Launch the app automatically

3. **Alternative: Manual build and run**
   ```bash
   swift build -c release
   .build/release/TypoZap
   ```

4. **Set up your API key**
   - The app will prompt you for your Gemini API key on first run
   - Enter your API key when prompted
   - It will be securely stored in your macOS Keychain

### Getting a Gemini API Key

1. Visit [Google AI Studio](https://ai.google.dev/gemini-api)
2. Sign in with your Google account
3. Create a new API key
4. Copy the key and paste it into TypoZap when prompted

## 🔧 Setup & Permissions

### Required Permissions

TypoZap needs the following permissions to function properly:

1. **Accessibility Permissions**
   - Go to **System Preferences > Security & Privacy > Privacy > Accessibility**
   - Add TypoZap to the list of allowed applications
   - This allows the app to simulate keyboard shortcuts (⌘+C, ⌘+V)

2. **Input Monitoring** (if prompted)
   - Some macOS versions may require input monitoring permissions
   - This allows the app to detect the global hotkey

### First Run Setup

1. Launch TypoZap
2. Grant accessibility permissions when prompted
3. Enter your Gemini API key
4. The app icon (🔤) will appear in your menu bar
5. You're ready to use! Select text and press ⌥+T

## 📱 How to Use

### Basic Usage

1. **Select text** in any application (email, document, web browser, etc.)
2. **Press ⌥+T** (Option+T)
3. **Wait for correction** - the app icon will show ⏳ while processing
4. **See the result** - corrected text is automatically pasted, original clipboard restored

### Menu Bar Options

Right-click the menu bar icon (🔤) to access:

- **Change Hotkey**: Customize the keyboard shortcut (coming soon)
- **Set API Key**: Update or change your Gemini API key
- **Toggle Auto-Correct**: Enable/disable automatic correction (coming soon)
- **Quit**: Close the application

### Visual Feedback

- **🔤** - Normal state, ready to use
- **⏳** - Processing text with Gemini API
- **✅** - Correction completed successfully

## 🏗️ Project Structure

```
typo_zap/
├── Package.swift              # Swift Package Manager configuration
├── Sources/
│   └── TypoZap/
│       ├── main.swift         # App entry point
│       ├── AppDelegate.swift  # Main app logic and menu bar setup
│       ├── GeminiService.swift # Gemini API integration
│       ├── ClipboardManager.swift # Clipboard operations
│       └── Info.plist         # App configuration
└── README.md                  # This file
```

## 🔒 Security & Privacy

- **API Keys**: Stored securely in macOS Keychain, never in plain text
- **Text Processing**: Text is sent directly to Google's Gemini API over HTTPS
- **Local Storage**: No text or corrections are stored locally
- **Permissions**: Only requests necessary system permissions for functionality

## 🐛 Troubleshooting

### Common Issues

1. **"Accessibility Permission Required"**
   - Go to System Preferences > Security & Privacy > Privacy > Accessibility
   - Add TypoZap and ensure it's checked

2. **"No API Key Found"**
   - Right-click the menu bar icon and select "Set API Key"
   - Enter your valid Gemini API key

3. **Hotkey not working**
   - Check if another app is using ⌥+T
   - Ensure TypoZap has accessibility permissions
   - Try restarting the app

4. **Text not being corrected**
   - Verify your API key is valid
   - Check your internet connection
   - Ensure the selected text is not empty

### Debug Mode

To see detailed logs, run the app from Terminal:
```bash
swift run
```

## 🚧 Development

### Building from Source

1. **Install Xcode Command Line Tools**
   ```bash
   xcode-select --install
   ```

2. **Build the project**
   ```bash
   swift build
   ```

3. **Run in debug mode**
   ```bash
   swift run
   ```

### Dependencies

- **HotKey**: Global hotkey detection library
- **AppKit**: macOS UI framework
- **Foundation**: Core Swift functionality
- **Security**: Keychain integration

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Support

If you encounter any issues or have questions:

1. Check the troubleshooting section above
2. Review the project documentation
3. Open an issue on GitHub
4. Ensure you're using the latest version

## 🔄 Updates

TypoZap will check for updates automatically. New versions include:
- Bug fixes and performance improvements
- New features and customization options
- Enhanced AI correction capabilities
- Better macOS compatibility

---

**Made with ❤️ for macOS users who want perfect grammar without the hassle.**
