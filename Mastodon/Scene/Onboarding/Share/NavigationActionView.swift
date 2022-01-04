//
//  NavigationActionView.swift
//  Mastodon
//
//  Created by MainasuK on 2021-12-31.
//

import UIKit

final class NavigationActionView: UIView {
    
    static let buttonHeight: CGFloat = 50
    
    let buttonContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 18
        return stackView
    }()
    
    let backButton: PrimaryActionButton = {
        let button = PrimaryActionButton()
        button.action = .back
        button.setTitle(L10n.Common.Controls.Actions.back, for: .normal)
        return button
    }()
    
    let nextButton: PrimaryActionButton = {
        let button = PrimaryActionButton()
        button.action = .next
        button.setTitle(L10n.Common.Controls.Actions.next, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension NavigationActionView {
    private func _init() {
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.preservesSuperviewLayoutMargins = true
        addSubview(buttonContainer)
        NSLayoutConstraint.activate([
            buttonContainer.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            buttonContainer.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
            safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor, constant: 8),
        ])
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addArrangedSubview(backButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addArrangedSubview(nextButton)
        NSLayoutConstraint.activate([
            backButton.heightAnchor.constraint(equalToConstant: NavigationActionView.buttonHeight).priority(.required - 1),
            nextButton.heightAnchor.constraint(equalToConstant: NavigationActionView.buttonHeight).priority(.required - 1),
            nextButton.widthAnchor.constraint(equalTo: backButton.widthAnchor, multiplier: 2).priority(.required - 1),
        ])
    }
}
