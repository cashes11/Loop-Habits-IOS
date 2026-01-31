import Foundation

class CSVExporter {
    
    /// Exports habits to CSV format matching the Android app
    static func exportHabits(_ habits: [Habit]) -> String {
        var csv = "Position,Name,Type,Question,Description,FrequencyNumerator,FrequencyDenominator,Color,Unit,Target Type,Target Value,Archived?\n"
        
        let sortedHabits = habits.sorted { $0.position < $1.position }
        
        for habit in sortedHabits {
            let fields = [
                String(format: "%03d", habit.position),
                escapeCSVField(habit.name),
                habit.type.rawValue,
                escapeCSVField(habit.question),
                escapeCSVField(habit.description),
                String(habit.frequencyNumerator),
                String(habit.frequencyDenominator),
                habit.color,
                habit.type == .NUMERICAL ? escapeCSVField(habit.unit) : "",
                habit.targetType?.rawValue ?? "",
                habit.targetValue != nil ? String(habit.targetValue!) : "",
                String(habit.isArchived)
            ]
            
            csv += fields.joined(separator: ",") + "\n"
        }
        
        return csv
    }
    
    /// Exports entries for a specific habit
    static func exportEntries(_ entries: [Entry]) -> String {
        var csv = "Date,Value,Notes\n"
        
        let sortedEntries = entries.sorted { $0.timestamp > $1.timestamp }
        
        for entry in sortedEntries {
            if entry.value == Entry.UNKNOWN {
                continue  // Don't export unknown entries
            }
            
            let fields = [
                entry.timestamp.toCSVString(),
                String(entry.value),
                escapeCSVField(entry.notes)
            ]
            
            csv += fields.joined(separator: ",") + "\n"
        }
        
        return csv
    }
    
    /// Exports all data to a directory structure matching Android app
    static func exportAllData(_ habits: [Habit], to directory: URL) throws {
        // Create main Habits.csv
        let habitsCSV = exportHabits(habits)
        let habitsURL = directory.appendingPathComponent("Habits.csv")
        try habitsCSV.write(to: habitsURL, atomically: true, encoding: .utf8)
        
        // Create individual habit folders with entries
        for habit in habits {
            let habitFolder = directory.appendingPathComponent(
                String(format: "%03d %@", habit.position, habit.name)
            )
            try FileManager.default.createDirectory(
                at: habitFolder,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            // Export checkmarks
            let checkmarksCSV = exportEntries(habit.entries)
            let checkmarksURL = habitFolder.appendingPathComponent("Checkmarks.csv")
            try checkmarksCSV.write(to: checkmarksURL, atomically: true, encoding: .utf8)
        }
    }
    
    /// Imports all data from a directory structure matching Android app
    static func importAllData(from directory: URL) throws -> [Habit] {
        let habitsURL = directory.appendingPathComponent("Habits.csv")
        var habits = try CSVImporter.importHabits(from: habitsURL)
        
        // Try to load entries for each habit
        for i in 0..<habits.count {
            let habitFolder = directory.appendingPathComponent(
                String(format: "%03d %@", habits[i].position, habits[i].name)
            )
            let checkmarksURL = habitFolder.appendingPathComponent("Checkmarks.csv")
            
            if FileManager.default.fileExists(atPath: checkmarksURL.path) {
                let entries = try CSVImporter.importEntries(from: checkmarksURL)
                habits[i].entries = entries
            }
        }
        
        return habits
    }
    
    /// Escapes special characters in CSV fields
    private static func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }
}
