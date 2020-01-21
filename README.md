# RootCAChallengeResolver

A package to support use of [URLSession](https://developer.apple.com/documentation/foundation/urlsession) to make SSL request where the service utilizes a self-signed certificate. Using RootCAChallengeResolver encourages not pervasive disabling [ATS](https://developer.apple.com/documentation/security/preventing_insecure_network_connections).

As always, be careful of the endpoints you trust. They should ideally be endpoints your organization hosts.

For more information see Apple's documentation on [Preventing Insecure Network Connections](https://developer.apple.com/documentation/security/preventing_insecure_network_connections).

![Swift Version](https://img.shields.io/badge/swift-5.1-blue.svg?style=for-the-badge)
![iOS Version](https://img.shields.io/badge/iOS-12-green.svg?style=for-the-badge)
![macOS Version](https://img.shields.io/badge/macOS-10.14-green.svg?style=for-the-badge)
![tvOS Version](https://img.shields.io/badge/tvOS-12-green.svg?style=for-the-badge)
![watchOS Version](https://img.shields.io/badge/watchOS-5-green.svg?style=for-the-badge)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)](.//LICENSE)
[![Maintained](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=for-the-badge)](https://github.com/pryomoax/RootCAChallengeResolver/graphs/commit-activity)
![Release](https://img.shields.io/github/release-pre/pryomoax/RootCAChallengeResolver.svg?style=for-the-badge)

# Release Notes

This is not yet a production-ready release. 

| Version | Description    |
| :-----: | -------------- |
|  0.4.0  | Initial commit |

# Installation

To use RootCAChallengeResolver within your project see how to reference package using the [Swift Package Manager](https://swift.org/package-manager/) or in [Xcode](https://developer.apple.com/videos/play/wwdc2019/408/). Once installed you can import **RootCAChallengeResolver** as appropriate.

# Usage

The intent is for [`RootCAChallengeResolver`](./Sources/RootCAChallengeResolver/RootCAChallengeResolver.swift) to be used as a [URLSession](https://developer.apple.com/documentation/foundation/urlsession)'s delegate for the specific host your application has implicit trust in. 

First create a new requests (details here are for show only)

```swift
let host = "cdn.example.com"
let endpoint = URL("https://\(host)/conf/2020-01-01.json")!
let request = URLRequest(url: endpoint)
```

Create a `RootCAChallengeResolver` and use as the delegate to a new [URLSession](https://developer.apple.com/documentation/foundation/urlsession/1411597-init)

```swift
// (Optional) load an embedded cert to use for trust
let certUrl = Bundle.main.url(forResource: host, withExtension: "pem")
let certData = Data(contentsOf: certUrl)

// Use a `RootCAChallengeResolver` as the delegate for a `URLSession`
//
// `cert` is optional, and only need to be provided if you want to ensure more 
// stringent trust validation
let challengeDelegate = RootCAChallengeResolver(host: host, cert: certData)

// Use the `challengeDelegate` as the session delegate
let session = URLSession(configuration: .default, 
                         delegate: challengeDelegate, 
                         delegateQueue: .current ?? .main)
```

Perform a task, like a download

```swift
// Download the data
let task = session.downloadTask(with: request) { localUrl, response, error in
    ///...
}

task.resume()
```

## URLSession Conveniences

`URLSession` has been extended with some convenience initializers

``` swift
let host = "cdn.example.com"
let certUrl = Bundle.main.url(forResource: host, withExtension: "pem")
let certData = Data(contentsOf: certUrl)

// Create a session for a host and trust cert
let session = URLSession(configuration: .default, host: host, cert: certData)

..OR..

// Create a session for just a host
let session = URLSession(configuration: .default, host: host)
```

# Unit Testing

Testing has not yet been implemented.

This package was extracted from another project and is yet to be fully self-serving.
