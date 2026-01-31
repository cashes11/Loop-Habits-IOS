# Loop Habit Tracker - iOS Version

This is an iOS port of the Loop Habit Tracker Android app, maintaining full compatibility with the CSV data format for easy data transfer between platforms.

## Features

- ✅ Track yes/no habits and numerical habits
- ✅ Flexible schedules (daily, weekly, custom frequencies)
- ✅ Colorful habit tracking with visual feedback
- ✅ Streak tracking and statistics
- ✅ CSV Import/Export compatible with Android version
- ✅ Offline-first, no internet required
- ✅ Privacy-focused, data stays on your device

## Getting Started

### Requirements

- macOS with Xcode 15.0 or later
- iOS 17.0+ for deployment
- An Apple Developer account (free or paid) for installing on physical device

### Building the App

1. Open the project in Xcode:
   ```bash
   cd LoopHabitsIOS
   open LoopHabitsIOS.xcodeproj
   ```

2. Select your development team:
   - Click on the project in the navigator
   - Select the "LoopHabitsIOS" target
   - Go to "Signing & Capabilities"
   - Select your team from the dropdown

3. Connect your iPhone and select it as the destination

4. Press Cmd+R to build and run

### Transferring Data from Android

1. On your Android device:
   - Open Loop Habit Tracker
   - Go to Settings → Import/Export
   - Export to CSV
   - This creates a folder with Habits.csv and individual habit folders

2. Transfer the export folder to your iOS device using:
   - AirDrop
   - Files app via iCloud
   - Any file transfer method

3. On your iOS device:
   - Open Loop Habits iOS
   - Tap the export icon (top left)
   - Tap "Import from CSV"
   - Select the folder you transferred
   - Your habits and all their data will be imported!

## Data Format

The app uses the exact same CSV format as the Android version:

### Habits.csv Format
```
Position,Name,Type,Question,Description,FrequencyNumerator,FrequencyDenominator,Color,Unit,Target Type,Target Value,Archived?
001,Meditate,YES_NO,Did you meditate this morning?,,1,1,#FF8F00,,,,false
```

### Checkmarks.csv Format (per habit)
```
Date,Value,Notes
2026-01-29,2,
2026-01-28,2,Great session
```

Values:
- -1: Unknown
- 0: No
- 1: Yes (auto-computed)
- 2: Yes (manual)
- 3: Skip
- For numerical habits: actual value × 1000

## Architecture

- **SwiftUI**: Modern declarative UI framework
- **UserDefaults**: Simple JSON persistence for habits
- **No external dependencies**: Pure Swift implementation
- **MVVM pattern**: Clear separation of concerns

### File Structure

```
LoopHabitsIOS/
├── Models/
│   ├── Habit.swift          # Core habit data model
│   ├── Entry.swift          # Daily entry/checkmark model
│   └── Timestamp.swift      # Date/time utilities
├── Services/
│   ├── HabitStore.swift     # Data management and persistence
│   ├── CSVImporter.swift    # CSV import functionality
│   └── CSVExporter.swift    # CSV export functionality
├── Views/
│   ├── ContentView.swift        # Main habit list
│   ├── HabitDetailView.swift   # Individual habit view
│   ├── AddHabitView.swift      # Create new habit
│   └── ImportExportView.swift  # Import/Export UI
└── LoopHabitsIOSApp.swift      # App entry point
```

## Differences from Android Version

**Simplified for MVP:**
- No widgets (iOS limitations)
- No reminders/notifications yet
- Simplified statistics
- No habit score calculation (yet)

**Same functionality:**
- ✅ All habit tracking features
- ✅ CSV import/export
- ✅ Data format compatibility
- ✅ Frequency settings
- ✅ Color customization
- ✅ Numerical habits

## Future Enhancements

- [ ] iOS Widgets
- [ ] Notifications/Reminders
- [ ] Advanced statistics and charts
- [ ] Habit score calculation
- [ ] iCloud sync
- [ ] Dark mode optimization
- [ ] iPad optimization

## License

This project maintains the same GPLv3 license as the original Loop Habit Tracker.

## Credits

Original Android app by Álinson Santos Xavier (iSoron)
iOS port created to enable cross-platform habit tracking with data portability.
