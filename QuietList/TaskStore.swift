import Foundation
import Combine

struct ListTask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isComplete = false
}

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [ListTask] = []
    @Published var errorMessage: String?
    private var canSave = true
    private let url: URL

    init() {
        url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("tasks.json")
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            tasks = try JSONDecoder().decode([ListTask].self, from: Data(contentsOf: url))
        } catch {
            // Don't overwrite unreadable data with an empty list.
            canSave = false
            errorMessage = "Your saved list couldn’t be opened. The original file has been left untouched. Try restarting the app before making changes."
        }
    }

    func add(_ title: String) {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        tasks.insert(ListTask(title: clean), at: 0)
        save()
    }

    func toggle(_ id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isComplete.toggle()
        save()
    }

    func rename(_ id: UUID, to title: String) {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty, let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].title = clean
        save()
    }

    func delete(_ id: UUID) { tasks.removeAll { $0.id == id }; save() }
    func clearCompleted() { tasks.removeAll { $0.isComplete }; save() }

    private func save() {
        guard canSave else {
            errorMessage = "Changes can’t be saved because the existing list couldn’t be read. Your original file is still untouched."
            return
        }
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        } catch {
            errorMessage = "Your latest changes couldn’t be saved. Please check your available storage and try again."
        }
    }
}
