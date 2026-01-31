import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @EnvironmentObject var habitStore: HabitStore
    @State private var selectedDate = Date()
    
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
                
                // Calendar view
                VStack(alignment: .leading, spacing: 16) {
                    Text("History")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    CalendarView(habit: habit)
                }
                
                Divider()
                
                // Statistics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Statistics")
                        .font(.headline)
                    
                    // Habit Score (Strength)
                    let score = habit.getCurrentScore()
                    let scorePercent = Int(score * 100)
                    HStack {
                        Text("Habit Strength")
                            .foregroundColor(.secondary)
                        Spacer()
                        HStack(spacing: 8) {
                            Text("\(scorePercent)%")
                                .bold()
                            ScoreBar(score: score, color: habit.colorValue)
                        }
                    }
                    
                    StatRow(title: "Frequency", value: "\(habit.frequencyNumerator) times every \(habit.frequencyDenominator) days")
                    
                    let streak = calculateStreak(for: habit)
                    StatRow(title: "Current Streak", value: "\(streak) days")
                    
                    let total = habit.entries.filter { $0.isYes }.count
                    StatRow(title: "Total Completions", value: "\(total)")
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
}

struct CalendarView: View {
    let habit: Habit
    @EnvironmentObject var habitStore: HabitStore
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
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

struct ScoreBar: View {
    let score: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 12)
                
                // Filled portion
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 80 * CGFloat(score), height: 12)
            }
        }
        .frame(width: 80, height: 12)
    }
}
