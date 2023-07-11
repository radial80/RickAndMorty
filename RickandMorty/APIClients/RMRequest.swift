
import Foundation

/// Object that represents a single API
final class RMRequest {
        //Base URL
        //Endpoint
        //path Components
        //Query paramaters
        // https://rickandmortyapi.com/api/character
        /// API Constants
    private struct Constants {
        static let baseURL = "https://rickandmortyapi.com/api"
    }
        /// Desired Endpoint
    private let endPoint: RMEndPoint
        ///  Path Components for API, if any
    private let pathComponents: [String]

    private let querryParameters: [URLQueryItem]
        ///  Constructed URL for API request in string format
    private var urlString: String  {
        var string = Constants.baseURL
        string += "/"
        string += endPoint.rawValue

        if !pathComponents.isEmpty {
            pathComponents.forEach({
                string += "/\($0)"
            })
        }

        if !querryParameters.isEmpty {
        string += "?"
                let arguementString = querryParameters.compactMap({
                    guard let value = $0.value else { return nil }
                    return "\($0.name)=\(value)"
                        }).joined(separator: "&")

            string += arguementString

        }
        return string
    }
            /// constructed API URL
    public var url: URL? {
        return URL(string: urlString )
    }
    public let httpMethod = "GET"

    // MARK: - Public
    
    public init(
        endPoint: RMEndPoint,
        pathComponents: [String] = [],
        querryParameters: [URLQueryItem] = []

    ) {
        self.endPoint = endPoint
        self.pathComponents = pathComponents
        self.querryParameters = querryParameters
    }
}

extension RMRequest {
    static let listCharactersRequest = RMRequest(endPoint: .character)
}
