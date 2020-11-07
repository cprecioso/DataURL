import Foundation

extension NSTextCheckingResult {
  var ranges: [NSRange] { (0..<self.numberOfRanges).map { self.range(at: $0) } }
}

extension String {
  var fullIndexRange: NSRange {
    NSRange(self.startIndex..<self.endIndex, in: self)
  }

  func firstMatch(with regularExpression: NSRegularExpression) -> [Substring?]? {
    guard
      let match = regularExpression.firstMatch(in: self, options: [], range: self.fullIndexRange)
    else { return nil }
    return match.ranges.map { nsRange -> Substring? in
      if nsRange.location == NSNotFound { return nil }
      guard let range = Range(nsRange, in: self) else { return nil }
      return self[range]
    }
  }
}
