import SwiftUI
import Charts

struct HabitDetailView: View {
    let habit: Habit
    @EnvironmentObject var habitStore: HabitStore
    @State private var selectedDate = Date()
    @State private var showingHistoryEditor = false
    @State private var selectedTimestamp: Timestamp?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(habit.colorValue)
                            .frame(width: 20, height: 20)
                        
                        Text(habit.name)
                            .font(.title)
                            .bold()
                    }
                    
                    if !habit.question.isEmpty {
                        Text(habit.question)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    if !habit.description.isEmpty {
                        Text(habit.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Divider()
                
                // Score Chart (Habit Strength Over Time)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Habit Strength")
                            .font(.headline)
                        Spacer()
                        let score = habit.getCurrentScore()
                        let scorePercent = Int(score * 100)
                        Text("\(scorePercent)%")
                            .font(.title2)
                            .bold()
                            .foregroundColor(habit.colorValue)
                    }
                    .padding(.horizontal)
                    
                    ScoreChartView(habit: habit)
                        .frame(height: 200)
                        .padding(.horizontal)
                }
                
                Divider()
                
                // History Calendar (Editable)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("History")
                            .font(.headline)
                        Spacer()
                        Text("Tap to edit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    EditableCalendarView(habit: habit)
                }
                
                Divider()
                
                // Frequency Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weekly Frequency")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    FrequencyChartView(habit: habit)
                        .frame(height: 180)
                        .padding(.horizontal)
                }
                
                Divider()
                
                // Statistics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Statistics")
                        .font(.headline)
                    
                    let streak = calculateStreak(for: habit)
                    StatRow(title: "Current Streak", value: "\(streak) days")
                    
                    let bestStreak = calculateBestStreak(for: habit)
                    StatRow(title: "Best Streak", value: "\(bestStreak) days")
                    
                    let total = habit.entries.filter { $0.isYes }.count
                    StatRow(title: "Total Completions", value: "\(total)")
                    
                    StatRow(title: "Frequency", value: "\(habit.frequencyNumerator) times every \(habit.frequencyDenominator) days")
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedTimestamp) { timestamp in
            HistoryEditorSheet(habit: habit, timestamp: timestamp)
        }
    }
    
    private func calculateStreak(for habit: Habit) -> Int {
        var streak = 0
        var currentDate = Timestamp.today()
        
        while true {
            if habit.isCompletedOn(currentDate) {
                streak += 1
                currentDate = currentDate.minus(1)
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateBestStreak(for habit: Habit) -> Int {
        var bestStreak = 0
        var currentStreak = 0
        
        // Go back 365 days
        for daysAgo in 0..<365 {
            let timestamp = Timestamp.today().minus(daysAgo)
            if habit.isCompletedOn(timestamp) {
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return bestStreak
    }
}

// MARK: - Score Chart View
struct ScoreChartView: View {
    let habit: Habit
    
    var body: some View {
        let scores = getScoreData()
        
        if scores.isEmpty {
            Text("No data yet")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart(scores) { data in
                LineMark(
                    x: .value("Day", data.daysAgo),
                    y: .value("Score", data.score)
                )
                .foregroundStyle(habit.colorValue)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Day", data.daysAgo),
                    y: .value("Score", data.score)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [habit.colorValue.opacity(0.3), habit.colorValue.opacity(0.05)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: 15)) { value in
                    if let days = value.as(Int.self) {
                        AxisValueLabel {
                            Text("\(days)d")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 0.25, 0.5, 0.75, 1.0]) { value in
                    if let score = value.as(Double.self) {
                        AxisValueLabel {
                            Text("\(Int(score * 100))%")
                                .font(.caption2)
                        }
                    }
                }
            }
        }
    }
    
    private func getScoreData() -> [ScoreDataPoint] {
        var result: [ScoreDataPoint] = []
        let today = Timestamp.today()
        
        // Get scores for the last 90 days
        for daysAgo in (0..<90).reversed() {
            let timestamp = today.minus(daysAgo)
            let score = habit.getScore(for: timestamp)
            result.append(ScoreDataPoint(daysAgo: daysAgo, score: score))
        }
        
        return result
    }
}

struct ScoreDataPoint: Identifiable {
    let id = UUID()
    let daysAgo: Int
    let score: Double
}

// MARK: - Frequency Chart View
struct FrequencyChartView: View {
    let habit: Habit
    
    var body: some View {
        let frequency = getWeekdayFrequency()
        
        Chart(frequency) { data in
            BarMark(
                x: .value("Day", data.dayName),
                y: .value("Count", data.count)
            )
            .foregroundStyle(habit.colorValue)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
    
    private func getWeekdayFrequency() -> [WeekdayFrequency] {
        var weekdayCounts = [Int](repeating: 0, count: 7)
        let calendar = Calendar.current
        
        // Count completions by day of week (last 90 days)
        for daysAgo in 0..<90 {
            let timestamp = Timestamp.today().minus(daysAgo)
            if habit.isCompletedOn(timestamp) {
                let date = timestamp.toDate()
                let weekday = calendar.component(.weekday, from: date) // 1 = Sunday
                weekdayCounts[weekday - 1] += 1
            }
        }
        
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return (0..<7).map { index in
            WeekdayFrequency(dayName: dayNames[index], count: weekdayCounts[index])
        }
    }
}

struct WeekdayFrequency: Identifiable {
    let id = UUID()
    let dayName: String
    let count: Int
}

// MARK: - Editable Calendar View
struct EditableCalendarView: View {
    let habit: Habit
    @EnvironmentObject var habitStore: HabitStore
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        VStack(spacing: 8) {
            // Day labels
            HStack(spacing: 4) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<49, id: \.self) { daysAgo in
                    let timestamp = Timestamp.today().minus(48 - daysAgo)
                    let isCompleted = habit.isCompletedOn(timestamp)
                    
                    CheckmarkButton(
                        isChecked: isCompleted,
                        color: habit.colorValue,
                        size: .medium
                    ) {
                        habitStore.toggleEntry(for: habit, on: timestamp)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - History Editor Sheet
struct HistoryEditorSheet: View {
    let habit: Habit
    let timestamp: Timestamp
    @EnvironmentObject var habitStore: HabitStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(timestamp.toDate(), style: .date)
                    .font(.title2)
                    .bold()
                
                let isCompleted = habit.isCompletedOn(timestamp)
                
                Button(action: {
                    habitStore.toggleEntry(for: habit, on: timestamp)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title)
                        Text(isCompleted ? "Completed" : "Not Completed")
                            .font(.headline)
                    }
                    .foregroundColor(isCompleted ? habit.colorValue : .gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Make Timestamp identifiable for sheet presentation
extension Timestamp: Identifiable {
    public var id: Int64 { unixTime }
}

// MARK: - Supporting Views
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}
