import Foundation

/// Represents a timestamp (day) in the habit tracker
struct Timestamp: Codable, Comparable, Hashable {
    let unixTime: Int64
    
    init(unixTime: Int64) {
        self.unixTime = unixTime
    }
    
    init(year: Int, month: Int, day: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = TimeZone.current
        
        let calendar = Calendar.current
        if let date = calendar.date(from: components) {
            self.unixTime = Int64(date.timeIntervalSince1970)
        } else {
            self.unixTime = 0
        }
    }
    
    static func fromDate(_ date: Date) -> Timestamp {
        let unixTime = Int64(date.timeIntervalSince1970)
        return Timestamp(unixTime: unixTime)
    }
    
    static func today() -> Timestamp {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        return fromDate(startOfDay)
    }
    
    func toDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(unixTime))
    }
    
    func minus(_ days: Int) -> Timestamp {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .day, value: -days, to: toDate()) {
            return Timestamp.fromDate(newDate)
        }
        return self
    }
    
    func plus(_ days: Int) -> Timestamp {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .day, value: days, to: toDate()) {
            return Timestamp.fromDate(newDate)
        }
        return self
    }
    
    func toCSVString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: toDate())
    }
    
    static func fromCSVString(_ string: String) -> Timestamp? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        if let date = dateFormatter.date(from: string) {
            return fromDate(date)
        }
        return nil
    }
    
    static func < (lhs: Timestamp, rhs: Timestamp) -> Bool {
        return lhs.unixTime < rhs.unixTime
    }
}
