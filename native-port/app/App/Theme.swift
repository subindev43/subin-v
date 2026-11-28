import UIKit

/// Rose Noir (Pink · Violet · Obsidian) design system for SUBIN-V: deep obsidian-plum glass,
/// neon rose-pink and royal violet accents, GTA artwork cards, and 120 Hz smooth springs.
enum Theme {
    /// The app's version as players should quote it in reports, e.g. "v2.0 (20)".
    static let appVersion: String = {
        let info = Bundle.main.infoDictionary
        return "v\(info?["CFBundleShortVersionString"] as? String ?? "?") (\(info?["CFBundleVersion"] as? String ?? "?"))"
    }()

    /// Primary Neon Rose Pink accent.
    static let accent = UIColor(red: 1.000, green: 0.302, blue: 0.651, alpha: 1)      // #FF4DA6
    static let accentDeep = UIColor(red: 0.851, green: 0.149, blue: 0.533, alpha: 1)  // #D92688
    static let neonPurple = UIColor(red: 0.659, green: 0.333, blue: 0.969, alpha: 1)  // #A855F7
    static let softPink = UIColor(red: 0.976, green: 0.659, blue: 0.831, alpha: 1)    // #F9A8D4
    static let ok = UIColor(red: 0.204, green: 0.827, blue: 0.600, alpha: 1)          // #34D399
    static let warning = UIColor(red: 0.984, green: 0.749, blue: 0.141, alpha: 1)     // #FBBF24
    static let problem = UIColor(red: 0.984, green: 0.443, blue: 0.522, alpha: 1)     // #FB7185
    static let text = UIColor.white
    static let secondaryText = UIColor(white: 1, alpha: 0.76)
    static let tertiaryText = UIColor(white: 1, alpha: 0.48)
    static let night = UIColor(red: 0.027, green: 0.016, blue: 0.055, alpha: 1)       // #07040E
    static let obsidianDark = UIColor(red: 0.065, green: 0.024, blue: 0.105, alpha: 1)// #10061B
    static let panelStroke = UIColor(red: 1.000, green: 0.302, blue: 0.651, alpha: 0.26)
    static let rowBackground = UIColor(red: 0.075, green: 0.043, blue: 0.125, alpha: 0.78)
    static let rowSelected = UIColor(red: 1.000, green: 0.302, blue: 0.651, alpha: 0.20)

    static func display(_ size: CGFloat, _ weight: UIFont.Weight = .heavy) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        let descriptor = base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor
        return UIFont(descriptor: descriptor, size: size)
    }

    static func body(_ size: CGFloat = 15, _ weight: UIFont.Weight = .regular) -> UIFont {
        .systemFont(ofSize: size, weight: weight)
    }

    /// A blurred obsidian-plum glass panel with a crisp rose-pink hairline stroke.
    static func panel(cornerRadius: CGFloat = 16, stroke: UIColor = panelStroke) -> UIVisualEffectView {
        let panel = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        panel.contentView.backgroundColor = UIColor(red: 0.055, green: 0.024, blue: 0.098, alpha: 0.58)
        panel.layer.cornerRadius = cornerRadius
        panel.layer.cornerCurve = .continuous
        panel.clipsToBounds = true
        panel.layer.borderWidth = 1
        panel.layer.borderColor = stroke.cgColor
        return panel
    }

    /// Renders the real background artwork (`StartBackground` / `SettingsBackground`) with subtle
    /// black-plum edge scrims so left/right launcher controls stay crisp while the center shines.
    static func backdrop(image name: String, darken: CGFloat = 0.52) -> UIView {
        let view = UIView()
        view.backgroundColor = night

        let fallback = GradientView(
            colors: [
                UIColor(red: 0.18, green: 0.03, blue: 0.14, alpha: 1),
                night,
                UIColor(red: 0.11, green: 0.03, blue: 0.20, alpha: 1)
            ],
            locations: [0, 0.5, 1],
            horizontal: true
        )

        let imageView = UIImageView(image: UIImage(named: name))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.95

        let sideShade = GradientView(
            colors: [
                night.withAlphaComponent(min(0.84, darken + 0.24)),
                night.withAlphaComponent(0.08),
                night.withAlphaComponent(min(0.84, darken + 0.24))
            ],
            locations: [0, 0.5, 1],
            horizontal: true
        )

        let floorShade = GradientView(
            colors: [.clear, night.withAlphaComponent(0.72)],
            locations: [0.55, 1],
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

    /// Evenly dimmed Rose Noir artwork behind Settings / Mod / Save / Files screens.
    static func dimmedBackdrop(image name: String) -> UIView {
        let view = UIView()
        view.backgroundColor = night

        let fallback = GradientView(
            colors: [night, UIColor(red: 0.12, green: 0.03, blue: 0.17, alpha: 1)],
            locations: [0, 1],
            horizontal: true
        )
        let imageView = UIImageView(image: UIImage(named: name))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.45

        let shade = GradientView(
            colors: [
                night.withAlphaComponent(0.86),
                UIColor(red: 0.055, green: 0.020, blue: 0.095, alpha: 0.74),
                night.withAlphaComponent(0.88)
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

    /// GTA Launcher-inspired pearl-white Play CTA with glowing Pink-Violet accent strip.
    static func primaryButton(_ title: String, symbol: String? = nil) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = symbol.map { UIImage(systemName: $0, withConfiguration: UIImage.SymbolConfiguration(weight: .heavy)) } ?? nil
        config.imagePadding = 10
        config.cornerStyle = .fixed
        config.background.cornerRadius = 14
        config.baseForegroundColor = obsidianDark
        config.background.backgroundColor = UIColor(red: 0.992, green: 0.957, blue: 0.980, alpha: 1) // #FFF4FA
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 18)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = display(15.5, .black)
            return attributes
        }
        let button = PrimaryPlayButton(configuration: config)
        button.configurationUpdateHandler = { button in
            button.configuration?.background.backgroundColor = button.isEnabled
                ? (button.isHighlighted
                    ? UIColor(red: 0.96, green: 0.84, blue: 0.92, alpha: 1)
                    : UIColor(red: 0.992, green: 0.957, blue: 0.980, alpha: 1))
                : UIColor(white: 1, alpha: 0.14)
            button.configuration?.baseForegroundColor = button.isEnabled
                ? obsidianDark
                : UIColor(white: 1, alpha: 0.55)
            springPress(button, pressed: button.isHighlighted && button.isEnabled)
        }
        button.layer.shadowColor = accent.cgColor
        button.layer.shadowOpacity = 0.48
        button.layer.shadowRadius = 16
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        return button
    }

    /// Translucent obsidian-violet glass capsule button with rose-pink hairline.
    static func glassButton(_ title: String, symbol: String, accentColor: UIColor = accent) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        config.imagePadding = 7
        config.cornerStyle = .capsule
        config.baseForegroundColor = text
        config.background.backgroundColor = UIColor(red: 0.082, green: 0.039, blue: 0.137, alpha: 0.80)
        config.background.strokeColor = accentColor.withAlphaComponent(0.36)
        config.background.strokeWidth = 1
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 13, bottom: 8, trailing: 13)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = body(13, .semibold)
            return attributes
        }
        let button = UIButton(configuration: config)
        button.configurationUpdateHandler = { button in
            button.alpha = button.isEnabled ? (button.isHighlighted ? 0.82 : 1.0) : 0.45
            springPress(button, pressed: button.isHighlighted && button.isEnabled)
        }
        return button
    }

    /// GTA x iOS Dashboard card tile supporting optional artwork backdrop & pink/violet glow border.
    static func tileButton(_ title: String, subtitle: String? = nil, symbol: String, tint: UIColor = accent, highlighted: Bool = false, artwork: String? = nil) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.subtitle = subtitle
        config.image = UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 13.5, weight: .bold))
        config.imagePlacement = .top
        config.imagePadding = 5
        config.titleAlignment = .leading
        config.cornerStyle = .fixed
        config.background.cornerRadius = 14
        config.background.backgroundColor = artwork != nil ? .clear : UIColor(red: 0.075, green: 0.038, blue: 0.128, alpha: 0.84)
        config.background.strokeColor = highlighted ? tint.withAlphaComponent(0.85) : tint.withAlphaComponent(0.30)
        config.background.strokeWidth = highlighted ? 1.5 : 1
        config.baseForegroundColor = text
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var a = attributes
            a.font = display(12, .bold)
            a.foregroundColor = text
            return a
        }
        config.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var a = attributes
            a.font = body(10, .medium)
            a.foregroundColor = secondaryText
            return a
        }
        let button = TileArtworkButton(configuration: config)
        if let artwork, let img = UIImage(named: artwork) {
            button.installArtwork(img, tint: tint)
        }
        button.contentHorizontalAlignment = .leading
        button.configurationUpdateHandler = { b in
            b.alpha = b.isEnabled ? (b.isHighlighted ? 0.86 : 1.0) : 0.45
            springPress(b, pressed: b.isHighlighted && b.isEnabled)
        }
        return button
    }

    /// Smooth 120Hz-friendly spring press scale without layout churn.
    static func springPress(_ view: UIView, pressed: Bool) {
        let target = pressed ? CGAffineTransform(scaleX: 0.965, y: 0.965) : .identity
        guard view.transform != target else { return }
        UIView.animate(withDuration: 0.22, delay: 0, usingSpringWithDamping: 0.78, initialSpringVelocity: 0.4, options: [.allowUserInteraction, .beginFromCurrentState]) {
            view.transform = target
        }
    }

    static func hapticLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    static func hapticMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
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

/// Rockstar-inspired Play CTA pill with bottom Neon Rose-to-Violet accent bar and cached shadowPath.
private final class PrimaryPlayButton: UIButton {
    private let accentBar = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAccentBar()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    private func setupAccentBar() {
        accentBar.colors = [Theme.accent.cgColor, Theme.neonPurple.cgColor]
        accentBar.startPoint = CGPoint(x: 0, y: 0.5)
        accentBar.endPoint = CGPoint(x: 1, y: 0.5)
        accentBar.cornerRadius = 2
        layer.addSublayer(accentBar)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 15).cgPath
        let barHeight: CGFloat = 3.5
        let inset: CGFloat = 14
        accentBar.frame = CGRect(x: inset, y: bounds.height - barHeight, width: max(0, bounds.width - inset * 2), height: barHeight)
    }
}

/// Dashboard tile hosting masked GTA artwork photo + obsidian-plum scrim behind title/icon.
private final class TileArtworkButton: UIButton {
    private let backdropContainer = UIView()
    private let artView = UIImageView()
    private var scrimView: GradientView?

    func installArtwork(_ image: UIImage, tint: UIColor) {
        backdropContainer.isUserInteractionEnabled = false
        backdropContainer.clipsToBounds = true
        backdropContainer.layer.cornerRadius = 15
        backdropContainer.layer.cornerCurve = .continuous
        backdropContainer.frame = bounds
        backdropContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        artView.image = image
        artView.contentMode = .scaleAspectFill
        artView.alpha = 0.42
        artView.frame = backdropContainer.bounds
        artView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let scrim = GradientView(
            colors: [
                UIColor(red: 0.06, green: 0.02, blue: 0.11, alpha: 0.62),
                UIColor(red: 0.04, green: 0.015, blue: 0.08, alpha: 0.90)
            ],
            locations: [0, 1],
            horizontal: false
        )
        scrim.frame = backdropContainer.bounds
        scrim.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrimView = scrim

        backdropContainer.addSubview(artView)
        backdropContainer.addSubview(scrim)
        insertSubview(backdropContainer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backdropContainer.frame = bounds
    }
}
