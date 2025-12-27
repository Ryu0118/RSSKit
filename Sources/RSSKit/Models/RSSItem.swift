import Foundation

/// An individual item in an RSS feed.
///
/// All elements are optional, but at least one of `title` or `description`
/// should be present for a valid item.
public struct RSSItem: Sendable, Equatable {
    /// The title of the item.
    public let title: String?

    /// The URL of the item.
    public let link: URL?

    /// The item synopsis.
    public let description: String?

    /// Email address of the author.
    public let author: String?

    /// Categories the item belongs to.
    public let categories: [RSSCategory]

    /// URL of a page for comments relating to the item.
    public let comments: URL?

    /// Media object attached to the item.
    public let enclosure: RSSEnclosure?

    /// A unique identifier for the item.
    public let guid: RSSGUID?

    /// When the item was published.
    public let pubDate: Date?

    /// The RSS channel the item came from.
    public let source: RSSSource?

    public init(
        title: String? = nil,
        link: URL? = nil,
        description: String? = nil,
        author: String? = nil,
        categories: [RSSCategory] = [],
        comments: URL? = nil,
        enclosure: RSSEnclosure? = nil,
        guid: RSSGUID? = nil,
        pubDate: Date? = nil,
        source: RSSSource? = nil
    ) {
        self.title = title
        self.link = link
        self.description = description
        self.author = author
        self.categories = categories
        self.comments = comments
        self.enclosure = enclosure
        self.guid = guid
        self.pubDate = pubDate
        self.source = source
    }
}
