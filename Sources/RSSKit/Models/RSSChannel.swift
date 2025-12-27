import Foundation

/// RSS channel metadata and items.
///
/// A channel contains required elements (title, link, description)
/// and optional elements like language, copyright, and items.
public struct RSSChannel: Sendable, Equatable {
    // MARK: - Required Elements

    /// The name of the channel.
    public let title: String

    /// The URL to the website corresponding to the channel.
    public let link: URL

    /// A description of the channel.
    public let description: String

    // MARK: - Optional Elements

    /// The language the channel is written in (e.g., "en-us").
    public let language: String?

    /// Copyright notice for the channel content.
    public let copyright: String?

    /// Email address of the managing editor.
    public let managingEditor: String?

    /// Email address of the webmaster.
    public let webMaster: String?

    /// The publication date of the channel content.
    public let pubDate: Date?

    /// The last time the channel content changed.
    public let lastBuildDate: Date?

    /// Categories the channel belongs to.
    public let categories: [RSSCategory]

    /// The program used to generate the channel.
    public let generator: String?

    /// URL pointing to the RSS specification documentation.
    public let docs: URL?

    /// Time to live in minutes - how long the channel can be cached.
    public let ttl: Int?

    /// The channel's image.
    public let image: RSSImage?

    /// The items in the channel.
    public let items: [RSSItem]

    public init(
        title: String,
        link: URL,
        description: String,
        language: String? = nil,
        copyright: String? = nil,
        managingEditor: String? = nil,
        webMaster: String? = nil,
        pubDate: Date? = nil,
        lastBuildDate: Date? = nil,
        categories: [RSSCategory] = [],
        generator: String? = nil,
        docs: URL? = nil,
        ttl: Int? = nil,
        image: RSSImage? = nil,
        items: [RSSItem] = []
    ) {
        self.title = title
        self.link = link
        self.description = description
        self.language = language
        self.copyright = copyright
        self.managingEditor = managingEditor
        self.webMaster = webMaster
        self.pubDate = pubDate
        self.lastBuildDate = lastBuildDate
        self.categories = categories
        self.generator = generator
        self.docs = docs
        self.ttl = ttl
        self.image = image
        self.items = items
    }
}
