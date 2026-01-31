import Foundation

/// Represents the score (strength) of a habit on a particular day
struct Score: Codable {
    let timestamp: Timestamp
    let value: Double  // 0.0 (weak) to 1.0 (strong)
    
    init(timestamp: Timestamp, value: Double) {
        self.timestamp = timestamp
        self.value = value
    }
    
    /// Computes the current score for a habit given the frequency, previous score, and checkmark value
    ///
    /// The frequency of the habit is the number of repetitions divided by the length of the interval.
    /// For example, a habit that should be repeated 3 times in 8 days has frequency 3.0 / 8.0 = 0.375.
    ///
    /// - Parameters:
    ///   - frequency: The habit frequency as a decimal (e.g., daily = 1.0, weekly = 1/7)
    ///   - previousScore: The score from the previous day
    ///   - checkmarkValue: The value of the current checkmark (0.0 to 1.0)
    /// - Returns: The computed score (0.0 to 1.0)
    static func compute(
        frequency: Double,
        previousScore: Double,
        checkmarkValue: Double
    ) -> Double {
        // Time decay multiplier - habits with higher frequency decay slower
        let multiplier = pow(0.5, sqrt(frequency) / 13.0)
        
        // Decay the previous score and add the current checkmark contribution
        var score = previousScore * multiplier
        score += checkmarkValue * (1 - multiplier)
        
        return score
    }
}
