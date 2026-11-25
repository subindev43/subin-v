import UIKit

/// Cyberpunk Neon design system for SUBIN-IOS: deep night glass, cyan/purple neon accents,
/// and real backdrop artwork rendering with balanced edge scrims.
enum Theme {
    /// The app's version as players should quote it in reports, e.g. "v2.0 (20)".
    static let appVersion: String = {
        let info = Bundle.main.infoDictionary
        return "v\(info?["CFBundleShortVersionString"] as? String ?? "?") (\(info?["CFBundleVersion"] as? String ?? "?"))"
    }()

    /// Primary neon cyan accent.
    static let accent = UIColor(red: 0.133, green: 0.827, blue: 0.933, alpha: 1)      // #22D3EE
    static let accentDeep = UIColor(red: 0.024, green: 0.714, blue: 0.831, alpha: 1)  // #06B6D4
    static let neonPurple = UIColor(red: 0.659, green: 0.333, blue: 0.969, alpha: 1)  // #A855F7
    static let ok = UIColor(red: 0.204, green: 0.827, blue: 0.600, alpha: 1)          // #34D399
    static let warning = UIColor(red: 0.984, green: 0.749, blue: 0.141, alpha: 1)     // #FBBF24
    static let problem = UIColor(red: 0.984, green: 0.443, blue: 0.522, alpha: 1)     // #FB7185
    static let text = UIColor.white
    static let secondaryText = UIColor(white: 1, alpha: 0.72)
    static let tertiaryText = UIColor(white: 1, alpha: 0.48)
    static let night = UIColor(red: 0.024, green: 0.035, blue: 0.075, alpha: 1)       // #060913
    static let panelStroke = UIColor(red: 0.133, green: 0.827, blue: 0.933, alpha: 0.24)
    static let rowBackground = UIColor(red: 0.055, green: 0.082, blue: 0.165, alpha: 0.74)
    static let rowSelected = UIColor(red: 0.133, green: 0.827, blue: 0.933, alpha: 0.18)

    static func display(_ size: CGFloat, _ weight: UIFont.Weight = .heavy) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        let descriptor = base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor
        return UIFont(descriptor: descriptor, size: size)
    }

    static func body(_ size: CGFloat = 15, _ weight: UIFont.Weight = .regular) -> UIFont {
        .systemFont(ofSize: size, weight: weight)
    }

    /// A blurred neon-tinted glass panel with a crisp hairline stroke. Put content in `contentView`.
    static func panel(cornerRadius: CGFloat = 16, stroke: UIColor = panelStroke) -> UIVisualEffectView {
        let panel = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        panel.contentView.backgroundColor = UIColor(red: 0.045, green: 0.070, blue: 0.145, alpha: 0.45)
        panel.layer.cornerRadius = cornerRadius
        panel.layer.cornerCurve = .continuous
        panel.clipsToBounds = true
        panel.layer.borderWidth = 1
        panel.layer.borderColor = stroke.cgColor
        return panel
    }

    /// Renders the real background artwork (`StartBackground` / `SettingsBackground`) with side scrims
    /// so left/right HUD cards stay legible while the center artwork remains clear.
    static func backdrop(image name: String, darken: CGFloat = 0.55) -> UIView {
        let view = UIView()
        view.backgroundColor = night

        let fallback = GradientView(
            colors: [
                UIColor(red: 0.07, green: 0.05, blue: 0.22, alpha: 1),
                night,
                UIColor(red: 0.02, green: 0.14, blue: 0.24, alpha: 1)
            ],
            locations: [0, 0.52, 1],
            horizontal: true
        )

        let imageView = UIImageView(image: UIImage(named: name))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.94

        // Darken left & right edges where controls sit, keep center bright for artwork & title.
        let sideShade = GradientView(
            colors: [
                night.withAlphaComponent(min(0.86, darken + 0.26)),
                night.withAlphaComponent(0.10),
                night.withAlphaComponent(min(0.86, darken + 0.26))
            ],
            locations: [0, 0.5, 1],
            horizontal: true
        )

        let floorShade = GradientView(
            colors: [.clear, night.withAlphaComponent(0.62)],
            locations: [0.58, 1],
            horizontal: false
        )

        for layer in [fallback, imageView, sideShade, floorShade] as [UIView] {
            layer.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(layer)
            NSLayoutConstraint.activate([
                layer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                layer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                layer.topAnchor.constraint(equalTo: view.topAnchor),
                layer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        view.isUserInteractionEnabled = false
        return view
    }

    /// Evenly dimmed artwork behind Settings / Mod / Save / Files screens.
    static func dimmedBackdrop(image name: String) -> UIView {
        let view = UIView()
        view.backgroundColor = night

        let fallback = GradientView(
            colors: [night, UIColor(red: 0.06, green: 0.05, blue: 0.16, alpha: 1)],
            locations: [0, 1],
            horizontal: true
        )
        let imageView = UIImageView(image: UIImage(named: name))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.55

        let shade = GradientView(
            colors: [
                night.withAlphaComponent(0.82),
                UIColor(red: 0.03, green: 0.05, blue: 0.11, alpha: 0.72),
                night.withAlphaComponent(0.86)
            ],
            locations: [0, 0.5, 1],
            horizontal: true
        )

        for layer in [fallback, imageView, shade] as [UIView] {
            layer.frame = view.bounds
            layer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(layer)
        }
        view.isUserInteractionEnabled = false
        return view
    }

    /// Primary Neon Cyan CTA button (Play / Save / Continue).
    static func primaryButton(_ title: String, symbol: String? = nil) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = symbol.map { UIImage(systemName: $0, withConfiguration: UIImage.SymbolConfiguration(weight: .heavy)) } ?? nil
        config.imagePadding = 10
        config.cornerStyle = .capsule
        config.baseForegroundColor = UIColor(red: 0.015, green: 0.075, blue: 0.10, alpha: 1)
        config.background.backgroundColor = accent
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = display(18, .heavy)
            return attributes
        }
        let button = UIButton(configuration: config)
        button.configurationUpdateHandler = { button in
            button.configuration?.background.backgroundColor = button.isEnabled
                ? (button.isHighlighted ? accentDeep : accent)
                : UIColor(white: 1, alpha: 0.14)
            button.configuration?.baseForegroundColor = button.isEnabled
                ? UIColor(red: 0.015, green: 0.075, blue: 0.10, alpha: 1)
                : UIColor(white: 1, alpha: 0.55)
        }
        button.layer.shadowColor = accent.cgColor
        button.layer.shadowOpacity = 0.45
        button.layer.shadowRadius = 18
        button.layer.shadowOffset = .zero
        return button
    }

    /// Translucent dark glass capsule button with neon stroke.
    static func glassButton(_ title: String, symbol: String, accentColor: UIColor = accent) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        config.imagePadding = 7
        config.cornerStyle = .capsule
        config.baseForegroundColor = text
        config.background.backgroundColor = UIColor(red: 0.055, green: 0.086, blue: 0.17, alpha: 0.78)
        config.background.strokeColor = accentColor.withAlphaComponent(0.32)
        config.background.strokeWidth = 1
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 13, bottom: 8, trailing: 13)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = body(13, .semibold)
            return attributes
        }
        let button = UIButton(configuration: config)
        button.configurationUpdateHandler = { button in
            button.alpha = button.isHighlighted ? 0.72 : (button.isEnabled ? 1.0 : 0.45)
        }
        return button
    }

    /// Compact Cyberpunk Neon dashboard tile button for the 2x3 Home action grid.
    static func tileButton(_ title: String, subtitle: String? = nil, symbol: String, tint: UIColor = accent, highlighted: Bool = false) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.subtitle = subtitle
        config.image = UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        config.imagePlacement = .top
        config.imagePadding = 6
        config.titleAlignment = .leading
        config.cornerStyle = .fixed
        config.background.cornerRadius = 14
        config.background.backgroundColor = UIColor(red: 0.055, green: 0.085, blue: 0.175, alpha: 0.80)
        config.background.strokeColor = highlighted ? tint.withAlphaComponent(0.75) : tint.withAlphaComponent(0.28)
        config.background.strokeWidth = highlighted ? 1.5 : 1
        config.baseForegroundColor = text
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 11, bottom: 10, trailing: 11)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var a = attributes
            a.font = display(13, .bold)
            a.foregroundColor = text
            return a
        }
        config.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var a = attributes
            a.font = body(10, .medium)
            a.foregroundColor = secondaryText
            return a
        }
        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .leading
        button.configurationUpdateHandler = { b in
            b.alpha = b.isHighlighted ? 0.72 : (b.isEnabled ? 1.0 : 0.45)
        }
        return button
    }

    /// Styling for navigation bars across modal screens.
    static func styleNavigation(_ navigation: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.titleTextAttributes = [.foregroundColor: text, .font: display(18, .bold)]
        appearance.largeTitleTextAttributes = [.foregroundColor: text, .font: display(30, .heavy)]
        navigation.navigationBar.standardAppearance = appearance
        navigation.navigationBar.scrollEdgeAppearance = appearance
        navigation.navigationBar.compactAppearance = appearance
        navigation.navigationBar.tintColor = accent
        navigation.overrideUserInterfaceStyle = .dark
        navigation.view.tintColor = accent
    }
}

/// Linear gradient view for backdrop edge scrims and subtle neon glows.
final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    init(colors: [UIColor], locations: [NSNumber], horizontal: Bool) {
        super.init(frame: .zero)
        let gradient = layer as! CAGradientLayer
        gradient.colors = colors.map(\.cgColor)
        gradient.locations = locations
        gradient.startPoint = horizontal ? CGPoint(x: 0, y: 0.5) : CGPoint(x: 0.5, y: 0)
        gradient.endPoint = horizontal ? CGPoint(x: 1, y: 0.5) : CGPoint(x: 0.5, y: 1)
        isUserInteractionEnabled = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
}
