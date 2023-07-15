
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
        // parsing the url for fetching more data
    convenience init?(url: URL) {
        let string = url.absoluteString
        if !string.contains(Constants.baseURL) {
            return nil
        }
        let trimmed = string.replacingOccurrences(of: Constants.baseURL+"/"  , with: "")
        if trimmed.contains("/") {
            let components = trimmed.components(separatedBy: "/")
            if !components.isEmpty {
                let endPointString = components[0]
                if let rmEndpoint = RMEndPoint(rawValue: endPointString){
                    self.init(endPoint: rmEndpoint)
                    return
                }
            }

        } else if trimmed.contains("?") {
            let components = trimmed.components(separatedBy: "?")
            if !components.isEmpty, components.count >= 2 {
                let endPointString = components[0]
                let queryItemsString = components[1]
                let queryItems: [URLQueryItem] = queryItemsString.components(separatedBy: "&").compactMap({
                    guard $0.contains("=") else {
                        return nil
                    }
                    let parts = $0.components(separatedBy: "=")
                    return URLQueryItem(name: parts[0],
                                        value: parts[1])
                })
                if let rmEndpoint = RMEndPoint(rawValue: endPointString){
                    self.init(endPoint: rmEndpoint, querryParameters: queryItems)
                    return
                }
            }

        }

        return nil

    }
}

extension RMRequest {
    static let listCharactersRequest = RMRequest(endPoint: .character)
}
