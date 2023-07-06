

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
        ///   - type: the type of object we expect to get back
        ///   - completion: call back with data or error
    public func execute<T: Codable>(
        _ request: RMRequest,
        expecting type: T.Type,
        completion: @escaping(Result<T, Error>
        ) -> Void
    ){
    }
}


