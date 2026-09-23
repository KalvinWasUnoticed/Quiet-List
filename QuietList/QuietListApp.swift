import SwiftUI

@main
struct QuietListApp: App {
    @StateObject private var store = TaskStore()
    var body: some Scene {
        WindowGroup { ContentView().environmentObject(store) }
    }
}
