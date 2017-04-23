// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIColor
  typealias Color = UIColor
#elseif os(OSX)
  import AppKit.NSColor
  typealias Color = NSColor
#endif

extension Color {
  convenience init(rgbaValue: UInt32) {
    let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
    let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
    let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
    let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}

// swiftlint:disable file_length
// swiftlint:disable line_length

// swiftlint:disable type_body_length
enum ColorName {
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#1e2029"></span>
  /// Alpha: 100% <br/> (0x1e2029ff)
  case Basement
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#1f6fbf"></span>
  /// Alpha: 100% <br/> (0x1f6fbfff)
  case Button
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#e6e6e6"></span>
  /// Alpha: 100% <br/> (0xe6e6e6ff)
  case LightGray
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#252733"></span>
  /// Alpha: 100% <br/> (0x252733ff)
  case NavigationBar
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#fefffe"></span>
  /// Alpha: 100% <br/> (0xfefffeff)
  case White

  var rgbaValue: UInt32 {
    switch self {
    case .Basement:
      return 0x1e2029ff
    case .Button:
      return 0x1f6fbfff
    case .LightGray:
      return 0xe6e6e6ff
    case .NavigationBar:
      return 0x252733ff
    case .White:
      return 0xfefffeff
    }
  }

  var color: Color {
    return Color(named: self)
  }
}
// swiftlint:enable type_body_length

extension Color {
  convenience init(named name: ColorName) {
    self.init(rgbaValue: name.rgbaValue)
  }
}

