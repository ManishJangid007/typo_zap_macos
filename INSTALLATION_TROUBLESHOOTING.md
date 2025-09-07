# TypoZap Installation Troubleshooting

## 🚨 "App is Damaged" Error

If you see the error **"TypoZap.app is damaged and can't be opened"**, this is a macOS security feature called Gatekeeper blocking unsigned apps. Here's how to fix it:

### Method 1: Bypass Gatekeeper (Recommended)

1. **Right-click** on `TypoZap.app` in Finder
2. Select **"Open"** from the context menu
3. Click **"Open"** in the security dialog that appears
4. The app will now launch normally

### Method 2: System Preferences

1. Go to **System Preferences** → **Security & Privacy**
2. Click the **"General"** tab
3. Look for a message about TypoZap being blocked
4. Click **"Open Anyway"**
5. Click **"Open"** when prompted

### Method 3: Terminal Command

Open Terminal and run:
```bash
sudo xattr -rd com.apple.quarantine /Applications/TypoZap.app
```

Then try opening the app normally.

## 🔒 Why This Happens

- **Gatekeeper Protection**: macOS blocks apps that aren't signed by Apple or registered developers
- **Security Feature**: This prevents potentially harmful software from running
- **Not Malware**: TypoZap is completely safe - it's just not code-signed

## ✅ After Installation

Once you've bypassed Gatekeeper:

1. **Grant Accessibility Permissions** when prompted
2. **Enter your Gemini API key** when requested
3. **Start using** with ⌥+T hotkey!

## 🛡️ Security Note

TypoZap is:
- ✅ **Open Source**: Code is publicly available on GitHub
- ✅ **No Malware**: Completely safe to use
- ✅ **Privacy Focused**: No data collection or tracking
- ✅ **Local Processing**: Only sends text to Google's secure API

## 📞 Need Help?

If you continue having issues:
1. Check the [GitHub Issues](https://github.com/ManishJangid007/typo_zap_macos/issues)
2. Verify you're using macOS 13.0 or later
3. Make sure you downloaded from the official GitHub release

---

**The app is safe to use - macOS is just being extra cautious! 🛡️**
