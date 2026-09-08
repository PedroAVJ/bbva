import CoreText
import Foundation

enum FontRegistrar {
    private static let fontFiles = [
        "LibreFranklin-Variable",
        "SourceSerif4-Variable",
    ]

    static func registerBundledFonts() {
        for name in fontFiles {
            let url = Bundle.main.url(forResource: name, withExtension: "ttf")
                ?? Bundle.module.url(forResource: name, withExtension: "ttf")
            guard let url else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
