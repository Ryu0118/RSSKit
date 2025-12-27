import Foundation

/// A media object attached to an RSS item.
///
/// Enclosures are commonly used for podcasts and other media content.
public struct RSSEnclosure: Sendable, Equatable {
    /// The URL where the enclosure is located.
    public let url: URL

    /// The size of the enclosure in bytes.
    public let length: Int

    /// The MIME type of the enclosure (e.g., "audio/mpeg").
    public let type: String

    public init(url: URL, length: Int, type: String) {
        self.url = url
        self.length = length
        self.type = type
    }
}
