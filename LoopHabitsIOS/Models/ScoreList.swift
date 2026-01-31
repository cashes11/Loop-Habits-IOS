import Foundation

/// Manages the history of scores for a habit
class ScoreList {
    private var map: [Timestamp: Score] = [:]
    
    /// Returns the score for a given day
    /// If no score exists for that timestamp, returns a score with value 0.0
    func get(_ timestamp: Timestamp) -> Score {
        return map[timestamp] ?? Score(timestamp: timestamp, value: 0.0)
    }
    
    /// Returns scores for all days in the given interval (inclusive)
    /// The list is ordered by timestamp (newest first)
    func getByInterval(from: Timestamp, to: Timestamp) -> [Score] {
        var result: [Score] = []
        
        if from > to {
            return result
        }
        
        var current = to
        while current >= from {
            result.append(get(current))
            current = current.minus(1)
        }
        
        return result
    }
    
    /// Recomputes all scores between the provided timestamps
    func recompute(
        frequency: Frequency,
        isNumerical: Bool,
        targetType: TargetType?,
        targetValue: Double?,
        entries: [Entry],
        from: Timestamp,
        to: Timestamp
    ) {
        map.removeAll()
        
        var rollingSum = 0.0
        var numerator = frequency.numerator
        var denominator = frequency.denominator
        let freq = Double(numerator) / Double(denominator)
        
        // Build array of entry values for the interval
        let entriesByTimestamp = Dictionary(uniqueKeysWithValues: entries.map { ($0.timestamp, $0) })
        var values: [Int] = []
        var current = from
        while current <= to {
            let entry = entriesByTimestamp[current] ?? Entry(timestamp: current, value: Entry.UNKNOWN)
            values.append(entry.value)
            current = current.plus(1)
        }
        
        let isAtMost = targetType == .AT_MOST
        let target = targetValue ?? 0.0
        
        // For non-daily boolean habits, double the numerator and denominator
        // to smooth out irregular schedules (e.g., weekly habits on different days)
        if !isNumerical && freq < 1.0 {
            numerator *= 2
            denominator *= 2
        }
        
        var previousValue = isNumerical && isAtMost ? 1.0 : 0.0
        
        for i in 0..<values.count {
            let offset = values.count - i - 1
            
            if isNumerical {
                // For numerical habits, sum the values in the rolling window
                rollingSum += Double(max(0, values[offset]))
                if offset + denominator < values.count {
                    rollingSum -= Double(max(0, values[offset + denominator]))
                }
                
                let normalizedRollingSum = rollingSum / 1000.0  // Values stored × 1000
                
                if values[offset] != Entry.SKIP {
                    let percentageCompleted: Double
                    
                    if !isAtMost {
                        // AT_LEAST: percentage = min(1.0, sum / target)
                        if target > 0 {
                            percentageCompleted = min(1.0, normalizedRollingSum / target)
                        } else {
                            percentageCompleted = 1.0
                        }
                    } else {
                        // AT_MOST: percentage = 1 - ((sum - target) / target), clamped [0, 1]
                        if target > 0 {
                            let excess = (normalizedRollingSum - target) / target
                            percentageCompleted = max(0.0, min(1.0, 1.0 - excess))
                        } else {
                            percentageCompleted = normalizedRollingSum > 0 ? 0.0 : 1.0
                        }
                    }
                    
                    previousValue = Score.compute(
                        frequency: freq,
                        previousScore: previousValue,
                        checkmarkValue: percentageCompleted
                    )
                }
            } else {
                // For boolean habits, count YES_MANUAL in the rolling window
                if values[offset] == Entry.YES_MANUAL {
                    rollingSum += 1.0
                }
                if offset + denominator < values.count {
                    if values[offset + denominator] == Entry.YES_MANUAL {
                        rollingSum -= 1.0
                    }
                }
                
                if values[offset] != Entry.SKIP {
                    let percentageCompleted = min(1.0, rollingSum / Double(numerator))
                    previousValue = Score.compute(
                        frequency: freq,
                        previousScore: previousValue,
                        checkmarkValue: percentageCompleted
                    )
                }
            }
            
            let timestamp = from.plus(i)
            map[timestamp] = Score(timestamp: timestamp, value: previousValue)
        }
    }
    
    /// Returns the most recent score (highest timestamp)
    func getToday() -> Score {
        let today = Timestamp.today()
        return get(today)
    }
}

/// Helper struct to encapsulate frequency
struct Frequency {
    let numerator: Int
    let denominator: Int
    
    var toDouble: Double {
        return Double(numerator) / Double(denominator)
    }
    
    static let daily = Frequency(numerator: 1, denominator: 1)
    static let weekly = Frequency(numerator: 1, denominator: 7)
}
