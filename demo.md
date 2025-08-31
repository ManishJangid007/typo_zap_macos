# TypoZap Demo Guide 🚀

This guide will walk you through testing and using the TypoZap macOS menu bar app.

## 🏗️ Building the App

1. **Ensure you have the prerequisites:**
   - macOS 13.0 or later
   - Xcode Command Line Tools installed (`xcode-select --install`)

2. **Build the app:**
   ```bash
   # Option 1: Use the installation script (Recommended)
   ./install.sh
   
   # Option 2: Use the build script
   ./build.sh
   
   # Option 3: Build manually
   swift build -c release
   ```

3. **Run the app:**
   ```bash
   .build/release/TypoZap
   ```

## 🧪 Testing the App

### First Run Setup

1. **Launch TypoZap** - you should see the 🔤 icon in your menu bar
2. **Grant Accessibility Permissions** when prompted:
   - Go to System Preferences > Security & Privacy > Privacy > Accessibility
   - Add TypoZap and check the box
3. **Enter your Gemini API Key** when prompted:
   - Get a free API key from [Google AI Studio](https://ai.google.dev/gemini-api)
   - Enter it in the dialog that appears

### Testing the Grammar Correction

1. **Open any text editor** (TextEdit, Notes, etc.)
2. **Type some text with intentional errors**, for example:
   ```
   i went to the store yesterday and buyed some apples. they was very delicious.
   ```
3. **Select the text** (⌘+A to select all)
4. **Press ⌥+T** (Option+T)
5. **Watch the magic happen:**
   - App icon changes to ⏳ (processing)
   - Text gets corrected to: "I went to the store yesterday and bought some apples. They were very delicious."
   - App icon briefly shows ✅ (success)
   - Returns to 🔤 (ready)

### Testing Different Scenarios

#### ✅ **Working Cases:**
- Text in TextEdit, Notes, Pages
- Text in web browsers (Safari, Chrome)
- Text in messaging apps (Messages, WhatsApp)
- Text in email clients (Mail, Outlook)

#### ⚠️ **Edge Cases:**
- **No text selected**: Shows notification "No Text Selected"
- **Empty text**: Shows notification "No Text Selected"
- **Secure fields**: Password fields may block paste operations
- **Very long text**: May take longer to process

#### 🔒 **Security Features:**
- API key stored securely in macOS Keychain
- No text stored locally
- HTTPS communication with Gemini API

## 🎯 Menu Bar Features

Right-click the menu bar icon (🔤) to access:

- **Change Hotkey**: Coming in future updates
- **Set API Key**: Update your Gemini API key
- **Toggle Auto-Correct**: Coming in future updates
- **Quit**: Close the application

## 🐛 Troubleshooting

### Common Issues:

1. **"Accessibility Permission Required"**
   - Solution: Grant permissions in System Preferences

2. **"No API Key Found"**
   - Solution: Right-click menu bar icon → "Set API Key"

3. **Hotkey not working**
   - Check if another app uses ⌥+T
   - Verify accessibility permissions
   - Restart the app

4. **Text not being corrected**
   - Verify API key is valid
   - Check internet connection
   - Ensure text is selected

### Debug Mode:

Run from Terminal to see detailed logs:
```bash
swift run
```

## 📱 Visual Feedback Guide

| Icon | Meaning | Action Required |
|------|---------|-----------------|
| 🔤 | Ready | None - app is ready to use |
| ⏳ | Processing | Wait for Gemini API response |
| ✅ | Success | None - correction completed |
| ❌ | Error | Check notifications for details |

## 🔄 Workflow Example

Here's a complete workflow example:

1. **Open TextEdit** and create a new document
2. **Type**: "me and my friend goes to the movies every weekend"
3. **Select the text** (⌘+A)
4. **Press ⌥+T**
5. **Wait for processing** (icon shows ⏳)
6. **See the result**: "My friend and I go to the movies every weekend"
7. **Icon briefly shows ✅** then returns to 🔤

## 🎉 Success Indicators

- Text is automatically corrected and pasted
- Original clipboard content is restored
- App icon shows success feedback
- No manual intervention required

## 🚀 Advanced Usage

- **Batch correction**: Select multiple paragraphs and press ⌥+T
- **Quick fixes**: Use for emails, documents, social media posts
- **Learning tool**: See how AI improves your writing

---

**Happy TypoZapping! 🎯✨**
