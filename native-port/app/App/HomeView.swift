import UIKit

/// Rose Noir (Pink · Violet · Obsidian) start launcher: blends GTA artwork cards with sleek iOS glass
/// controls along the left and right edges while keeping the center SUBIN-V hero artwork clean.
final class HomeView: UIView {
    enum FilesState { case ready, attention, problem, busy }

    let playButton = Theme.primaryButton(L10n.text("Vào game"), symbol: "play.fill")
    let cheatButton = Theme.tileButton(L10n.text("Menu Cheat"), subtitle: L10n.text("Trainer & Gọi xe"), symbol: "bolt.fill", tint: Theme.accent, highlighted: true, artwork: "CardCheat")
    let modButton = Theme.tileButton(L10n.text("Quản lý Mod"), subtitle: L10n.text("DLC .rpf & Xe mod"), symbol: "cube.box.fill", tint: Theme.neonPurple, artwork: "CardMods")
    let settingsButton = Theme.tileButton(L10n.text("Đồ họa & FPS"), subtitle: L10n.text("DLSS5 · 120 FPS · RAM"), symbol: "slider.horizontal.3", tint: Theme.accent, artwork: "CardSettings")
    let layoutButton = Theme.tileButton(L10n.text("Bố trí nút"), subtitle: L10n.text("Cảm ứng & Gyro"), symbol: "hand.tap.fill", tint: Theme.softPink, artwork: "CardLayout")
    let onlineButton = Theme.tileButton(L10n.text("Máy chủ Online"), subtitle: L10n.text("UDP · Voice 3D"), symbol: "network", tint: Theme.neonPurple, artwork: "CardOnline")
    let saveButton = Theme.tileButton(L10n.text("Save game"), subtitle: L10n.text("Sao lưu & Khôi phục"), symbol: "externaldrive.fill", tint: Theme.warning, artwork: "CardSave")
    let languageButton = Theme.glassButton("VI", symbol: "globe")
    let preloadLabel = UILabel()
    let controllerLabel = UILabel()

    var onFiles: (() -> Void)?
    var onMode: ((Int) -> Void)?
    var onMap: ((Int) -> Void)?

    private let filesCard = UIControl()
    private let filesIcon = UIImageView()
    private let filesTitle = UILabel()
    private let filesDetail = UILabel()
    private let filesSpinner = UIActivityIndicatorView(style: .medium)
    private var modeCards: [ModeCard] = []
    private let modeDetail = UILabel()
    private let mapRow = UIStackView()
    private var mapChips: [UIButton] = []

    init(modes: [(title: String, symbol: String)], log: UIView) {
        super.init(frame: .zero)
        let backdrop = Theme.backdrop(image: "StartBackground", darken: 0.54)
        pin(backdrop, to: self)

        // Top compact status header (left brand pill + right language pill, center clear for SUBIN-V hero art)
        let icon = UIImageView(image: UIImage(named: "HomeIcon"))
        icon.contentMode = .scaleAspectFill
        icon.backgroundColor = .black
        icon.layer.cornerRadius = 11
        icon.layer.cornerCurve = .continuous
        icon.layer.borderWidth = 1.2
        icon.layer.borderColor = Theme.accent.withAlphaComponent(0.75).cgColor
        icon.clipsToBounds = true
        icon.widthAnchor.constraint(equalToConstant: 38).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 38).isActive = true

        let title = UILabel()
        title.text = "SUBIN V"
        title.font = Theme.display(19, .black)
        title.textColor = Theme.text

        let badge = PaddedBadge(text: "ROSE NOIR · \(Theme.appVersion)", accent: Theme.accent)
        let titleStack = UIStackView(arrangedSubviews: [title, badge])
        titleStack.axis = .vertical
        titleStack.spacing = 2
        titleStack.alignment = .leading

        let brandRow = UIStackView(arrangedSubviews: [icon, titleStack])
        brandRow.spacing = 10
        brandRow.alignment = .center

        let topBar = UIStackView(arrangedSubviews: [brandRow, UIView(), languageButton])
        topBar.alignment = .center
        topBar.spacing = 10
        topBar.translatesAutoresizingMaskIntoConstraints = false
        languageButton.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(topBar)

        // Left launch dock: Mode Artwork Cards -> Description -> Play CTA -> Floating Files Card -> Telemetry
        buildFilesCard()
        let modeArtworks = ["CardStory", "CardSandbox"]
        for (index, mode) in modes.enumerated() {
            let art = index < modeArtworks.count ? modeArtworks[index] : nil
            let card = ModeCard(title: L10n.text(mode.title), symbol: mode.symbol, artwork: art)
            card.addAction(UIAction { [weak self] _ in self?.onMode?(index) }, for: .touchUpInside)
            modeCards.append(card)
        }
        let modesStack = UIStackView(arrangedSubviews: modeCards)
        modesStack.spacing = 8
        modesStack.distribution = .fillEqually

        modeDetail.font = Theme.body(12)
        modeDetail.textColor = Theme.secondaryText
        modeDetail.numberOfLines = 2
        modeDetail.adjustsFontSizeToFitWidth = true
        modeDetail.minimumScaleFactor = 0.85

        setupMapRow()

        for label in [preloadLabel, controllerLabel] {
            label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .medium)
            label.textColor = Theme.softPink.withAlphaComponent(0.92)
            label.numberOfLines = 0
        }
        preloadLabel.isHidden = true

        let leftColumn = UIStackView(arrangedSubviews: [modesStack, modeDetail, mapRow, playButton, filesCard, preloadLabel, controllerLabel])
        leftColumn.axis = .vertical
        leftColumn.spacing = 9
        leftColumn.setCustomSpacing(4, after: modesStack)
        leftColumn.setCustomSpacing(10, after: modeDetail)
        leftColumn.setCustomSpacing(10, after: playButton)
        leftColumn.alignment = .fill
        leftColumn.translatesAutoresizingMaskIntoConstraints = false

        let leftScroll = UIScrollView()
        leftScroll.showsVerticalScrollIndicator = false
        leftScroll.alwaysBounceVertical = false
        leftScroll.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftScroll)
        leftScroll.addSubview(leftColumn)

        // Right 2x3 GTA × iOS Dashboard Grid
        let hubDot = UIView()
        hubDot.backgroundColor = Theme.accent
        hubDot.layer.cornerRadius = 3.5
        hubDot.translatesAutoresizingMaskIntoConstraints = false
        hubDot.widthAnchor.constraint(equalToConstant: 7).isActive = true
        hubDot.heightAnchor.constraint(equalToConstant: 7).isActive = true

        let hubHeader = UILabel()
        hubHeader.text = L10n.text("Thiết lập trải nghiệm")
        hubHeader.font = Theme.display(13, .bold)
        hubHeader.textColor = Theme.softPink

        let hubTitleRow = UIStackView(arrangedSubviews: [hubDot, hubHeader, UIView()])
        hubTitleRow.spacing = 6
        hubTitleRow.alignment = .center

        let row1 = makeGridRow(cheatButton, modButton)
        let row2 = makeGridRow(settingsButton, layoutButton)
        let row3 = makeGridRow(onlineButton, saveButton)

        let versionLabel = UILabel()
        versionLabel.text = "SUBIN V · Rose Noir · \(Theme.appVersion)"
        versionLabel.font = .monospacedSystemFont(ofSize: 10, weight: .medium)
        versionLabel.textColor = Theme.tertiaryText
        versionLabel.textAlignment = .right

        let rightColumn = UIStackView(arrangedSubviews: [hubTitleRow, row1, row2, row3, versionLabel])
        rightColumn.axis = .vertical
        rightColumn.spacing = 8
        rightColumn.setCustomSpacing(6, after: hubTitleRow)
        rightColumn.alignment = .fill
        rightColumn.translatesAutoresizingMaskIntoConstraints = false

        let rightScroll = UIScrollView()
        rightScroll.showsVerticalScrollIndicator = false
        rightScroll.alwaysBounceVertical = false
        rightScroll.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightScroll)
        rightScroll.addSubview(rightColumn)

        log.translatesAutoresizingMaskIntoConstraints = false
        addSubview(log)

        let guide = safeAreaLayoutGuide
        let sideWidth = leftScroll.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.34)
        sideWidth.priority = .defaultHigh

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            topBar.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 18),
            topBar.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -18),

            leftScroll.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 18),
            leftScroll.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),
            leftScroll.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8),
            sideWidth,
            leftScroll.widthAnchor.constraint(lessThanOrEqualToConstant: 325),
            leftScroll.widthAnchor.constraint(greaterThanOrEqualToConstant: 225),

            leftColumn.leadingAnchor.constraint(equalTo: leftScroll.contentLayoutGuide.leadingAnchor),
            leftColumn.trailingAnchor.constraint(equalTo: leftScroll.contentLayoutGuide.trailingAnchor),
            leftColumn.widthAnchor.constraint(equalTo: leftScroll.frameLayoutGuide.widthAnchor),
            leftColumn.topAnchor.constraint(greaterThanOrEqualTo: leftScroll.contentLayoutGuide.topAnchor),
            leftColumn.bottomAnchor.constraint(equalTo: leftScroll.contentLayoutGuide.bottomAnchor),
            leftColumn.heightAnchor.constraint(greaterThanOrEqualTo: leftScroll.frameLayoutGuide.heightAnchor),

            rightScroll.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -18),
            rightScroll.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),
            rightScroll.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8),
            rightScroll.widthAnchor.constraint(equalTo: leftScroll.widthAnchor),

            rightColumn.leadingAnchor.constraint(equalTo: rightScroll.contentLayoutGuide.leadingAnchor),
            rightColumn.trailingAnchor.constraint(equalTo: rightScroll.contentLayoutGuide.trailingAnchor),
            rightColumn.widthAnchor.constraint(equalTo: rightScroll.frameLayoutGuide.widthAnchor),
            rightColumn.topAnchor.constraint(greaterThanOrEqualTo: rightScroll.contentLayoutGuide.topAnchor),
            rightColumn.bottomAnchor.constraint(equalTo: rightScroll.contentLayoutGuide.bottomAnchor),
            rightColumn.heightAnchor.constraint(greaterThanOrEqualTo: rightScroll.frameLayoutGuide.heightAnchor),

            log.leadingAnchor.constraint(equalTo: leftScroll.trailingAnchor, constant: 12),
            log.trailingAnchor.constraint(equalTo: rightScroll.leadingAnchor, constant: -12),
            log.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 10),
            log.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -10)
        ])

        // Push left & right panels slightly downward so center hero artwork breathes cleanly.
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        leftColumn.insertArrangedSubview(leftSpacer, at: 0)
        rightColumn.insertArrangedSubview(rightSpacer, at: 0)
        leftSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        rightSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    private func makeGridRow(_ left: UIButton, _ right: UIButton) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [left, right])
        row.spacing = 8
        row.distribution = .fillEqually
        row.alignment = .fill
        return row
    }

    private func setupMapRow() {
        let mapLabel = UILabel()
        mapLabel.text = L10n.text("Bản đồ")
        mapLabel.font = Theme.body(12, .semibold)
        mapLabel.textColor = Theme.secondaryText
        mapRow.addArrangedSubview(mapLabel)
        for (index, title) in ["Los Santos"].enumerated() {
            var config = UIButton.Configuration.gray()
            config.title = title
            config.cornerStyle = .capsule
            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { a in
                var a = a; a.font = Theme.body(12, .semibold); return a
            }
            let chip = UIButton(configuration: config)
            chip.addAction(UIAction { [weak self] _ in self?.onMap?(index) }, for: .touchUpInside)
            mapChips.append(chip)
            mapRow.addArrangedSubview(chip)
        }
        mapRow.addArrangedSubview(UIView())
        mapRow.spacing = 8
        mapRow.alignment = .center
        mapRow.isHidden = true
    }

    private func buildFilesCard() {
        let panel = Theme.panel(cornerRadius: 14, stroke: Theme.neonPurple.withAlphaComponent(0.32))
        panel.isUserInteractionEnabled = false
        pin(panel, to: filesCard)

        filesIcon.contentMode = .scaleAspectFit
        filesIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 19, weight: .semibold)
        filesTitle.font = Theme.body(13, .bold)
        filesTitle.textColor = Theme.text
        filesDetail.font = Theme.body(11)
        filesDetail.textColor = Theme.secondaryText
        filesDetail.numberOfLines = 2

        let texts = UIStackView(arrangedSubviews: [filesTitle, filesDetail])
        texts.axis = .vertical
        texts.spacing = 2

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)))
        chevron.tintColor = Theme.accent
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        filesSpinner.color = Theme.accent
        let iconHolder = UIView()
        for view in [filesIcon, filesSpinner] as [UIView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            iconHolder.addSubview(view)
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: iconHolder.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: iconHolder.centerYAnchor)
            ])
        }
        iconHolder.widthAnchor.constraint(equalToConstant: 24).isActive = true

        let row = UIStackView(arrangedSubviews: [iconHolder, texts, chevron])
        row.spacing = 10
        row.alignment = .center
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        filesCard.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: filesCard.leadingAnchor, constant: 11),
            row.trailingAnchor.constraint(equalTo: filesCard.trailingAnchor, constant: -11),
            row.topAnchor.constraint(equalTo: filesCard.topAnchor, constant: 7),
            row.bottomAnchor.constraint(equalTo: filesCard.bottomAnchor, constant: -7)
        ])
        filesCard.accessibilityTraits = .button
        filesCard.isAccessibilityElement = true
        filesCard.addAction(UIAction { [weak self] _ in
            Theme.hapticLight()
            self?.onFiles?()
        }, for: .touchUpInside)
        filesCard.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.filesCard.alpha = 0.85
            Theme.springPress(self.filesCard, pressed: true)
        }, for: [.touchDown, .touchDragEnter])
        filesCard.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.filesCard.alpha = 1
            Theme.springPress(self.filesCard, pressed: false)
        }, for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    func setFiles(_ state: FilesState, title: String, detail: String) {
        filesTitle.text = L10n.text(title)
        filesDetail.text = L10n.text(detail)
        filesDetail.isHidden = detail.isEmpty
        filesSpinner.isHidden = state != .busy
        filesIcon.isHidden = state == .busy
        if state == .busy { filesSpinner.startAnimating() } else { filesSpinner.stopAnimating() }
        let (symbol, color): (String, UIColor) = switch state {
        case .ready: ("checkmark.circle.fill", Theme.ok)
        case .attention: ("folder.badge.plus", Theme.warning)
        case .problem: ("exclamationmark.triangle.fill", Theme.problem)
        case .busy: ("", Theme.text)
        }
        filesIcon.image = symbol.isEmpty ? nil : UIImage(systemName: symbol)
        filesIcon.tintColor = color
        filesCard.accessibilityLabel = "Game files: \(title). \(detail)"
    }

    func setMap(_ index: Int, visible: Bool, enabled: Bool) {
        mapRow.isHidden = true
        modeDetail.isHidden = false
        for (i, chip) in mapChips.enumerated() {
            let selected = i == index
            chip.isEnabled = enabled
            chip.configuration?.baseForegroundColor = selected ? Theme.accent : Theme.text
            chip.configuration?.background.backgroundColor = selected ? Theme.accent.withAlphaComponent(0.20) : UIColor(white: 1, alpha: 0.1)
            chip.configuration?.background.strokeColor = selected ? Theme.accent : .clear
            chip.configuration?.background.strokeWidth = selected ? 1.5 : 0
            chip.accessibilityTraits = selected ? [.button, .selected] : .button
            chip.accessibilityLabel = "Sandbox map: " + GameSettings.sandboxMapTitles[i]
        }
    }

    func setMode(_ index: Int?, detail: String, enabled: Bool) {
        for (i, card) in modeCards.enumerated() {
            card.isSelected = i == index
            card.isEnabled = enabled
        }
        modeDetail.text = L10n.text(detail)
    }

    private func pin(_ view: UIView, to parent: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            view.topAnchor.constraint(equalTo: parent.topAnchor),
            view.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
    }
}

private final class PaddedBadge: UIView {
    init(text: String, accent: UIColor) {
        super.init(frame: .zero)
        backgroundColor = accent.withAlphaComponent(0.16)
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = accent.withAlphaComponent(0.50).cgColor
        let label = UILabel()
        label.text = text
        label.font = .monospacedSystemFont(ofSize: 10, weight: .bold)
        label.textColor = Theme.softPink
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
}

private final class ModeCard: UIControl {
    private let panel = Theme.panel(cornerRadius: 14)
    private let artView = UIImageView()
    private let artScrim: GradientView
    private let icon = UIImageView()
    private let label = UILabel()
    private let activeTag = UILabel()

    init(title: String, symbol: String, artwork: String?) {
        artScrim = GradientView(
            colors: [
                UIColor(red: 0.08, green: 0.02, blue: 0.14, alpha: 0.48),
                UIColor(red: 0.04, green: 0.015, blue: 0.08, alpha: 0.90)
            ],
            locations: [0, 1],
            horizontal: false
        )
        super.init(frame: .zero)
        panel.isUserInteractionEnabled = false
        panel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(panel)

        if let artwork, let img = UIImage(named: artwork) {
            artView.image = img
            artView.contentMode = .scaleAspectFill
            artView.clipsToBounds = true
            artView.alpha = 0.60
            artView.translatesAutoresizingMaskIntoConstraints = false
            panel.contentView.addSubview(artView)
            artScrim.translatesAutoresizingMaskIntoConstraints = false
            panel.contentView.addSubview(artScrim)
            NSLayoutConstraint.activate([
                artView.leadingAnchor.constraint(equalTo: panel.contentView.leadingAnchor),
                artView.trailingAnchor.constraint(equalTo: panel.contentView.trailingAnchor),
                artView.topAnchor.constraint(equalTo: panel.contentView.topAnchor),
                artView.bottomAnchor.constraint(equalTo: panel.contentView.bottomAnchor),
                artScrim.leadingAnchor.constraint(equalTo: panel.contentView.leadingAnchor),
                artScrim.trailingAnchor.constraint(equalTo: panel.contentView.trailingAnchor),
                artScrim.topAnchor.constraint(equalTo: panel.contentView.topAnchor),
                artScrim.bottomAnchor.constraint(equalTo: panel.contentView.bottomAnchor)
            ])
        }

        activeTag.text = "ACTIVE"
        activeTag.font = .monospacedSystemFont(ofSize: 8.5, weight: .black)
        activeTag.textColor = Theme.night
        activeTag.backgroundColor = Theme.accent
        activeTag.textAlignment = .center
        activeTag.layer.cornerRadius = 5
        activeTag.clipsToBounds = true
        activeTag.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activeTag)

        icon.image = UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))
        label.text = title
        label.font = Theme.display(13, .heavy)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        let row = UIStackView(arrangedSubviews: [icon, label])
        row.spacing = 6
        row.alignment = .center
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: trailingAnchor),
            panel.topAnchor.constraint(equalTo: topAnchor),
            panel.bottomAnchor.constraint(equalTo: bottomAnchor),
            activeTag.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            activeTag.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            activeTag.widthAnchor.constraint(equalToConstant: 42),
            activeTag.heightAnchor.constraint(equalToConstant: 14),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            row.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            heightAnchor.constraint(equalToConstant: 52)
        ])
        isAccessibilityElement = true
        accessibilityLabel = title
        update()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    override var isSelected: Bool { didSet { update() } }
    override var isEnabled: Bool { didSet { update() } }
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.86 : 1
            Theme.springPress(self, pressed: isHighlighted && isEnabled)
        }
    }

    private func update() {
        let color = isSelected ? Theme.softPink : Theme.text
        icon.tintColor = isSelected ? Theme.accent : Theme.text
        label.textColor = isEnabled ? color : Theme.tertiaryText
        activeTag.isHidden = !isSelected
        artView.alpha = isSelected ? 0.72 : 0.42
        UIView.animate(withDuration: 0.18, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.panel.contentView.backgroundColor = self.isSelected
                ? Theme.accent.withAlphaComponent(0.16)
                : UIColor(red: 0.055, green: 0.024, blue: 0.098, alpha: 0.65)
        }
        panel.layer.borderColor = (isSelected ? Theme.accent : Theme.neonPurple.withAlphaComponent(0.32)).cgColor
        panel.layer.borderWidth = isSelected ? 1.8 : 1
        accessibilityTraits = isSelected ? [.button, .selected] : .button
    }
}
