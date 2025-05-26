import UIKit

extension UIFont {
    static var ysDisplayMedium: UIFont {
        UIFont(name: "YSDisplay-Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
    }

    static var ysDisplayBold: UIFont {
        UIFont(name: "YSDisplay-Bold", size: 20) ?? .boldSystemFont(ofSize: 20)
    }

    static func ysDisplayMedium(size: CGFloat) -> UIFont {
        UIFont(name: "YSDisplay-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
    }

    static func ysDisplayBold(size: CGFloat) -> UIFont {
        UIFont(name: "YSDisplay-Bold", size: size) ?? .boldSystemFont(ofSize: size)
    }
}
