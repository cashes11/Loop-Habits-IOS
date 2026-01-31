# How to Install on Your iPhone

## Prerequisites

1. **Mac with Xcode**: You need a Mac computer with Xcode installed (free from Mac App Store)
2. **iPhone**: Running iOS 17.0 or later
3. **Apple ID**: You need an Apple ID (free, no paid developer account required for personal use)
4. **USB Cable**: To connect your iPhone to your Mac

## Step-by-Step Installation

### 1. Install Xcode

1. Open the Mac App Store
2. Search for "Xcode"
3. Click "Get" to download and install (it's large, ~15GB)
4. Wait for installation to complete

### 2. Prepare Your iPhone

1. Connect your iPhone to your Mac with a USB cable
2. On your iPhone, tap "Trust" when asked to trust this computer
3. Enter your iPhone passcode if prompted

### 3. Open the Project

1. On your Mac, navigate to where you have the project:
   ```bash
   cd /home/cashes11/GitHub/LoopHabitsIOS
   ```

2. Double-click `LoopHabitsIOS.xcodeproj` to open it in Xcode

### 4. Configure Signing

1. In Xcode, click on the blue "LoopHabitsIOS" project icon in the left sidebar
2. Select "LoopHabitsIOS" under TARGETS
3. Click the "Signing & Capabilities" tab
4. Check "Automatically manage signing"
5. In the "Team" dropdown, select your Apple ID
   - If you don't see your Apple ID, click "Add an Account..." and sign in
6. Change the "Bundle Identifier" to something unique, like:
   `com.yourname.loophabits` (replace "yourname" with your name)

### 5. Build and Install

1. At the top of Xcode, click the device dropdown (next to the play button)
2. Select your iPhone from the list
3. Click the Play button (▶) or press Cmd+R
4. Wait for the build to complete

### 6. Trust the Developer Certificate on Your iPhone

The first time you install:

1. On your iPhone, go to: **Settings → General → VPN & Device Management**
2. You'll see your Apple ID listed under "Developer App"
3. Tap your Apple ID
4. Tap "Trust [Your Apple ID]"
5. Tap "Trust" again to confirm

### 7. Launch the App!

The app should now be installed on your iPhone home screen as "Loop Habits". Tap to open!

## Troubleshooting

### "Unable to verify app"
- Follow step 6 to trust the developer certificate on your iPhone

### "Signing for LoopHabitsIOS requires a development team"
- Make sure you've added your Apple ID in step 4

### "Your device is not connected"
- Make sure your iPhone is unlocked
- Try unplugging and replugging the USB cable
- Make sure you tapped "Trust" on your iPhone

### App crashes on launch
- Make sure your iPhone is running iOS 17.0 or later
- Check: Settings → General → About → iOS Version

## Importing Your Android Data

Once the app is installed:

1. **Export from Android:**
   - Open Loop Habit Tracker on Android
   - Settings → Export
   - Share the export folder

2. **Transfer to iPhone:**
   - Email yourself the zip file, or
   - Use a cloud service (Google Drive, Dropbox), or
   - Use AirDrop if you have access to the Android files on another device

3. **Import on iPhone:**
   - Unzip the folder to your iPhone (Files app)
   - Open Loop Habits iOS
   - Tap the export icon (top left)
   - Tap "Import from CSV"
   - Navigate to and select the unzipped folder

Done! Your habits and all historical data should now be on your iPhone.

## Keeping the App Updated

Since this is a side-loaded app (not from App Store):
- The app will work for 7 days, then you need to rebuild and reinstall
- Each time you rebuild, your data is preserved (stored in UserDefaults)
- To avoid data loss, export your data regularly using the built-in export feature

### Alternative: Refresh the App Certificate

You can extend the 7-day limit:
1. Keep the project on your Mac
2. Connect your iPhone weekly
3. Click the Play button in Xcode to reinstall
4. This resets the 7-day timer

---

**Note:** If you want the app to stay permanently without weekly reinstalls, you would need a paid Apple Developer account ($99/year), or consider alternative distribution methods like TestFlight.
