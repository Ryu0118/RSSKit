/// XML element names used in RSS 1.0 (RDF) feeds.
///
/// This enum provides type-safe access to RSS 1.0 element names,
/// including Dublin Core namespace elements.
package enum RSS1Element: String, Sendable {
    // RDF root element
    case rdf = "rdf:RDF"

    // Channel elements
    case channel
    case title
    case link
    case description
    case image
    case items
    case textinput

    // Item elements
    case item

    // Dublin Core elements
    case dcTitle = "dc:title"
    case dcCreator = "dc:creator"
    case dcSubject = "dc:subject"
    case dcDescription = "dc:description"
    case dcPublisher = "dc:publisher"
    case dcContributor = "dc:contributor"
    case dcDate = "dc:date"
    case dcType = "dc:type"
    case dcFormat = "dc:format"
    case dcIdentifier = "dc:identifier"
    case dcSource = "dc:source"
    case dcLanguage = "dc:language"
    case dcRelation = "dc:relation"
    case dcCoverage = "dc:coverage"
    case dcRights = "dc:rights"

    // RDF attributes
    case rdfAbout = "rdf:about"
    case rdfResource = "rdf:resource"
}
