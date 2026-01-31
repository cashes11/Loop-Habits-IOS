import SwiftUI

@main
struct LoopHabitsIOSApp: App {
    @StateObject private var habitStore = HabitStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(habitStore)
        }
    }
}
