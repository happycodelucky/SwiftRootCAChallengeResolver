//
//  URLSession+RootCAChallengeResolver.swift
//  RootCAChallengeResolver
//
//  Created by Paul Bates on 1/14/20.
//  Copyright © 2020 Paul Bates. All rights reserved.
//

import Foundation

extension URLSession {
    /// Initialize a URL session with `RootCAChallengeResolver` for a host
    ///
    /// - Parameters:
    ///     - configuration: A configuration object that specifies certain behaviors, such as caching policies, timeouts, proxies,
    ///                      pipelining, TLS versions to support, cookie policies, credential storage, and so on.
    ///     - resolve: Resolver created prior to use to resolve trusted self-signed endpoints
    public convenience init(configuration: URLSessionConfiguration, resolver: RootCAChallengeResolver) {
        self.init(configuration: configuration, delegate: resolver, delegateQueue: .current)
    }

    /// Initialize a URL session with `RootCAChallengeResolver` for a host, and optional trust certificate
    ///
    /// - Parameters:
    ///     - configuration: A configuration object that specifies certain behaviors, such as caching policies, timeouts, proxies,
    ///                      pipelining, TLS versions to support, cookie policies, credential storage, and so on.
    ///     - host: Host to trust
    public convenience init(configuration: URLSessionConfiguration, host: String) {
        self.init(configuration: configuration, resolver: RootCAChallengeResolver(host: host)!)
    }

    /// Initialize a URL session with `RootCAChallengeResolver` for a host, and optional trust certificate
    /// Can return `nil` is the cert data provided is not a valid certificate
    ///
    /// - Parameters:
    ///     - configuration: A configuration object that specifies certain behaviors, such as caching policies, timeouts, proxies,
    ///                      pipelining, TLS versions to support, cookie policies, credential storage, and so on.
    ///     - host: Host to trust
    ///     - cert: Limit to certificate to trust
    public convenience init?(configuration: URLSessionConfiguration, host: String, cert: Data?) {
        guard let resolver = RootCAChallengeResolver(host: host, cert: cert) else {
            return nil
        }

        self.init(configuration: configuration, resolver: resolver)
    }
}
