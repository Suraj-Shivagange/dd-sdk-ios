import Foundation

/// An implementation of `HTTPTransport` which uses `URLSession` for requests delivery.
final class URLSessionTransport: HTTPTransport {
    private let session: URLSession
    
    convenience init() {
        let configuration: URLSessionConfiguration = .ephemeral
        // TODO: RUMM-123 Optimize `URLSessionConfiguration` for good traffic performance
        self.init(session: URLSession(configuration: configuration))
    }
    
    init(session: URLSession) {
        self.session = session
    }
    
    func send(request: URLRequest, callback: @escaping (HTTPTransportResult) -> Void) {
        let task = session.dataTask(with: request) { (data, response, error) in
            callback(transportResult(for: (data, response, error)))
        }
        task.resume()
    }
}

/// An error returned if given `URLSession` response state is inconsistent (like no data, no response and no error).
/// The code execution in `URLSessionTransport` should never reach its initialization.
struct URLSessionTransportInconsistencyException: Error {}

/// As `URLSession` returns 3-values-touple for request execution, this function applies consistency constraints and turns
/// it into only two possible states of `HTTPTransportResult`.
private func transportResult(for urlSessionTaskCompletion: (Data?, URLResponse?, Error?)) -> HTTPTransportResult {
    let (data, response, error) = urlSessionTaskCompletion
    
    if let error = error {
        return .error(error, data)
    }
    
    if let httpResponse = response as? HTTPURLResponse, let data = data {
        return .response(httpResponse, data)
    }
    
    return .error(URLSessionTransportInconsistencyException(), data)
}
