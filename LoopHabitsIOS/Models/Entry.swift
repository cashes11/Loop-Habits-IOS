import Foundation

/// Represents an entry/checkmark for a specific day
struct Entry: Codable, Identifiable {
    var id: String { "\(timestamp.unixTime)-\(value)" }
    
    let timestamp: Timestamp
    let value: Int
    let notes: String
    
    // Entry values matching Android app
    static let UNKNOWN = -1
    static let NO = 0
    static let YES_MANUAL = 2
    static let YES_AUTO = 1
    static let SKIP = 3
    
    init(timestamp: Timestamp, value: Int, notes: String = "") {
        self.timestamp = timestamp
        self.value = value
        self.notes = notes
    }
    
    var isYes: Bool {
        return value == Entry.YES_MANUAL || value == Entry.YES_AUTO
    }
    
    var isNo: Bool {
        return value == Entry.NO
    }
    
    var isSkip: Bool {
        return value == Entry.SKIP
    }
    
    var isUnknown: Bool {
        return value == Entry.UNKNOWN
    }
}
