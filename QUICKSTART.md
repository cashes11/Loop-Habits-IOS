# Quick Start Guide

## 🚀 Getting Your iOS App Running in 5 Minutes

### Prerequisites Checklist
- [ ] Mac computer with macOS
- [ ] Xcode installed (from Mac App Store)
- [ ] iPhone with iOS 17.0+
- [ ] USB cable to connect iPhone to Mac
- [ ] Apple ID (free account is fine)

### Quick Setup Steps

1. **Open in Xcode**
   ```bash
   cd /home/cashes11/GitHub/LoopHabitsIOS
   open LoopHabitsIOS.xcodeproj
   ```

2. **Configure Your Team**
   - Click project name in sidebar
   - Select target "LoopHabitsIOS"
   - Go to "Signing & Capabilities"
   - Select your Apple ID as Team
   - Change Bundle ID to: `com.YOURNAME.loophabits`

3. **Connect iPhone**
   - Plug in iPhone
   - Trust computer on iPhone
   - Select iPhone in Xcode device menu

4. **Build & Run**
   - Press ▶ (Play button) or Cmd+R
   - Wait for build...
   - App installs on your iPhone!

5. **Trust Developer**
   - On iPhone: Settings → General → VPN & Device Management
   - Tap your Apple ID → Trust

Done! The app is now on your iPhone! 🎉

---

## 📱 Key Features

### What Works Now
✅ Create and track habits (yes/no or numerical)
✅ Daily checkmarks with history
✅ Custom frequencies (daily, weekly, custom)
✅ Color-coded habits
✅ Streak tracking
✅ Import/Export CSV (Android compatible!)
✅ All data stored locally
✅ Works offline
✅ Privacy-focused (no tracking, no ads)

### Differences from Android
⚠️ No widgets yet (iOS limitation)
⚠️ No notifications/reminders yet
⚠️ Simplified statistics
⚠️ No habit score calculation

---

## 🔄 Transfer Your Android Data

### From Android
1. Loop app → Settings → Export
2. Email or upload to cloud
3. Share to iPhone

### On iPhone
1. Open Loop Habits iOS
2. Tap ↑ icon (top left)
3. Tap "Import from CSV"
4. Select your export folder

**Your complete habit history transfers in seconds!**

---

## 💾 Data Format Compatibility

The iOS app uses **identical CSV format** as Android:

```
Habits.csv              → Main habit list
001 HabitName/
  ├─ Checkmarks.csv    → Your daily entries
  └─ Scores.csv        → (not used yet)
```

**This means:**
- ✅ Export from Android → Import to iOS
- ✅ Export from iOS → Import to Android
- ✅ Edit CSVs manually if needed
- ✅ Backup your data anywhere

---

## 🔧 Common Issues & Fixes

### "Cannot verify app"
→ Settings → General → VPN & Device Management → Trust

### "No team selected"
→ Add your Apple ID in Xcode Preferences → Accounts

### App expires after 7 days
→ Reconnect iPhone and rebuild in Xcode (data preserved)
→ Or get paid Apple Developer account for permanent install

### Import fails
→ Select the folder, not individual CSV files
→ Folder must contain Habits.csv

---

## 📊 Usage Tips

### Creating a Habit
1. Tap + button
2. Enter name (required)
3. Set type (yes/no or numerical)
4. Choose frequency
5. Pick a color
6. Save!

### Checking Off a Habit
- **List view**: Tap any of the 7 day circles
- **Detail view**: Tap any day in the calendar grid

### Viewing History
- Tap habit name to see full history
- 7-week calendar shows your streak
- Statistics show total completions

### Export Backup
1. Tap ↑ icon
2. Tap "Export to CSV"
3. Share via AirDrop/email/Files

---

## 🎨 Customization

### Available Colors
- Orange (#FF8F00) - Default
- Teal (#00897B)
- Red (#D32F2F)
- Blue (#1976D2)
- Purple (#7B1FA2)
- Green (#388E3C)
- Dark Orange (#F57C00)
- Cyan (#0097A7)

### Frequency Options
- Daily (1 time per 1 day)
- 3 times per week
- Every other day
- Any custom frequency!

---

## 📂 Project Structure

```
LoopHabitsIOS/
├── Models/               → Data structures
│   ├── Habit.swift
│   ├── Entry.swift
│   └── Timestamp.swift
├── Services/             → Business logic
│   ├── HabitStore.swift
│   ├── CSVImporter.swift
│   └── CSVExporter.swift
├── Views/                → UI screens
│   ├── ContentView.swift
│   ├── HabitDetailView.swift
│   ├── AddHabitView.swift
│   └── ImportExportView.swift
└── LoopHabitsIOSApp.swift → Entry point
```

**Simple, clean architecture - easy to modify!**

---

## 🛠 Extending the App

Want to add features? The code is straightforward:

### Add a new view
1. Create new `.swift` file in Views/
2. Add SwiftUI View struct
3. Import in ContentView

### Modify data model
1. Edit `Habit.swift` or `Entry.swift`
2. Update CSV import/export if needed

### Change colors
1. Edit `AddHabitView.swift`
2. Add colors to `availableColors` array

---

## 📝 Version Info

**Version:** 1.0.0
**iOS Support:** 17.0+
**License:** GPLv3 (same as Android version)
**Android Compatibility:** Full CSV format compatibility

---

## 🆘 Need Help?

1. Read `INSTALLATION.md` for detailed setup
2. Read `DATA_TRANSFER.md` for import/export details
3. Check the code - it's well-commented!
4. All models are in `Models/` folder
5. All UI is in `Views/` folder

**The codebase is intentionally simple so you can customize it!**
