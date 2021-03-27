//
//  curl2swift boilerplate code
//

import Foundation
import RxSwift

class RequestSpecBuilder {

    // MARK: - Enums
    enum Property {
        case baseURL(String)
        case path(String)
        case queryParams([String: String])
        case method(HTTPMethod)
        case header(key: String, value: String)
        case parameter(key: String, value: Any)
    }

    enum Header: String {
        case xTenantContext = "x-tenant-context"
        case acceptLanguage = "Accept-Language"
        case xClientApplication = "X-Client-Application"
        case contentType = "Content-Type"
        case authorization = "Authorization"
    }

    // MARK: - Properties
    var baseURL: String = ""
    var path: String = ""
    var queryParams: [String: String] = [:]
    var method: HTTPMethod = .get
    var headers: [String: String] = [:]
    var params: [String: Any] = [:]

    // MARK: - Init
    required init(
        baseURL: String = "",
        path: String = "",
        queryParams: [String: String] = [:],
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        params: [String: Any] = [:]
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.params = params
    }
}

// MARK: - Builder functions
extension RequestSpecBuilder {

    @discardableResult
    func set(_ property: Property) -> Self {
        switch property {
        case .baseURL(let baseURL):
            self.baseURL = baseURL
        case .path(let path):
            self.path = path
        case .queryParams(let params):
            self.queryParams = params
        case .method(let method):
            self.method = method
        case .header(let key, let value):
            self.headers[key] = value
        case .parameter(let key, let value):
            self.params[key] = value
        }
        return self
    }

    @discardableResult
    func setCommonHeader(_ header: Header, value: String) -> Self {
        headers[header.rawValue] = value
        return self
    }

    func build() -> RequestSpecification {
        return RequestSpecification(
            baseURL: baseURL,
            path: path,
            queryParams: queryParams,
            method: method,
            headers: headers,
            params: params
        )
    }

    func to<T: RequestSpecBuilder>(_ other: T.Type) -> T {
        return other.init(
            baseURL: baseURL,
            path: path,
            method: method,
            headers: headers,
            params: params
        )
    }
}

extension RequestSpecBuilder {

    func authorizeWithBearerToken(_ token: String) -> Self {
        setCommonHeader(.authorization, value: "Bearer \(token)")
        return self
    }

    func makeRxRequest() -> Single<Data> { rx.makeRequest() }

    // swiftlint:disable identifier_name
    var rx: Single<RequestSpecBuilder> { .just(self) }
}
