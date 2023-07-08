import SwiftUI
import MultiSettings

@main
struct SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            SettingsView(overwrite: false)
        }
            .commands {
                CommandGroup(replacing: .newItem) {}
            }
    }
}
