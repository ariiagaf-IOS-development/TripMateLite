//
//  SplashViewController.swift
//  TripMate Lite
//

import UIKit

final class SplashViewController: UIViewController {
    
    private enum Layout {
        static let iconContainerSize: CGFloat = 104
        static let iconSize: CGFloat = 52
        
        static let titleFontSize: CGFloat = 34
        static let subtitleFontSize: CGFloat = 16
        static let captionFontSize: CGFloat = 13
        
        static let contentSpacing: CGFloat = 18
    }
    
    private let contentStackView = UIStackView()
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let captionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .appBackground
        
        setupContent()
        animateContent()
        animatePlane()
        animateSubtitleTyping()
        openMainAppAfterDelay()
    }
    
    private func animatePlane() {
        UIView.animate(
            withDuration: 0.75,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: {
                self.iconImageView.transform = CGAffineTransform(
                    translationX: 0,
                    y: -8
                ).rotated(by: -0.08)
            }
        )
    }
    
    private func animateSubtitleTyping() {
        let text = "Plan smarter. Travel lighter."
        subtitleLabel.text = ""
        
        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9 + Double(index) * 0.045) { [weak self] in
                self?.subtitleLabel.text?.append(character)
            }
        }
    }
    
    private func setupContent() {
        view.addSubview(contentStackView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.spacing = Layout.contentSpacing
        
        iconContainerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.10)
        iconContainerView.layer.cornerRadius = 32
        iconContainerView.layer.shadowColor = UIColor.systemBlue.cgColor
        iconContainerView.layer.shadowOpacity = 0.14
        iconContainerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        iconContainerView.layer.shadowRadius = 18
        
        iconImageView.image = UIImage(systemName: "airplane")
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.text = "TripMate"
        titleLabel.font = .systemFont(
            ofSize: Layout.titleFontSize,
            weight: .bold
        )
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        subtitleLabel.text = ""
        subtitleLabel.font = .systemFont(
            ofSize: Layout.subtitleFontSize,
            weight: .medium
        )
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        
        captionLabel.text = "Routes • Stays • Notes"
        captionLabel.font = .systemFont(
            ofSize: Layout.captionFontSize,
            weight: .semibold
        )
        captionLabel.textColor = .tertiaryLabel
        captionLabel.textAlignment = .center
        
        contentStackView.addArrangedSubview(iconContainerView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(captionLabel)
        
        iconContainerView.addSubview(iconImageView)
        
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
            contentStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 32
            ),
            contentStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -32
            ),
            
            iconContainerView.widthAnchor.constraint(equalToConstant: Layout.iconContainerSize),
            iconContainerView.heightAnchor.constraint(equalToConstant: Layout.iconContainerSize),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize)
        ])
    }
    
    private func animateContent() {
        contentStackView.alpha = 0
        contentStackView.transform = CGAffineTransform(
            translationX: 0,
            y: 16
        )
        
        UIView.animate(
            withDuration: 0.65,
            delay: 0.15,
            options: [.curveEaseOut],
            animations: {
                self.contentStackView.alpha = 1
                self.contentStackView.transform = .identity
            }
        )
    }
    
    private func openMainAppAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { [weak self] in
            self?.openMainApp()
        }
    }
    
    private func openMainApp() {
        let mainTabBarController = MainTabBarController()
        
        guard let windowScene = view.window?.windowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            view.window?.rootViewController = mainTabBarController
            view.window?.makeKeyAndVisible()
            return
        }
        
        UIView.transition(
            with: window,
            duration: 1.0,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = mainTabBarController
            }
        )
    }
}
