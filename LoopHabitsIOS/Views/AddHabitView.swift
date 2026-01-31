import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitStore: HabitStore
    
    @State private var name = ""
    @State private var question = ""
    @State private var description = ""
    @State private var habitType: HabitType = .YES_NO
    @State private var frequencyNumerator = 1
    @State private var frequencyDenominator = 1
    @State private var selectedColor = Color.orange
    @State private var unit = ""
    @State private var targetValue = ""
    
    let availableColors: [Color] = [
        Color(hex: "#FF8F00")!,
        Color(hex: "#00897B")!,
        Color(hex: "#D32F2F")!,
        Color(hex: "#1976D2")!,
        Color(hex: "#7B1FA2")!,
        Color(hex: "#388E3C")!,
        Color(hex: "#F57C00")!,
        Color(hex: "#0097A7")!
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    TextField("Question (optional)", text: $question)
                    TextField("Description (optional)", text: $description)
                }
                
                Section(header: Text("Type")) {
                    Picker("Habit Type", selection: $habitType) {
                        Text("Yes/No").tag(HabitType.YES_NO)
                        Text("Numerical").tag(HabitType.NUMERICAL)
                    }
                    .pickerStyle(.segmented)
                    
                    if habitType == .NUMERICAL {
                        TextField("Unit (e.g., km, minutes)", text: $unit)
                        TextField("Target value", text: $targetValue)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(header: Text("Frequency")) {
                    Stepper("Times: \(frequencyNumerator)", value: $frequencyNumerator, in: 1...100)
                    Stepper("Every days: \(frequencyDenominator)", value: $frequencyDenominator, in: 1...365)
                    
                    Text("Do this habit \(frequencyNumerator) time\(frequencyNumerator > 1 ? "s" : "") every \(frequencyDenominator) day\(frequencyDenominator > 1 ? "s" : "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                        ForEach(availableColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveHabit() {
        let habit = Habit(
            name: name,
            type: habitType,
            question: question.isEmpty ? "Did you \(name.lowercased()) today?" : question,
            description: description,
            frequencyNumerator: frequencyNumerator,
            frequencyDenominator: frequencyDenominator,
            color: selectedColor.toHex(),
            unit: habitType == .NUMERICAL ? unit : "",
            targetType: habitType == .NUMERICAL ? .AT_LEAST : nil,
            targetValue: habitType == .NUMERICAL ? Double(targetValue) : nil
        )
        
        habitStore.addHabit(habit)
        dismiss()
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView()
            .environmentObject(HabitStore())
    }
}
