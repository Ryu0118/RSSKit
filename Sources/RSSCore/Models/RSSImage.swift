import Foundation

/// An image associated with an RSS channel.
public struct RSSImage: Sendable, Equatable {
    /// The URL of the image.
    public let url: URL

    /// The title of the image (used as alt text).
    public let title: String

    /// The URL of the site the image links to.
    public let link: URL

    /// The width of the image in pixels (max 144, default 88).
    public let width: Int?

    /// The height of the image in pixels (max 400, default 31).
    public let height: Int?

    /// A text description of the image.
    public let description: String?

    public init(
        url: URL,
        title: String,
        link: URL,
        width: Int? = nil,
        height: Int? = nil,
        description: String? = nil
    ) {
        self.url = url
        self.title = title
        self.link = link
        self.width = width
        self.height = height
        self.description = description
    }
}
