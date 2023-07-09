import SwiftUI
import MultiSettings

@main
struct SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            SettingsView(newApp: true)
        }
            .commands {
                CommandGroup(replacing: .newItem) {}
            }
    }
}
