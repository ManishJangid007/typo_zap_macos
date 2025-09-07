# Changelog

All notable changes to TypoZap will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-09-07

### Added
- 🎭 **Tone Selection Feature**: Choose from 5 different writing styles
  - Default: Standard grammar correction
  - Polite: Professional and courteous tone
  - Aggressive: Direct and assertive tone
  - Sarcastic: Witty and humorous tone
  - Funny: Playful and light-hearted tone
- ✨ **Enhanced Menu Bar Interface**: Better UI with tone descriptions
- 🎯 **Tone Persistence**: Selected tone is remembered between app launches
- 📱 **Visual Feedback**: Current tone highlighted with checkmark in menu
- 🔔 **Tone Change Notifications**: User gets notified when tone is changed
- 📦 **DMG Installer**: Professional DMG with one-click installation
- 📚 **Comprehensive Documentation**: Detailed setup and usage guides

### Changed
- 🔄 **Menu Bar Layout**: Reorganized menu with tone selection submenu
- 🎨 **User Experience**: Improved visual feedback and error messages
- 🔒 **API Key Management**: Enhanced security and error handling
- 📋 **Installation Process**: Streamlined and more reliable installation

### Fixed
- 🐛 **Installation Issues**: Fixed problems from previous release
- 🔧 **Accessibility Permissions**: Better handling and user guidance
- 📱 **Clipboard Management**: Improved text copying and pasting
- ⚠️ **Error Messages**: Clearer feedback for common issues

### Technical Improvements
- 🏗️ **Code Architecture**: Added tone management system
- 📁 **Resource Bundling**: Proper inclusion of tones.json in app bundle
- 🔧 **Build Process**: Enhanced install.sh to include all resources
- 📦 **Package Configuration**: Updated Package.swift for resource handling

## [1.0.0] - 2024-08-31

### Added
- 🚀 **Initial Release**: First version of TypoZap
- ⌨️ **Global Hotkey**: Option+T (⌥+T) for text correction
- 🤖 **AI Integration**: Google Gemini API for grammar correction
- 📱 **Menu Bar App**: Lightweight utility in macOS menu bar
- 🔒 **Secure Storage**: API keys stored in macOS Keychain
- 📋 **Smart Clipboard**: Preserves original clipboard contents
- 🎨 **Visual Feedback**: Icon changes show processing status
- 🔐 **Permission Management**: Accessibility permission handling
- 📚 **Documentation**: Comprehensive README and setup guides

### Features
- **Text Selection**: Works with any text field or application
- **Grammar Correction**: AI-powered grammar and spelling correction
- **Secure API**: HTTPS communication with Gemini API
- **No Local Storage**: Text is not stored locally
- **Cross-Platform**: Works with any macOS application
- **Error Handling**: Comprehensive error messages and recovery

---

## Release Notes Format

### Version Numbering
- **Major** (X.0.0): Breaking changes or major new features
- **Minor** (X.Y.0): New features, backwards compatible
- **Patch** (X.Y.Z): Bug fixes, backwards compatible

### Change Categories
- **Added**: New features
- **Changed**: Changes to existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security improvements

### Links
- [Unreleased]: https://github.com/ManishJangid007/typo_zap_macos/compare/v1.1.0...HEAD
- [1.1.0]: https://github.com/ManishJangid007/typo_zap_macos/compare/v1.0.0...v1.1.0
- [1.0.0]: https://github.com/ManishJangid007/typo_zap_macos/releases/tag/v1.0.0
