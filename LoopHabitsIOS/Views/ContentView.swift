import SwiftUI

struct ContentView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var showingAddHabit = false
    @State private var showingImportExport = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(habitStore.habits.filter { !$0.isArchived }) { habit in
                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                        HabitRowView(habit: habit)
                    }
                }
                .onDelete(perform: deleteHabits)
            }
            .navigationTitle("Loop Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingImportExport = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
            .sheet(isPresented: $showingImportExport) {
                ImportExportView()
            }
        }
    }
    
    private func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            let habit = habitStore.habits[index]
            habitStore.deleteHabit(habit)
        }
    }
}

struct HabitRowView: View {
    let habit: Habit
    @EnvironmentObject var habitStore: HabitStore
    @State private var showingNumberPicker = false
    @State private var selectedTimestamp: Timestamp?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(habit.colorValue)
                    .frame(width: 12, height: 12)
                
                Text(habit.name)
                    .font(.headline)
                
                Spacer()
                
                // Show score as percentage
                let score = habit.getCurrentScore()
                if score > 0 {
                    Text("\(Int(score * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !habit.question.isEmpty {
                Text(habit.question)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Show last 7 days - different UI for numerical vs yes/no
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { daysAgo in
                    let timestamp = Timestamp.today().minus(6 - daysAgo)
                    
                    if habit.type == .NUMERICAL {
                        NumericalButton(
                            habit: habit,
                            timestamp: timestamp,
                            color: habit.colorValue
                        ) {
                            selectedTimestamp = timestamp
                            showingNumberPicker = true
                        }
                    } else {
                        CheckmarkButton(
                            isChecked: habit.isCompletedOn(timestamp),
                            color: habit.colorValue,
                            size: .small
                        ) {
                            habitStore.toggleEntry(for: habit, on: timestamp)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingNumberPicker) {
            if let timestamp = selectedTimestamp {
                NumberEntrySheet(habit: habit, timestamp: timestamp)
            }
        }
    }
}

    }
}

// MARK: - Numerical Button
struct NumericalButton: View {
    let habit: Habit
    let timestamp: Timestamp
    let color: Color
    let action: () -> Void
    
    var body: some View {
        let entry = habit.getEntry(for: timestamp)
        let hasValue = entry.value > 0
        let displayValue = hasValue ? Double(entry.value) / 1000.0 : 0.0
        
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(hasValue ? color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                if hasValue {
                    Text(formatValue(displayValue))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                } else {
                    Text("–")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.0fk", value / 1000)
        } else if value >= 100 {
            return String(format: "%.0f", value)
        } else if value >= 10 {
            return String(format: "%.1f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// MARK: - Number Entry Sheet
struct NumberEntrySheet: View {
    let habit: Habit
    let timestamp: Timestamp
    @EnvironmentObject var habitStore: HabitStore
    @Environment(\.dismiss) var dismiss
    
    @State private var valueText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(timestamp.toDate(), style: .date)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(habit.name)
                        .font(.title2)
                        .bold()
                }
                .padding(.top)
                
                VStack(spacing: 16) {
                    HStack {
                        TextField("Value", text: $valueText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 48, weight: .bold))
                            .multilineTextAlignment(.center)
                            .focused($isTextFieldFocused)
                        
                        if !habit.unit.isEmpty {
                            Text(habit.unit)
                                .font(.title)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    if let target = habit.targetValue, target > 0 {
                        HStack {
                            Text("Target:")
                                .foregroundColor(.secondary)
                            Text("\(formatTarget(target)) \(habit.unit)")
                                .bold()
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
                
                HStack(spacing: 12) {
                    Button("Clear") {
                        habitStore.setEntry(for: habit, on: timestamp, value: 0)
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    Button("Save") {
                        saveValue()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(habit.colorValue)
                    .disabled(valueText.isEmpty)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Enter Value")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                let entry = habit.getEntry(for: timestamp)
                if entry.value > 0 {
                    valueText = String(format: "%.2f", Double(entry.value) / 1000.0)
                }
                isTextFieldFocused = true
            }
        }
    }
    
    private func saveValue() {
        guard let value = Double(valueText), value >= 0 else { return }
        // Store value multiplied by 1000 (Android compatibility)
        let storedValue = Int(value * 1000)
        habitStore.setEntry(for: habit, on: timestamp, value: storedValue)
        dismiss()
    }
    
    private func formatTarget(_ target: Double) -> String {
        if target.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", target)
        } else {
            return String(format: "%.2f", target)
        }
    }
}

struct CheckmarkButton: View {
    let isChecked: Bool
    let color: Color
    let size: ButtonSize
    let action: () -> Void
    
    enum ButtonSize {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 48
            case .large: return 64
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isChecked ? color : Color.gray.opacity(0.2))
                    .frame(width: size.dimension, height: size.dimension)
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: size.dimension * 0.5, weight: .bold))
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HabitStore())
    }
}
