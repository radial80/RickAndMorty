

import Foundation

/// First API service to get RM data
final class RMService {

    /// sahared singleton instance
    static let shared = RMService()

    /// Private Construct
    private init() {}
        /// Send RM API Call
        /// - Parameters:
        ///   - request: Request
        ///   - completion: call back with data or error
    public func execute(_ request: RMRequest, completion: @escaping() -> Void ){

    }
}

