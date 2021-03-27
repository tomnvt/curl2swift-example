//
//  curl2swift boilerplate code
//

import Foundation

extension URL {

    func setPathComponent(_ component: String) -> Self {
        self.appendingPathComponent(component)
    }

    func setUrlParams(_ params: [String: String]) -> Self {
        guard !params.isEmpty,
              var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        urlComponents.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        return urlComponents.url ?? self
    }
}
