import SwiftUI

// MARK: - Home screen layout constants

/// Width of each day column in the habit grid (header + cells must match).
private let kDayColumnWidth: CGFloat = 44
/// Number of recent days shown on the home screen (newest first, left to right).
private let kVisibleDays = 5
/// Horizontal inset applied identically to the header and each habit row so columns align.
private let kRowHorizontalPadding: CGFloat = 16

/// Uppercase 3-letter weekday, e.g. "SUN".
private func weekdayShort(_ ts: Timestamp) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    return formatter.string(from: ts.toDate()).uppercased()
}

/// Day-of-month number, e.g. "5".
private func dayOfMonth(_ ts: Timestamp) -> String {
    String(Calendar.current.component(.day, from: ts.toDate()))
}

struct ContentView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var showingAddHabit = false
    @State private var showingImportExport = false
    @State private var path: [UUID] = []
    /// How many days back the leftmost visible column is (0 == today). Driven by sliding the header.
    @State private var dayOffset = 0

    /// The visible day columns, newest first, shifted into the past by `dayOffset`.
    private var days: [Timestamp] {
        (0..<kVisibleDays).map { Timestamp.today().minus(dayOffset + $0) }
    }

    /// Non-archived habits in manual (position) order.
    private var visibleHabits: [Habit] {
        habitStore.habits
            .filter { !$0.isArchived }
            .sorted { $0.position < $1.position }
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                DaysHeaderView(days: days)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 15)
                            .onEnded { value in
                                // Slide left → older dates; slide right → back toward today.
                                let columns = Int((value.translation.width / kDayColumnWidth).rounded())
                                guard columns != 0 else { return }
                                withAnimation(.easeOut(duration: 0.2)) {
                                    dayOffset = max(0, dayOffset - columns)
                                }
                            }
                    )

                List {
                    ForEach(visibleHabits) { habit in
                        HabitGridRow(habit: habit, days: days) {
                            path.append(habit.id)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: kRowHorizontalPadding,
                                                  bottom: 6, trailing: kRowHorizontalPadding))
                    }
                    .onDelete(perform: deleteHabits)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Habits")
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
            .navigationDestination(for: UUID.self) { id in
                if let habit = habitStore.habits.first(where: { $0.id == id }) {
                    HabitDetailView(habit: habit)
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
        let habitsToDelete = offsets.map { visibleHabits[$0] }
        for habit in habitsToDelete {
            habitStore.deleteHabit(habit)
        }
    }
}

// MARK: - Days Header

/// The pinned header row: an empty area above the habit names, then one column
/// per recent day showing the weekday abbreviation and day-of-month.
struct DaysHeaderView: View {
    let days: [Timestamp]

    var body: some View {
        HStack(spacing: 0) {
            // Spacer occupying the habit-name column so day columns line up with the rows below.
            // (A Spacer only grows horizontally, so it won't stretch the header vertically.)
            Spacer(minLength: 0)

            ForEach(days, id: \.self) { day in
                VStack(spacing: 2) {
                    Text(weekdayShort(day))
                        .font(.caption2)
                        .fontWeight(.semibold)
                    Text(dayOfMonth(day))
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
                .frame(width: kDayColumnWidth)
            }
        }
        .padding(.horizontal, kRowHorizontalPadding)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }
}

// MARK: - Habit Grid Row

/// A single habit row: colored name on the left (tap to open detail) and one
/// tappable cell per recent day on the right (tap to record).
struct HabitGridRow: View {
    let habit: Habit
    let days: [Timestamp]
    let onSelectName: () -> Void
    @EnvironmentObject var habitStore: HabitStore
    @State private var numberEntryTimestamp: Timestamp?

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onSelectName) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(habit.colorValue)
                        .frame(width: 12, height: 12)
                    Text(habit.name)
                        .font(.body)
                        .foregroundColor(habit.colorValue)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            ForEach(days, id: \.self) { day in
                DayCell(habit: habit, day: day) {
                    if habit.type == .NUMERICAL {
                        numberEntryTimestamp = day
                    } else {
                        habitStore.toggleEntry(for: habit, on: day)
                    }
                }
                .frame(width: kDayColumnWidth)
            }
        }
        .sheet(item: $numberEntryTimestamp) { timestamp in
            NumberEntrySheet(habit: habit, timestamp: timestamp)
        }
    }
}

// MARK: - Day Cell

/// One day's cell for a habit. Boolean habits show a check/✕; numerical habits
/// show the recorded value and unit. Tapping triggers the row's record action.
struct DayCell: View {
    let habit: Habit
    let day: Timestamp
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if habit.type == .NUMERICAL {
                    numericalContent
                } else {
                    booleanContent
                }
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var booleanContent: some View {
        let done = habit.isCompletedOn(day)
        let skipped = habit.getEntry(for: day).isSkip

        if done {
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(habit.colorValue)
        } else if skipped {
            Image(systemName: "minus")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.gray.opacity(0.4))
        } else {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.gray.opacity(0.35))
        }
    }

    private var numericalContent: some View {
        let entry = habit.getEntry(for: day)
        let hasValue = entry.value > 0
        let value = Double(max(0, entry.value)) / 1000.0
        let met = habit.isCompletedOn(day)
        let color = met ? habit.colorValue : Color.gray.opacity(0.6)

        return VStack(spacing: 1) {
            Text(hasValue ? formatValue(value) : "0")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            if !habit.unit.isEmpty {
                Text(habit.unit)
                    .font(.system(size: 9))
                    .foregroundColor(color.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
    }

    private func formatValue(_ value: Double) -> String {
        // Numerical habits are integer-only.
        if value >= 10000 {
            return "\(Int(value / 1000))k"
        }
        return "\(Int(value))"
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
                            .keyboardType(.numberPad)
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
                    valueText = String(entry.value / 1000)
                }
                isTextFieldFocused = true
            }
        }
    }
    
    private func saveValue() {
        guard let value = Int(valueText), value >= 0 else { return }
        // Store integer value multiplied by 1000 (Android compatibility)
        let storedValue = value * 1000
        habitStore.setEntry(for: habit, on: timestamp, value: storedValue)
        dismiss()
    }
    
    private func formatTarget(_ target: Double) -> String {
        return String(Int(target))
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
