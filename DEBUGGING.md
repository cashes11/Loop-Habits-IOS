# Debugging & Development Guide

## 🎮 Playing with the App

### Option 1: iOS Simulator (No iPhone Needed!)

**Easiest way to test:**

1. Open project in Xcode:
   ```bash
   cd /home/cashes11/GitHub/LoopHabitsIOS
   open LoopHabitsIOS.xcodeproj
   ```

2. At the top of Xcode, select a simulator (e.g., "iPhone 15 Pro")

3. Press ▶ (Play) or Cmd+R

4. Simulator launches with your app!

**Simulator Benefits:**
- No physical device needed
- Instant testing
- Fast iteration
- Can simulate different screen sizes

### Option 2: Live Preview (Instant Feedback!)

**For UI changes:**

1. Open any View file (e.g., `ContentView.swift`)

2. Click "Resume" button in the preview pane (right side)
   - Or press Opt+Cmd+P

3. Interactive preview appears!

4. Edit code → Preview updates automatically

**Live Preview is FAST for UI tweaks!**

### Option 3: Real iPhone

Follow INSTALLATION.md - gives you real device testing

---

## 🔍 Debugging Tools

### 1. Print Statements

Add anywhere in your code:
```swift
print("DEBUG: Habit count = \(habitStore.habits.count)")
print("DEBUG: Entry value = \(entry.value)")
```

View output in Xcode's console (bottom panel)

### 2. Breakpoints

Click line number in Xcode → Red breakpoint appears

When code hits that line:
- Execution pauses
- Inspect variables
- Step through code
- View call stack

### 3. View Hierarchy Debugger

While app is running:
- Click 📱 icon in debug bar
- Shows 3D view of your UI
- Inspect any element
- See constraints

### 4. Memory Graph

Debug memory issues:
- Click memory icon in debug bar
- See all objects in memory
- Find leaks

---

## 🧪 Common Debugging Scenarios

### "Why isn't my habit saving?"

Add to `HabitStore.swift` → `saveHabits()`:
```swift
func saveHabits() {
    print("DEBUG: Saving \(habits.count) habits")
    if let encoded = try? JSONEncoder().encode(habits) {
        print("DEBUG: Encoded successfully")
        userDefaults.set(encoded, forKey: habitsKey)
    } else {
        print("ERROR: Failed to encode")
    }
}
```

### "CSV import not working?"

Add to `CSVImporter.swift` → `importHabits()`:
```swift
static func importHabits(from url: URL) throws -> [Habit] {
    print("DEBUG: Importing from \(url)")
    let content = try String(contentsOf: url, encoding: .utf8)
    print("DEBUG: File content length: \(content.count)")
    // ... rest of code
}
```

### "Entry values look wrong?"

Add to `HabitStore.swift` → `toggleEntry()`:
```swift
func toggleEntry(for habit: Habit, on timestamp: Timestamp) {
    let currentEntry = habit.getEntry(for: timestamp)
    print("DEBUG: Current value: \(currentEntry.value)")
    
    let newValue = currentEntry.value == Entry.YES_MANUAL ? Entry.NO : Entry.YES_MANUAL
    print("DEBUG: New value: \(newValue)")
    
    // ... rest of code
}
```

---

## 🎨 Quick UI Experiments

### Change Calendar Size

In `HabitDetailView.swift`, line 57:
```swift
ForEach(0..<49, id: \.self) { daysAgo in  // Change 49 to 70 for 10 weeks
```

### Change Colors Available

In `AddHabitView.swift`, line 18:
```swift
let availableColors: [Color] = [
    Color(hex: "#FF8F00")!,
    Color(hex: "#00897B")!,
    Color(hex: "#D32F2F")!,
    Color(hex: "#1976D2")!,
    Color(hex: "#7B1FA2")!,
    Color(hex: "#388E3C")!,
    Color(hex: "#F57C00")!,
    Color(hex: "#0097A7")!,
    // Add more here!
    Color(hex: "#E91E63")!,  // Pink
    Color(hex: "#FFC107")!   // Amber
]
```

### Show More Days in List View

In `ContentView.swift`, line 84:
```swift
ForEach(0..<7, id: \.self) { daysAgo in  // Change 7 to 14 for 2 weeks
```

---

## 🚀 Development Workflow

### Recommended Flow:

1. **Make changes** in Xcode
2. **Use Live Preview** for UI changes (instant feedback)
3. **Run in Simulator** for full app testing
4. **Add print statements** for debugging logic
5. **Test with real data** (create habits, check them off)
6. **Export CSV** to verify format
7. **Test on real iPhone** when ready

### Hot Reload Tip:

SwiftUI Live Preview gives you near-instant feedback!
- Change a color → See it immediately
- Adjust spacing → Updates live
- Add a button → Appears instantly

---

## 🛠 Useful Xcode Shortcuts

| Action | Shortcut |
|--------|----------|
| Build & Run | Cmd+R |
| Stop | Cmd+. |
| Clean Build | Cmd+Shift+K |
| Live Preview | Opt+Cmd+P |
| Open Quick | Cmd+Shift+O |
| Find in Project | Cmd+Shift+F |
| Jump to Definition | Cmd+Click |
| Show Documentation | Opt+Click |

---

## 📊 Testing Data Flow

### Create Test Data:

Add to `HabitStore.init()`:
```swift
init() {
    loadHabits()
    
    #if DEBUG
    // Test data for simulator
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
        createTestData()
    }
    #endif
}

private func createTestData() {
    let testHabit = Habit(
        position: 1,
        name: "Test Habit",
        question: "Did you test?",
        frequencyNumerator: 1,
        frequencyDenominator: 1,
        color: "#FF8F00"
    )
    
    // Add some test entries
    var habitWithEntries = testHabit
    for i in 0..<30 {
        let timestamp = Timestamp.today().minus(i)
        let value = i % 3 == 0 ? Entry.YES_MANUAL : Entry.NO
        habitWithEntries.addEntry(Entry(timestamp: timestamp, value: value))
    }
    
    habits = [habitWithEntries]
}
```

---

## 🐞 Common Issues & Solutions

### Simulator Issues

**Problem:** Simulator is slow
**Solution:** Use iPhone 15 (not Pro Max), disable Metal API validation

**Problem:** Can't type in text fields
**Solution:** Cmd+K to toggle keyboard, or use Mac keyboard

**Problem:** App doesn't install
**Solution:** Clean build (Cmd+Shift+K), then rebuild

### Preview Issues

**Problem:** Preview not showing
**Solution:** Click "Resume" or restart Xcode

**Problem:** Preview shows error
**Solution:** Check for syntax errors, ensure all imports are correct

**Problem:** Preview is outdated
**Solution:** Modify any code → Auto-refreshes

### Build Issues

**Problem:** "No such module 'SwiftUI'"
**Solution:** Select iOS deployment target 17.0+ in project settings

**Problem:** Code signing error
**Solution:** Re-select your team in Signing & Capabilities

---

## 💡 Pro Tips

1. **Use Simulator for speed** - Much faster than building to device
2. **Live Preview for UI** - Instant visual feedback
3. **Print liberally** - Don't be shy with debug prints
4. **Test with CSV exports** - Verify data format manually
5. **Keep Xcode console visible** - Catch issues early

---

## 🎯 Next Steps

1. Open project in Xcode
2. Select iPhone 15 Simulator
3. Press ▶ Play
4. Create a test habit
5. Check it off
6. View in detail page
7. Export and inspect CSV
8. Play around and have fun!

**Remember:** Simulator data persists between runs, just like a real device!
