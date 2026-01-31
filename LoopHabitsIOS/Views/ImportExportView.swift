import SwiftUI
import UniformTypeIdentifiers

struct ImportExportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitStore: HabitStore
    @State private var showingExportSuccess = false
    @State private var showingImportPicker = false
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Export Data")) {
                    Button(action: exportData) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export to CSV")
                        }
                    }
                }
                
                Section(header: Text("Import Data")) {
                    Button(action: { showingImportPicker = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import from CSV")
                        }
                    }
                }
                
                Section(header: Text("Information")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CSV Format")
                            .font(.headline)
                        
                        Text("The export creates a folder containing:")
                            .font(.caption)
                        
                        Text("• Habits.csv - List of all habits")
                            .font(.caption)
                        
                        Text("• [Habit folders] - Each containing Checkmarks.csv")
                            .font(.caption)
                        
                        Text("\nThis format is compatible with the Android Loop Habit Tracker app.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Import / Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Export/Import", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.folder],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
        }
    }
    
    private func exportData() {
        guard let url = habitStore.exportToCSV() else {
            alertMessage = "Failed to export data. Please try again."
            showingAlert = true
            return
        }
        
        exportURL = url
        showingShareSheet = true
    }
    
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                alertMessage = "Could not access the selected folder."
                showingAlert = true
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            habitStore.importFromCSV(directory: url)
            alertMessage = "Successfully imported \(habitStore.habits.count) habit(s)!"
            showingAlert = true
            
        case .failure(let error):
            alertMessage = "Import failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ImportExportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportExportView()
            .environmentObject(HabitStore())
    }
}
