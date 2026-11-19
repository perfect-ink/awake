import SwiftUI

@main
struct AwakeApp: App {
    @StateObject private var appState = AppState()

    init() {
        LegacyBundleIDMigration.run(legacyID: "com.awake.app")
    }

    var body: some Scene {
        MenuBarExtra {
            AppMenu()
                .environmentObject(appState)
        } label: {
            HStack(spacing: 2) {
                Image(systemName: appState.caffeineActive ? "cup.and.saucer.fill" : "cup.and.saucer")
                if appState.isDimmed {
                    Image(systemName: "moon.fill")
                }
            }
        }
        .menuBarExtraStyle(.menu)

        Window("Settings", id: "settings") {
            SettingsView()
                .environmentObject(appState)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 440, height: 360)
        .defaultPosition(.center)
    }
}

/// The bundle ID moved to org.perfectink.* in November 2026, and preferences
/// are stored under the bundle ID. On the first launch under the new ID, copy
/// the old domain's values across so nobody loses their settings. Values
/// already saved under the new ID win, and it runs only once.
enum LegacyBundleIDMigration {
    static let doneKey = "perfectink.migratedLegacyBundleID"

    static func run(legacyID: String,
                    currentID: String? = Bundle.main.bundleIdentifier,
                    defaults: UserDefaults = .standard) {
        guard let currentID, currentID != legacyID,
              !defaults.bool(forKey: doneKey) else { return }
        let existing = defaults.persistentDomain(forName: currentID) ?? [:]
        let legacy = defaults.persistentDomain(forName: legacyID) ?? [:]
        for (key, value) in legacy where existing[key] == nil {
            defaults.set(value, forKey: key)
        }
        defaults.set(true, forKey: doneKey)
    }
}
