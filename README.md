## 🖥️ Download & Install

1. [Download Checkpoint.dmg](https://github.com/damiensedgwick/Checkpoint/releases/latest)
2. Open the `.dmg` file
3. Drag `Checkpoint.app` to your `/Applications` folder
4. On first launch, right-click the app and choose **Open** to bypass macOS Gatekeeper warning.

🔨Building & Creating a DMG file

(You will need to install create-dmg) - `brew install create-dmg`

1. Make sure Xcode scheme is set to Release
2. Navigate to product > archive
3. Click distribution
4. Select custom, then copy and export to Desktop
5. Run `create-dmg Checkpoint.dmg Checkpoint/Checkpoint.app/` from your Desktop

You should now have a new .dmg file you can install.
