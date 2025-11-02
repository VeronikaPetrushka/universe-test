//
//  SaleView.swift
//  UniverseTest
//
//  Created by Veronika Petrushka on 31/10/2025.
//

import UIKit

class SaleView: UIView {
    
    
    let crossBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let crossImg = UIImage(systemName: "xmark") ?? UIImage(named: "cancel-sale-screen")
        btn.setImage(crossImg, for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = .clear
        btn.isEnabled = true
        return btn
    }()
    
    
    let imageVw: UIImageView = {
        let imgVw = UIImageView()
        imgVw.translatesAutoresizingMaskIntoConstraints = false
        imgVw.contentMode = .scaleAspectFill
        imgVw.image = UIImage(named: "sale-pic")
        imgVw.clipsToBounds = true
        return imgVw
    }()
    

    let titleLbl: UILabel = {
        
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Discover all Premium features"
        lbl.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        lbl.textColor = .black
        lbl.numberOfLines = 0
        return lbl
        
    }()
    
    
    let descLbl: UILabel = {
        
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        
        let attributedStr = NSMutableAttributedString(string: "Try 7 days for free\nthen $6.99 per week, auto-renewable")
        
        let priceRange = (attributedStr.string as NSString).range(of: "$6.99")
        
        attributedStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .regular), range: NSRange(location: 0, length: attributedStr.length))
        attributedStr.addAttribute(.foregroundColor, value: UIColor.customDarkGray, range: NSRange(location: 0, length: attributedStr.length))
        
        attributedStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: priceRange)
        attributedStr.addAttribute(.foregroundColor, value: UIColor.black, range: priceRange)
        
        lbl.attributedText = attributedStr
        return lbl
        
    }()
    
    
    let subscribeBtn: UIButton = {
        
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Start now", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 31
        btn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        btn.isEnabled = true
        
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 8
        btn.layer.shadowOpacity = 0.15
        btn.layer.masksToBounds = false
        
        return btn
        
        
    }()
    
    
    private let termsLink: UITextView = {
        let textVw = UITextView()
        textVw.translatesAutoresizingMaskIntoConstraints = false
        textVw.isScrollEnabled = false
        textVw.isEditable = false
        textVw.backgroundColor = .clear
        textVw.textAlignment = .center
        textVw.textContainerInset = .zero
        textVw.textContainer.lineFragmentPadding = 0
        
        let attributedString = NSMutableAttributedString(string: "By continuing you accept our:\nTerms of Use, Privacy Policy, Subscription Terms")
        
        let termsRange = (attributedString.string as NSString).range(of: "Terms of Use")
        attributedString.addAttribute(.link, value: "https://www.freeprivacypolicy.com/live/16f393d8-94f9-4b8f-a6e0-59f84190fef7", range: termsRange)
        
        let privacyRange = (attributedString.string as NSString).range(of: "Privacy Policy")
        attributedString.addAttribute(.link, value: "https://www.freeprivacypolicy.com/live/a732d79f-c973-437a-8a56-16c262074948", range: privacyRange)
        
        let subscriptionRange = (attributedString.string as NSString).range(of: "Subscription Terms")
        attributedString.addAttribute(.link, value: "https://www.freeprivacypolicy.com/live/16f393d8-94f9-4b8f-a6e0-59f84190fef7", range: subscriptionRange)
        
        let align = NSMutableParagraphStyle()
        align.alignment = .center
        align.lineBreakMode = .byWordWrapping
        
        attributedString.addAttribute(.paragraphStyle, value: align, range: NSRange(location: 0, length: attributedString.length))
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.foregroundColor, value: UIColor.customDarkGray, range: NSRange(location: 0, length: attributedString.length))
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: termsRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: privacyRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: subscriptionRange)
        
        textVw.attributedText = attributedString
        
        textVw.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: 0
        ]
        
        return textVw
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    
//  BUTTONS CLICKS
    
    var onCloseTapped: (() -> Void)?
    
    var onSubscribeTapped: (() -> Void)?
    
    var isLoading: Bool = false {
        didSet {
            subscribeBtn.isEnabled = !isLoading
            subscribeBtn.setTitle(isLoading ? "Processing..." : "Subscribe Now", for: .normal)
        }
    }
    
    
//    SETUP
    
    
    private func setupUI() {
        
        backgroundColor = .customLightGray
        
        addSubview(imageVw)
        addSubview(crossBtn)
        addSubview(titleLbl)
        addSubview(descLbl)
        addSubview(subscribeBtn)
        addSubview(termsLink)
        
        NSLayoutConstraint.activate([
            
//          sale image
            
            imageVw.topAnchor.constraint(equalTo: topAnchor),
            imageVw.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageVw.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageVw.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
            
//           cancel sale button
            
            crossBtn.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            crossBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            crossBtn.widthAnchor.constraint(equalToConstant: 16),
            crossBtn.heightAnchor.constraint(equalToConstant: 16),
            
//           title label
            
            titleLbl.topAnchor.constraint(equalTo: imageVw.bottomAnchor, constant: 40),
            titleLbl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLbl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
//          description
            
            descLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 16),
            descLbl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            descLbl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
//          subscribe button
            
            subscribeBtn.topAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -100),
            subscribeBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            subscribeBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
//          terms links
            
            termsLink.topAnchor.constraint(equalTo: subscribeBtn.bottomAnchor, constant: 20),
            termsLink.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            termsLink.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
        ])
        
        
        bringSubviewToFront(crossBtn)
        crossBtn.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        
        subscribeBtn.addTarget(self, action: #selector(subscribeBtnTapped), for: .touchUpInside)
        
    }
    
    
    @objc private func closeBtnTapped() {
        print("Cancel sale button tapped!")
        onCloseTapped?()
    }
    
    @objc private func subscribeBtnTapped() {
        onSubscribeTapped?()
    }
    
    
}
