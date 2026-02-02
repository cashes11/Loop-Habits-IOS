import Foundation
import Combine

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    
    private let userDefaults = UserDefaults.standard
    private let habitsKey = "saved_habits"
    
    init() {
        loadHabits()
        
        // Create sample habit if no habits exist
        if habits.isEmpty {
            let sampleHabit = Habit(
                position: 1,
                name: "Meditate",
                question: "Did you meditate today?",
                description: "Daily meditation practice",
                frequencyNumerator: 1,
                frequencyDenominator: 1,
                color: "#FF8F00"
            )
            habits.append(sampleHabit)
            saveHabits()
        }
    }
    
    func addHabit(_ habit: Habit) {
        var newHabit = habit
        newHabit.position = habits.count + 1
        habits.append(newHabit)
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            var updatedHabit = habit
            updatedHabit.recomputeScores()
            habits[index] = updatedHabit
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        // Reorder positions
        for i in 0..<habits.count {
            habits[i].position = i + 1
        }
        saveHabits()
    }
    
    func toggleEntry(for habit: Habit, on timestamp: Timestamp) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else {
            return
        }
        
        var updatedHabit = habits[index]
        let currentEntry = updatedHabit.getEntry(for: timestamp)
        
        let newValue: Int
        if currentEntry.value == Entry.YES_MANUAL {
            newValue = Entry.NO
        } else {
            newValue = Entry.YES_MANUAL
        }
        
        let newEntry = Entry(timestamp: timestamp, value: newValue)
        updatedHabit.addEntry(newEntry)
        
        // Recompute scores after adding entry
        updatedHabit.recomputeScores()
        
        habits[index] = updatedHabit
        saveHabits()
    }
    
    func setEntry(for habit: Habit, on timestamp: Timestamp, value: Int, notes: String = "") {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else {
            return
        }
        
        var updatedHabit = habits[index]
        let newEntry = Entry(timestamp: timestamp, value: value, notes: notes)
        updatedHabit.addEntry(newEntry)        updatedHabit.recomputeScores()        
        updatedHabit.recomputeScores()
        habits[index] = updatedHabit
        saveHabits()
    }
    
    // MARK: - Persistence
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            userDefaults.set(encoded, forKey: habitsKey)
        }
    }
    
    private func loadHabits() {
        if let data = userDefaults.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
    
    // MARK: - Import/Export
    
    func exportToCSV() -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let exportDir = tempDir.appendingPathComponent("LoopHabitsExport_\(Date().timeIntervalSince1970)")
        
        do {
            try FileManager.default.createDirectory(at: exportDir, withIntermediateDirectories: true)
            try CSVExporter.exportAllData(habits, to: exportDir)
            return exportDir
        } catch {
            print("Export error: \(error)")
            return nil
        }
    }
    
    func importFromCSV(directory: URL) {
        do {var importedHabits = try CSVExporter.importAllData(from: directory)
            // Recompute scores for all imported habits
            for i in 0..<importedHabits.count {
                importedHabits[i].recomputeScores()
            }
            let importedHabits = try CSVExporter.importAllData(from: directory)
            habits = importedHabits
            saveHabits()
        } catch {
            print("Import error: \(error)")
        }
    }
}
