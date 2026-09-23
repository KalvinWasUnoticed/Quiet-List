import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: TaskStore
    @State private var draft = ""
    @State private var showCompleted = false
    @State private var confirmClear = false
    @State private var editingTask: ListTask?
    @FocusState private var entryFocused: Bool

    private var pending: [ListTask] { store.tasks.filter { !$0.isComplete } }
    private var completed: [ListTask] { store.tasks.filter { $0.isComplete } }
    private let accent = Color(red: 0.28, green: 0.46, blue: 0.39)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    TextField("Add a task", text: $draft)
                        .focused($entryFocused)
                        .submitLabel(.done)
                        .onSubmit(addTask)
                        .accessibilityLabel("New task")
                    Button(action: addTask) {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .frame(width: 44, height: 44)
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Add task")
                }
                .padding(.leading, 16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)

                List {
                    if pending.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("A little room to breathe.")
                                .font(.headline).foregroundStyle(.primary)
                            Text("Add what matters. Leave the rest.")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 24)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    } else {
                        Section {
                            ForEach(pending) { task in taskRow(task) }
                        }
                    }
                    if !completed.isEmpty {
                        Section {
                            Button {
                                showCompleted.toggle()
                            } label: {
                                HStack {
                                    Text("Completed · \(completed.count)")
                                    Spacer()
                                    Image(systemName: showCompleted ? "chevron.up" : "chevron.down")
                                        .font(.caption.weight(.semibold))
                                }.foregroundStyle(.secondary)
                            }
                            .accessibilityHint(showCompleted ? "Hide completed tasks" : "Show completed tasks")
                            if showCompleted {
                                ForEach(completed) { task in taskRow(task) }
                                Button("Clear completed", role: .destructive) { confirmClear = true }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollDismissesKeyboard(.interactively)
                .scrollContentBackground(.hidden)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Quiet List")
            .tint(accent)
            .sheet(item: $editingTask) { task in
                EditTaskView(task: task) { store.rename(task.id, to: $0) }
                    .presentationDetents([.medium, .large])
            }
            .confirmationDialog("Delete all completed tasks?", isPresented: $confirmClear, titleVisibility: .visible) {
                Button("Delete completed tasks", role: .destructive) { store.clearCompleted() }
                Button("Cancel", role: .cancel) { }
            }
            .alert("Couldn’t save or load your list", isPresented: Binding(
                get: { store.errorMessage != nil },
                set: { if !$0 { store.errorMessage = nil } }
            )) {
                Button("OK") { store.errorMessage = nil }
            } message: { Text(store.errorMessage ?? "") }
        }
    }

    private func addTask() {
        guard !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        store.add(draft)
        draft = ""
        entryFocused = false
    }

    private func taskRow(_ task: ListTask) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Button { store.toggle(task.id) } label: {
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(task.isComplete ? accent : Color.secondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(task.isComplete ? "Mark \(task.title) incomplete" : "Complete \(task.title)")
            Button { editingTask = task } label: {
                Text(task.title)
                    .strikethrough(task.isComplete)
                    .foregroundStyle(task.isComplete ? .secondary : .primary)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .accessibilityHint("Edit task")
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 16))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", role: .destructive) { store.delete(task.id) }
        }
    }
}

private struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    let task: ListTask
    let onSave: (String) -> Void
    @State private var title: String

    init(task: ListTask, onSave: @escaping (String) -> Void) {
        self.task = task
        self.onSave = onSave
        _title = State(initialValue: task.title)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Task", text: $title, axis: .vertical)
                    .lineLimit(1...8)
                    .accessibilityLabel("Task text")
            }
            .navigationTitle("Edit task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(title); dismiss() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
