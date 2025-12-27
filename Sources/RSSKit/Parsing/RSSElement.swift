/// XML element names used in RSS 2.0 feeds.
///
/// This enum provides type-safe access to RSS element names,
/// preventing typos and enabling centralized management.
enum RSSElement: String, Sendable {
    // MARK: - Root Elements

    case rss
    case channel

    // MARK: - Channel Elements

    case title
    case link
    case description
    case language
    case copyright
    case managingEditor
    case webMaster
    case pubDate
    case lastBuildDate
    case category
    case generator
    case docs
    case cloud
    case ttl
    case image
    case rating
    case textInput
    case skipHours
    case skipDays

    // MARK: - Item Elements

    case item
    case author
    case comments
    case enclosure
    case guid
    case source

    // MARK: - Image Elements

    case url
    case width
    case height

    // MARK: - Enclosure Attributes

    case length
    case type

    // MARK: - GUID Attributes

    case isPermaLink

    // MARK: - Cloud Attributes

    case domain
    case port
    case path
    case registerProcedure
    case `protocol`
}
