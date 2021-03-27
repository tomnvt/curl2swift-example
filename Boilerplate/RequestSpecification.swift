//
//  curl2swift boilerplate code
//

import Foundation

struct RequestSpecification {

    var baseURL: String
    var path: String
    var queryParams: [String: String]
    var method: HTTPMethod
    var headers: [String: String]
    var params: [String: Any]
}

extension RequestSpecification {

    var urlRequest: URLRequest {
        var request = getURLRequest()
        if method == .post { request.httpBody = getHttpBody() }
        return request
    }
    
    private func getURLRequest() -> URLRequest {
        // swiftlint:disable force_unwrapping
        let url = URL(string: baseURL)!
            .setPathComponent(path)
            .setUrlParams(queryParams)

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        return request
    }

    private func getHttpBody() -> Data? {
        if let contentType = headers["Content-Type"] {
            if contentType.contains("application/x-www-form-urlencoded") {
                let rawBody = params.reduce(into: "") { (result, keyValuePair) in
                    // NOTE: All ampersands need to be encoded,
                    // otherwise it would be handled as a parameter delimiter
                    let key = replaceAmpersands(keyValuePair.key)
                    let value = replaceAmpersands(keyValuePair.value)
                    result += "\(key)=\(value)&"
                }
                return rawBody.data(using: .utf8)
            } else if contentType.contains("text/plain") || contentType.contains("application/json") {
                return try? JSONSerialization.data(withJSONObject: params)
            }
        }
        return nil
    }

    private func replaceAmpersands(_ value: Any) -> String {
        if let string = value as? String {
            return string.replacingOccurrences(of: "&", with: "%26")
        } else {
            return "\(value)"
        }
        
    }
}
