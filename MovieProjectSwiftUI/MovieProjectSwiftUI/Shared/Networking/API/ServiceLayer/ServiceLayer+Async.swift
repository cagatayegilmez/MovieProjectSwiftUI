import Foundation

extension ServiceLayer {
    /// Minimal async adapter to use the existing completion-based `ServiceLayer` from Swift Concurrency.
    ///
    /// This does not change request/response types or decoding behavior; it only bridges the callback into `async/await`.
    func send<T: APIRequest>(request: T, canRetry: Bool = true) async throws -> T.Response {
        try await withCheckedThrowingContinuation { continuation in
            self.send(request: request, canRetry: canRetry) { result in
                continuation.resume(with: result)
            }
        }
    }
}


