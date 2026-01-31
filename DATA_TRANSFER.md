# Data Transfer Guide: Android → iOS

This guide explains how to transfer your habit data from the Android Loop Habit Tracker to the iOS version.

## Quick Overview

The iOS app uses **exactly the same CSV format** as the Android app, so data transfers seamlessly. No conversion needed!

## Method 1: Email Transfer (Easiest)

### On Android:
1. Open Loop Habit Tracker
2. Tap the menu (⋮) → Settings
3. Tap "Export full backup" or "Export to CSV"
4. Choose a location and export
5. Zip the exported folder
6. Email the zip file to yourself

### On iPhone:
1. Open the email on your iPhone
2. Download and save the zip file to Files app
3. Tap the zip file to extract it
4. Open Loop Habits iOS
5. Tap the export icon (↑) in top left
6. Tap "Import from CSV"
7. Navigate to the extracted folder
8. Select it
9. Done! All your habits and history are now on iOS

## Method 2: Cloud Storage

### Using Google Drive / Dropbox / iCloud:
1. Export from Android (as above)
2. Upload the export folder to your cloud storage
3. On iPhone, open the cloud storage app
4. Download the folder to Files app
5. Import using Loop Habits iOS (steps 4-9 above)

## Method 3: Computer Transfer

### Via USB:
1. Export from Android
2. Connect Android to computer and copy the export folder
3. Connect iPhone to computer
4. Use Finder (Mac) or iTunes (Windows) to add files to Files app
5. Import on iPhone

## What Gets Transferred?

✅ **All Habits**: Including names, descriptions, questions
✅ **All Settings**: Colors, frequencies, types
✅ **Complete History**: Every checkmark and entry
✅ **Notes**: All notes associated with entries
✅ **Timestamps**: Exact dates preserved
✅ **Numerical Data**: Values for numerical habits

## Understanding the Data Format

Your Android export creates a folder structure like this:

```
Loop_Habits_Export/
├── Habits.csv                    # Main habits list
├── 001 Meditate/
│   ├── Checkmarks.csv           # Your meditation history
│   └── Scores.csv               # (optional, not used in iOS yet)
├── 002 Wake up early/
│   ├── Checkmarks.csv
│   └── Scores.csv
└── ...
```

### Habits.csv Example:
```csv
Position,Name,Type,Question,Description,FrequencyNumerator,FrequencyDenominator,Color,Unit,Target Type,Target Value,Archived?
001,Meditate,YES_NO,Did you meditate this morning?,,1,1,#FF8F00,,,,false
002,Exercise,NUMERICAL,How many minutes?,,3,7,#00897B,minutes,AT_LEAST,30.0,false
```

### Checkmarks.csv Example:
```csv
Date,Value,Notes
2026-01-29,2,Felt great!
2026-01-28,2,
2026-01-27,0,Too busy
```

**Value meanings:**
- `2` = Yes (manually checked)
- `1` = Yes (auto-computed based on frequency)
- `0` = No
- `3` = Skip
- `-1` = Unknown
- For numerical habits: multiply actual value by 1000 (e.g., 30 minutes = 30000)

## Troubleshooting

### Import says "No habits found"
- Make sure you're selecting the **folder**, not a single CSV file
- The folder must contain a file named exactly `Habits.csv`

### Some habits are missing
- Check if they're archived in the Android app
- Archived habits are imported but hidden by default

### Dates look wrong
- Both apps use UTC timestamps, so dates should match exactly
- If you see issues, check your timezone settings

### Import fails with an error
- Make sure the CSV files weren't modified in Excel or other apps
- Excel sometimes changes date formats - use the original export files

### Values are 1000x too large
- For numerical habits, the Android app stores values × 1000
- The iOS app handles this conversion automatically
- If you manually edited CSV files, remember this multiplier

## Exporting from iOS Back to Android

The process works in reverse too!

1. In Loop Habits iOS, tap export icon
2. Tap "Export to CSV"
3. Share the folder via AirDrop, email, etc.
4. On Android, open Loop Habit Tracker
5. Settings → Import
6. Select the folder you transferred
7. Done!

## Regular Backups

**Recommendation:** Export your data regularly (weekly/monthly) to:
- Protect against data loss
- Keep a backup you can restore
- Transfer between devices anytime

Both apps make this easy with their built-in export features!

## Data Privacy

Both Android and iOS versions:
- Store data **only on your device**
- Never send data to any server
- Work completely offline
- Give you full control via CSV exports

Your habit data is yours and stays private! 🔒

---

**Need Help?**

If you encounter any issues:
1. Check that both apps are updated to latest versions
2. Try exporting a single habit first to test
3. Verify CSV files are not corrupted
4. Make sure folder structure matches the format above
