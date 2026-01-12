import Foundation

/// Base coordinator abstraction for MVVM-C.
///
/// Coordinators own navigation/flow only. They must not own UI state or business data.
protocol BaseCoordinator: AnyObject {
    associatedtype Route

    func start() -> Route
}


