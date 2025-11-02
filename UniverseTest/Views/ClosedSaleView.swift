//
//  ClosedSaleView.swift
//  UniverseTest
//
//  Created by Veronika Petrushka on 02/11/2025.
//

import UIKit

class ClosedSaleView: UIView {
    
//    UI

    private let containerVw: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.backgroundColor = .customLightGray
        return vw
    }()
        
    private let checkmarkImgVw: UIImageView = {
        let imgvw = UIImageView()
        imgvw.translatesAutoresizingMaskIntoConstraints = false
        imgvw.image = UIImage(systemName: "checkmark.circle.fill")
        imgvw.tintColor = .customGreen
        imgvw.contentMode = .scaleAspectFit
        return imgvw
    }()
    
    private let thankYouLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Thank you for your setup!"
        lbl.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let messageLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "We will get back to you soon!"
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        lbl.textColor = .customDarkGray
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    
//    INIT

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
        

//    SETUP
    
    private func setupUI() {
        
        backgroundColor = .customLightGray
        alpha = 0
        
        addSubview(containerVw)
        containerVw.addSubview(checkmarkImgVw)
        containerVw.addSubview(thankYouLbl)
        containerVw.addSubview(messageLbl)
        
        NSLayoutConstraint.activate([
            containerVw.topAnchor.constraint(equalTo: topAnchor),
            containerVw.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerVw.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerVw.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            checkmarkImgVw.centerXAnchor.constraint(equalTo: containerVw.centerXAnchor),
            checkmarkImgVw.centerYAnchor.constraint(equalTo: containerVw.centerYAnchor, constant: -60),
            checkmarkImgVw.widthAnchor.constraint(equalToConstant: 80),
            checkmarkImgVw.heightAnchor.constraint(equalToConstant: 80),
            
            thankYouLbl.topAnchor.constraint(equalTo: checkmarkImgVw.bottomAnchor, constant: 24),
            thankYouLbl.leadingAnchor.constraint(equalTo: containerVw.leadingAnchor, constant: 40),
            thankYouLbl.trailingAnchor.constraint(equalTo: containerVw.trailingAnchor, constant: -40),
            
            messageLbl.topAnchor.constraint(equalTo: thankYouLbl.bottomAnchor, constant: 12),
            messageLbl.leadingAnchor.constraint(equalTo: containerVw.leadingAnchor, constant: 40),
            messageLbl.trailingAnchor.constraint(equalTo: containerVw.trailingAnchor, constant: -40)
        ])
        
    }
        

//      ANIMATIONS
    
    func show(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.5) {
                self.alpha = 1
            }
        } else {
            self.alpha = 1
        }
    }
    
    func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
            }) { _ in
                completion?()
            }
        } else {
            self.alpha = 0
            completion?()
        }
    }

}
