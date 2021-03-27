//
//  curl2swift boilerplate code
//

import Foundation
import RxCocoa
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait {

    @discardableResult
    func discardableSubscribe() -> Disposable {
        subscribe()
    }

    @discardableResult
    func discardableSubscribe(onSuccess: ((Element) -> Void)?,
                              onError: @escaping ((Error) -> Void) = { _ in }) -> Disposable {
        subscribe(onSuccess: onSuccess, onFailure: onError)
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Data {

    func mapTo<T: Codable>(_ type: T.Type) -> Single<T> {
        map { data in
            try JSONDecoder().decode(T.self, from: data)
        }
        .catch {
            #if DEBUG
            print($0)
            #endif
            return .error($0)
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == RequestSpecBuilder {

    func castTo<T: RequestSpecBuilder>(_ type: T.Type) -> Single<T> {
        self.map { $0.to(type) }
    }

    func makeRequest() -> Single<Data> {
        self.flatMap { builder in
            let spec = builder.build()
            let session = URLSession(configuration: .default)

            #if DEBUG
            print("[REQUEST DEBUG] - request cURL: \n\(spec.urlRequest.curlString)")
            #endif

            return session.rx.data(request: spec.urlRequest)
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
                .asSingle()
                .do(onSuccess: { data in
                    #if DEBUG
                    if let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Response from \(spec.urlRequest.url?.absoluteString ?? ""): \(response)")
                    } else if let response = String(data: data, encoding: .utf8) {
                        print("Response from \(spec.urlRequest.url?.absoluteString ?? ""): \(response)")
                    } else {
                        print("Response mapping to dictionary or string failed !!!")
                    }
                    #endif
                })
        }
    }
}
