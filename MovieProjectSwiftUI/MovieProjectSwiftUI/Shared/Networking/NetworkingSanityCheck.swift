import Foundation

/// Minimal runtime sanity check to validate that a real API call can be made and decoded.
///
/// Runs only in DEBUG builds. No UI is involved.
enum NetworkingSanityCheck {
    static func run() async {
        #if DEBUG
        // Avoid running real network calls when the app is launched as a test host.
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return
        }
        do {
            let api = ServiceLayer()
            let response = try await api.send(request: GetNowPlayingListRequest())
            print("NetworkingSanityCheck: now_playing count = \(response.results.count)")
        } catch {
            print("NetworkingSanityCheck failed: \(error)")
        }
        #endif
    }
}


