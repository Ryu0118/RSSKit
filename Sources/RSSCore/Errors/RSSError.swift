import Foundation

/// Errors that can occur during RSS feed parsing.
public enum RSSError: Error, Sendable, Equatable {
    /// The provided data is not valid XML.
    case invalidXML(underlying: String)

    /// The XML does not contain a valid RSS structure.
    case invalidRSSStructure

    /// A required element is missing from the feed.
    case missingRequiredElement(String)

    /// The RSS version is not supported.
    case unsupportedVersion(String)

    /// A date string could not be parsed.
    case invalidDateFormat(String)

    /// A URL string is malformed.
    case invalidURL(String)

    /// A numeric value could not be parsed.
    case invalidNumber(element: String, value: String)
}

extension RSSError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidXML(underlying):
            return "Invalid XML: \(underlying)"
        case .invalidRSSStructure:
            return "Invalid RSS structure: missing <rss> or <channel> element"
        case let .missingRequiredElement(element):
            return "Missing required element: <\(element)>"
        case let .unsupportedVersion(version):
            return "Unsupported RSS version: \(version)"
        case let .invalidDateFormat(dateString):
            return "Invalid date format: \(dateString)"
        case let .invalidURL(urlString):
            return "Invalid URL: \(urlString)"
        case let .invalidNumber(element, value):
            return "Invalid number in <\(element)>: \(value)"
        }
    }
}
