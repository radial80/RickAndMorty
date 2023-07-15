import Foundation
    // This loader created to keep photos in cache. If user scroll up the application will not download downloaded photos again.
final class RMImageLoader {
    static let shared = RMImageLoader()

    private var imageDataCache = NSCache<NSString, NSData> ()

    private init() {}


    /// Get image content with URL
    /// - Parameters:
    ///   - url: source url
    ///   - completion: call back
    public func downloadImage(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let key = url.absoluteString as NSString
        if let data = imageDataCache.object(forKey: key) {
            completion(.success(data as Data))
            return
        }

        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            let key = url.absoluteString as NSString
            let value = data as NSData
            self.imageDataCache.setObject(value, forKey: key)
            completion(.success(data))
        }
        task.resume()
    }
}
