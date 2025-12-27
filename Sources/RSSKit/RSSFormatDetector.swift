import Foundation
import RSSCore

/// Detected RSS feed format.
public enum RSSFormat: Sendable {
    /// RSS 1.0 (RDF-based)
    case rss1
    /// RSS 2.0
    case rss2
}

/// Detects the format of an RSS feed.
struct RSSFormatDetector: Sendable {
    private let xmlParser: XMLDocumentParser

    init() {
        xmlParser = XMLDocumentParser()
    }

    /// Detects the RSS format from XML data.
    ///
    /// - Parameter data: The RSS XML data.
    /// - Returns: The detected RSS format.
    /// - Throws: ``RSSError`` if the format cannot be detected or is unsupported.
    func detect(_ data: Data) throws -> RSSFormat {
        let root = try xmlParser.parse(data)

        // RSS 1.0 uses rdf:RDF as root element
        if root.name == "rdf:RDF" || root.name == "RDF" {
            return .rss1
        }

        // RSS 2.0 uses rss as root element
        if root.name == "rss" {
            return .rss2
        }

        throw RSSError.invalidRSSStructure
    }
}
