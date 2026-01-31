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
            
            // Show last 7 days
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { daysAgo in
                    let timestamp = Timestamp.today().minus(6 - daysAgo)
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
        .padding(.vertical, 4)
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
