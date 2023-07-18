import SwiftUI
import MultiSettings

@main
struct SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            SettingsView()
        }
            .commands {
                CommandGroup(replacing: .newItem) {}
            }
    }
}
