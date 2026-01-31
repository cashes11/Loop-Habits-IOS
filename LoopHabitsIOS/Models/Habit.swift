import Foundation
import SwiftUI

enum HabitType: String, Codable {
    case YES_NO = "YES_NO"
    case NUMERICAL = "NUMERICAL"
}

enum TargetType: String, Codable {
    case AT_LEAST = "AT_LEAST"
    case AT_MOST = "AT_MOST"
}

/// Represents a single habit
struct Habit: Identifiable, Codable {
    var id: UUID
    var position: Int
    var name: String
    var type: HabitType
    var question: String
    var description: String
    var frequencyNumerator: Int
    var frequencyDenominator: Int
    var color: String  // Hex color like "#FF8F00"
    var unit: String
    var targetType: TargetType?
    var targetValue: Double?
    var isArchived: Bool
    var entries: [Entry]
    
    // Score calculation (not stored in CSV, computed on demand)
    private var scoreList: ScoreList?
    
    init(
        id: UUID = UUID(),
        position: Int = 0,
        name: String,
        type: HabitType = .YES_NO,
        question: String = "",
        description: String = "",
        frequencyNumerator: Int = 1,
        frequencyDenominator: Int = 1,
        color: String = "#FF8F00",
        unit: String = "",
        targetType: TargetType? = nil,
        targetValue: Double? = nil,
        isArchived: Bool = false,
        entries: [Entry] = []
    ) {
        self.id = id
        self.position = position
        self.name = name
        self.type = type
        self.question = question
        self.description = description
        self.frequencyNumerator = frequencyNumerator
        self.frequencyDenominator = frequencyDenominator
        self.color = color
        self.unit = unit
        self.targetType = targetType
        self.targetValue = targetValue
        self.isArchived = isArchived
        self.entries = entries
    }
    
    var colorValue: Color {
        Color(hex: color) ?? .orange
    }
    
    func getEntry(for timestamp: Timestamp) -> Entry {
        return entries.first { $0.timestamp.unixTime == timestamp.unixTime }
            ?? Entry(timestamp: timestamp, value: Entry.UNKNOWN)
    }
    
    mutating func addEntry(_ entry: Entry) {
        // Remove existing entry for this timestamp
        entries.removeAll { $0.timestamp.unixTime == entry.timestamp.unixTime }
        // Add new entry
        entries.append(entry)
        // Sort by timestamp (newest first)
        entries.sort { $0.timestamp > $1.timestamp }
    }
    
    func isCompletedOn(_ timestamp: Timestamp) -> Bool {
        let entry = getEntry(for: timestamp)
        return entry.isYes
    }
    
    /// Recomputes the score history for this habit
    mutating func recomputeScores() {
        guard !entries.isEmpty else {
            scoreList = nil
            return
        }
        
        // Find the date range
        let timestamps = entries.map { $0.timestamp }.sorted()
        guard let earliest = timestamps.first, let latest = timestamps.last else {
            scoreList = nil
            return
        }
        
        // Extend the range to today if needed
        let today = Timestamp.today()
        let to = latest > today ? latest : today
        
        let list = ScoreList()
        list.recompute(
            frequency: Frequency(numerator: frequencyNumerator, denominator: frequencyDenominator),
            isNumerical: type == .NUMERICAL,
            targetType: targetType,
            targetValue: targetValue,
            entries: entries,
            from: earliest,
            to: to
        )
        
        scoreList = list
    }
    
    /// Gets the current score for this habit (0.0 to 1.0)
    /// Returns 0.0 if scores haven't been computed
    func getCurrentScore() -> Double {
        guard let scoreList = scoreList else {
            return 0.0
        }
        return scoreList.getToday().value
    }
    
    /// Gets the score for a specific date
    func getScore(for timestamp: Timestamp) -> Double {
        guard let scoreList = scoreList else {
            return 0.0
        }
        return scoreList.get(timestamp).value
    }
    
    /// Gets scores for a date range
    func getScores(from: Timestamp, to: Timestamp) -> [Score] {
        guard let scoreList = scoreList else {
            return []
        }
        return scoreList.getByInterval(from: from, to: to)
    }
}

// Helper extension for Color from hex
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
