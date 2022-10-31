//
//  URLSessionInstagramAPIProvider.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 27.10.2022.
//

import Foundation

class URLSessionInstagramAPIProvider: InstagramAPIServiceProviding {
    
    //MARK: - IVars
    
    var accessToken: String
    
    private var userId: String?
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    private var requestCount = 0
    
    //MARK: - Lifecycle
    
    init(
        accessToken: String
    ) {
        self.accessToken = accessToken
        decoder.dateDecodingStrategy = .iso8601
    }
    
    //MARK: - InstagramAPIServiceProviding
    
    func fetchInstagramUser() async throws -> InstagramUser {
        var urlComponents = urlComponents(path: "/v15.0/me")
        urlComponents.queryItems = [
            URLQueryItem(
                name: "fields",
                value: "id,username,media_count,account_type,media"
            )
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        let request = URLRequest(url: url)
        
        let data = try await makeRequest(request, session: urlSession)
        return try decoder.decode(InstagramUser.self, from: data)
    }
    
    func fetchInstagramUserMedia(userId: String) async throws -> InstagramMediaResponse {
        var urlComponents = urlComponents(path: "/v15.0/\(userId)/media")
        urlComponents.queryItems = [
            URLQueryItem(
                name: "fields",
                value: "id,caption,media_type,media_url,thumbnail_url,timestamp,children"
            ),
            URLQueryItem(
                name: "limit",
                value: "4"
            )
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        let request = URLRequest(url: url)
        
        let data = try await makeRequest(request, session: urlSession)
        var response = try decoder.decode(InstagramMediaResponse.self, from: data)
        
        for (index, item) in response.mediaItems.enumerated() {
            if let children = item.children?.mediaItems, children.count > 0 {
                let childResponses = try await fetchMediaItemsWith(ids: children.map({$0.id}), child: true)
                response.mediaItems[index].children?.mediaItems = childResponses
            }
        }
        
        return response
    }
    
    func fetchMediaItem(id: String, child: Bool = false) async throws -> InstagramMediaItem {
        var urlComponents = urlComponents(path: "/\(id)")
        urlComponents.queryItems = [
            URLQueryItem(
                name: "fields",
                value: child ? "id,media_url,thumbnail_url,timestamp" : "id,caption,media_type,media_url,thumbnail_url,timestamp,children"
            )
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        let request = URLRequest(url: url)
        
        let data = try await makeRequest(request, session: urlSession)
        return try decoder.decode(InstagramMediaItem.self, from: data)
    }
    
    func fetchMediaItemsWith(ids: [String], child: Bool = false) async throws -> [InstagramMediaItem] {
        
        let apiProvider = self
        
        var loadedMediaResponses = [String: Any?]()
        
        //Load in parallel
        await withTaskGroup(of: (id: String, responseOrError: Any).self, body: { group in
            for id in ids {
                group.addTask {
                    do {
                        var item = try await apiProvider.fetchMediaItem(id: id, child: child)
                        
                        if let childrenIds = item.children?.mediaItems.map({$0.id}) {
                            let childItems = try await apiProvider.fetchMediaItemsWith(ids: childrenIds, child: true)
                            
                            item.children?.mediaItems = childItems
                        }
                        
                        return (id, item)
                    } catch {
                        return (id, error)
                    }
                }
                
                for await responseOrErrorForId in group {
                    loadedMediaResponses[responseOrErrorForId.id] = responseOrErrorForId.responseOrError
                }
            }
        })
        
        var returnValues = [InstagramMediaItem]()
        
        for id in ids {
            if let item = loadedMediaResponses[id] as? InstagramMediaItem {
                returnValues.append(item)
            } else if let error = loadedMediaResponses as? Error {
                var item = InstagramMediaItem(id: id)
                item.loadErrorMessage = error.localizedDescription
                returnValues.append(item)
            } else {
                let item = InstagramMediaItem(id: id)
                returnValues.append(item)
            }
        }
        
        return returnValues
    }
    
    func fetchNextPageFor(paging: InstagramMediaResponsePaging) async throws -> InstagramMediaResponse? {
        guard let next = paging.next, let url = URL(string: next) else {
            return nil
        }
        
        let request = URLRequest(url: url)
        
        let data = try await makeRequest(request, session: urlSession, authenticated: false)
        
        var response = try decoder.decode(InstagramMediaResponse.self, from: data)
        
        for (index, item) in response.mediaItems.enumerated() {
            if let children = item.children?.mediaItems, children.count > 0 {
                let childResponses = try await fetchMediaItemsWith(ids: children.map({$0.id}), child: true)
                response.mediaItems[index].children?.mediaItems = childResponses
            }
        }
        
        return response
    }
    
    //MARK: - Private
    
    private func makeRequest(_ request: URLRequest, session: URLSession, authenticated: Bool = true) async throws -> Data {
        
        guard let url = request.url else {
            throw URLError(.badURL)
        }
        
        var authenticatedRequest = request
        
        if authenticated {
            let authenticationQueryItem = URLQueryItem(name: "access_token", value: accessToken)
            
            var newComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
            if newComponents?.queryItems != nil {
                newComponents?.queryItems?.append(authenticationQueryItem)
            } else {
                newComponents?.queryItems = [authenticationQueryItem]
            }
            
            guard let authenticatedUrl = newComponents?.url else {
                throw URLError(.badURL)
            }
        
            authenticatedRequest.url = authenticatedUrl
        }
        
        requestCount += 1
        let currentCount = requestCount
        
        print("\nREQUEST (\(currentCount))\n\(request.url?.absoluteString ?? "")")
        
        let dataTaskOutput = try await session.data(for: authenticatedRequest)
        
        print("\nRESPONSE (\(currentCount))\nCode \((dataTaskOutput.1 as? HTTPURLResponse)?.statusCode ?? 0)\n\(String(data: dataTaskOutput.0, encoding: .utf8) ?? "")")
        
        if let httpStatusCode = (dataTaskOutput.1 as? HTTPURLResponse)?.statusCode, httpStatusCode != 200 {
            throw URLError(.badServerResponse)
        }
        return dataTaskOutput.0
    }
    
    private func urlComponents(path: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "graph.instagram.com"
        components.path = path
        return components
    }
}
