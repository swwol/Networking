import Foundation

public protocol RequestBehavior {
    func modify(urlComponents: URLComponents) -> URLComponents
    func modify(planned request: URLRequest) -> URLRequest
    func before(sending request: URLRequest)

    func modifyResponse(data: Data?, response: URLResponse?, error: Error?) -> (Data?, URLResponse?, Error?)
    func after(completion response: URLResponse?)
    func after(failure: Error?)
    func and(_ behavior: RequestBehavior) -> RequestBehavior
}

public extension RequestBehavior {
    func modify(urlComponents: URLComponents) -> URLComponents { return urlComponents }
    func modify(planned request: URLRequest) -> URLRequest { return request }
    func before(sending: URLRequest) { }

    func modifyResponse(data: Data?, response: URLResponse?, error: Error?)
        -> (Data?, URLResponse?, Error?) { return (data, response, error) }
    func after(completion: URLResponse?) { }
    func after(failure: Error?) { }

    func and(_ behavior: RequestBehavior) -> RequestBehavior {
        return CompoundRequestBehavior(behaviors: [self, behavior])
    }
}

struct EmptyRequestBehavior: RequestBehavior {}

private struct CompoundRequestBehavior: RequestBehavior {
    private let behaviors: [RequestBehavior]

    init(behaviors: [RequestBehavior]) {
        self.behaviors = behaviors
    }

    func modify(urlComponents: URLComponents) -> URLComponents {
        var urlComponents = urlComponents

        behaviors.forEach {
            urlComponents = $0.modify(urlComponents: urlComponents)
        }

        return urlComponents
    }

    func modify(planned request: URLRequest) -> URLRequest {
        var request = request

        behaviors.forEach {
            request = $0.modify(planned: request)
        }

        return request
    }

    func before(sending request: URLRequest) {
        behaviors.forEach {
            $0.before(sending: request)
        }
    }

    func modifyResponse(data: Data?, response: URLResponse?, error: Error?) -> (Data?, URLResponse?, Error?) {
        var data = data
        var response = response
        var error = error

        behaviors.forEach {
            (data, response, error) = $0.modifyResponse(data: data, response: response, error: error)
        }

        return (data, response, error)
    }

    func after(completion response: URLResponse?) {
        behaviors.forEach {
            $0.after(completion: response)
        }
    }

    func after(failure: Error?) {
        behaviors.forEach {
            $0.after(failure: failure)
        }
    }
}
