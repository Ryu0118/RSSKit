/// XML element names used in RSS feeds.
///
/// This enum provides type-safe access to RSS element names,
/// preventing typos and enabling centralized management.
package enum RSSElement: String, Sendable {
    case rss
    case channel

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

    case item
    case author
    case comments
    case enclosure
    case guid
    case source

    case url
    case width
    case height

    case length
    case type

    case isPermaLink

    case domain
    case port
    case path
    case registerProcedure
    case `protocol`
}
