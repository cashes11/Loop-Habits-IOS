import Foundation

class CSVImporter {
    
    /// Imports habits from a CSV file in the Loop Habit Tracker format
    static func importHabits(from url: URL) throws -> [Habit] {
        let content = try String(contentsOf: url, encoding: .utf8)
        var habits: [Habit] = []
        
        let lines = content.components(separatedBy: .newlines)
        
        // Skip header line
        guard lines.count > 1 else {
            return habits
        }
        
        for i in 1..<lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            if line.isEmpty { continue }
            
            let fields = parseCSVLine(line)
            if fields.count < 12 { continue }
            
            let position = Int(fields[0]) ?? i
            let name = fields[1]
            let typeString = fields[2]
            let question = fields[3]
            let description = fields[4]
            let freqNum = Int(fields[5]) ?? 1
            let freqDen = Int(fields[6]) ?? 1
            let color = fields[7]
            let unit = fields[8]
            let targetTypeString = fields[9]
            let targetValueString = fields[10]
            let isArchived = fields[11].lowercased() == "true"
            
            let type: HabitType = typeString == "NUMERICAL" ? .NUMERICAL : .YES_NO
            let targetType: TargetType? = targetTypeString.isEmpty ? nil :
                (targetTypeString == "AT_MOST" ? .AT_MOST : .AT_LEAST)
            let targetValue: Double? = targetValueString.isEmpty ? nil : Double(targetValueString)
            
            let habit = Habit(
                position: position,
                name: name,
                type: type,
                question: question,
                description: description,
                frequencyNumerator: freqNum,
                frequencyDenominator: freqDen,
                color: color,
                unit: unit,
                targetType: targetType,
                targetValue: targetValue,
                isArchived: isArchived
            )
            
            habits.append(habit)
        }
        
        return habits
    }
    
    /// Imports checkmarks/entries for a specific habit
    static func importEntries(from url: URL) throws -> [Entry] {
        let content = try String(contentsOf: url, encoding: .utf8)
        var entries: [Entry] = []
        
        let lines = content.components(separatedBy: .newlines)
        
        // Skip header line (Date,Value,Notes)
        guard lines.count > 1 else {
            return entries
        }
        
        for i in 1..<lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            if line.isEmpty { continue }
            
            let fields = parseCSVLine(line)
            if fields.count < 2 { continue }
            
            guard let timestamp = Timestamp.fromCSVString(fields[0]) else {
                continue
            }
            
            let value = Int(fields[1]) ?? Entry.UNKNOWN
            let notes = fields.count > 2 ? fields[2] : ""
            
            entries.append(Entry(timestamp: timestamp, value: value, notes: notes))
        }
        
        return entries
    }
    
    /// Parses a CSV line handling quoted fields
    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        fields.append(currentField)
        return fields
    }
}
