import Foundation

/// Sends logs to server.
final class LogsUploader {
    
    private let httpClient: HTTPClient
    private let requestBuilder: LogsUploadRequestEncoder
    
    init(configuration: Datadog, httpClient: HTTPClient) {
        self.httpClient = httpClient
        self.requestBuilder = LogsUploadRequestEncoder(uploadURL: configuration.logsUploadURL)
    }
    
    func upload(logs: [Log], completion: @escaping (LogsDeliveryStatus) -> Void) throws {
        let request = try requestBuilder.encodeRequest(with: logs)
        httpClient.send(request: request) { (result) in
            switch result {
            case .success(let httpResponse):
                completion(LogsDeliveryStatus(from: httpResponse, logs: logs))
            case .failure(let httpRequestDeliveryError):
                completion(LogsDeliveryStatus(from: httpRequestDeliveryError, logs: logs))
            }
        }
    }
}
