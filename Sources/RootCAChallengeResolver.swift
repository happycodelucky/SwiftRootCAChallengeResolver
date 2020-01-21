//
//  RootCAChallengeResolver.swift
//  RootCAChallengeResolver
//
//  Created by Paul Bates on 1/14/20.
//  Copyright © 2020 Paul Bates. All rights reserved.
//

import Foundation

/// Supports use of self-signed root certificates for TLS, where it may be required to resolve the cert challenge dynamically (i.e.
/// an application does not want to support insecure communcation for anything)
public class RootCAChallengeResolver: NSObject, URLSessionDelegate {
    /// Host address for secured endpoint
    private let host: String

    /// Certifcate to ensure trust with
    private let cert: SecCertificate?

    // MARK: Init

    /// Initializes the resolver for a given host and (optional) cert
    /// Can return `nil` is the cert data provided is not a valid certificate
    ///
    /// - Parameters:
    ///     - host: The host to initialize for
    ///     - cert: Optional certificate data the trust challenge will be verified against
    public init?(host: String, cert: Data? = nil) {
        precondition(!host.isEmpty, "A valid host is required")
        precondition(!(cert?.isEmpty ?? false), "Trust cert must contain data")

        self.host = host
        if let certData = cert, certData.count > 0 {
            guard let certificate = SecCertificateCreateWithData(nil, certData as CFData) else {
                return nil
            }

            self.cert = certificate
        } else {
            self.cert = nil
        }
    }

    // MARK: URLSessionDelegate

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let protectionSpace = challenge.protectionSpace
        if // Only support trust challenges
            protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            // Ensure there is something to trust
            let trust = protectionSpace.serverTrust,
            // Ensure hosts are equivalent
            protectionSpace.host == host
        {
            // If there is no cert to verify, we can trust the connection
            guard let cert = cert else {
                completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
                return
            }

            // Verify the trust against the cert
            SecTrustSetAnchorCertificates(trust, [cert] as CFArray)
            SecTrustSetAnchorCertificatesOnly(trust, false)
            if SecTrustEvaluateWithError(trust, nil) {
                completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
            }
        }

        // Default handling
        completionHandler(.performDefaultHandling, nil)
    }
}
