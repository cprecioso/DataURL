import UniformTypeIdentifiers

public struct DataURL: Codable {
  public var data: Data
  public var type: UTType?
  public var base64: Bool

  static let dataUrlRegex = try! NSRegularExpression(
    pattern: #"^data:(.+?)?(;base64)?,(.+)$"#, options: [])

  var contentPart: String? {
    if base64 {
      return data.base64EncodedString()
    } else {
      return String(data: data, encoding: .utf8)?.addingPercentEncoding(
        withAllowedCharacters: .urlPasswordAllowed)
    }
  }

  public var urlString: String? {
    guard let content = contentPart else { return nil }
    let mimeType = type?.preferredMIMEType ?? ""
    let base64Tag = base64 ? ";base64" : ""

    let str = "data:\(mimeType)\(base64Tag),\(content)"
    return str
  }

  public var url: URL? {
    guard let urlString = urlString else { return nil }
    return URL(string: urlString)
  }

  public init(_ data: Data, type: UTType? = nil, base64: Bool = true) {
    self.data = data
    self.type = type
    self.base64 = base64
  }

  public init?(_ string: String, type: UTType? = nil, base64: Bool = true) {
    guard let data = string.data(using: .utf8) else { return nil }
    self.init(data, type: type, base64: base64)
  }

  public init?(string: String) {
    guard let matches = string.firstMatch(with: Self.dataUrlRegex) else { return nil }

    let mimeType = Self.parse(mimeType: matches[1])
    let isBase64 = !(matches[2]?.isEmpty ?? true)
    let content = matches[3]
    guard let data = Self.parse(content: content, base64: isBase64) else { return nil }

    self.init(data, type: mimeType, base64: isBase64)
  }

  public init?(url: URL) {
    self.init(string: url.absoluteString)
  }

  static func parse<T: StringProtocol>(mimeType: T?) -> UTType? {
    guard let mimeType = mimeType else { return nil }
    return UTType(mimeType: String(mimeType))
  }

  static func parse<T: StringProtocol>(content: T?, base64: Bool) -> Data? {
    guard let content = content else { return nil }
    if base64 {
      return Data(base64Encoded: String(content))
    } else {
      return content.removingPercentEncoding?.data(using: .utf8)
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let str = try container.decode(String.self)
    self.init(str)!
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.urlString!)
  }
}
