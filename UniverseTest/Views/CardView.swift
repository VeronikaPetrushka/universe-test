//
//  CardView.swift
//  UniverseTest
//
//  Created by Veronika Petrushka on 31/10/2025.
//

import UIKit

class CardView: UIView {

//    UI
        
        let titleLbl: UILabel = {
            
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.text = "Let’s setup App for you"
            lbl.font = UIFont.systemFont(ofSize: 26, weight: .bold)
            lbl.textColor = .black
            return lbl
            
        }()
        
        
        let questionLbl: UILabel = {
            
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.font = .systemFont(ofSize: 20, weight: .bold)
            lbl.textColor = .black
            lbl.numberOfLines = 0
            return lbl
            
        }()
        
        
        let answersStackVw: UIStackView = {
            
            let vw = UIStackView()
            vw.translatesAutoresizingMaskIntoConstraints = false
            vw.axis = .vertical
            vw.spacing = 12
            return vw
            
        }()
        
        
        let continueBtn: UIButton = {
            
            let btn = UIButton(type: .system)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.setTitle("Continue", for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            btn.backgroundColor = .black
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 31
            btn.heightAnchor.constraint(equalToConstant: 60).isActive = true
            btn.isEnabled = false
            
            btn.layer.shadowColor = UIColor.black.cgColor
            btn.layer.shadowOffset = CGSize(width: 0, height: 4)
            btn.layer.shadowRadius = 8
            btn.layer.shadowOpacity = 0.15
            btn.layer.masksToBounds = false
            
            return btn
            
        }()
    
    
    let contentStackVw: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    
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
        
        addSubview(titleLbl)
        addSubview(contentStackVw)
        addSubview(continueBtn)
        
        contentStackVw.addArrangedSubview(questionLbl)
        contentStackVw.addArrangedSubview(answersStackVw)
        
        NSLayoutConstraint.activate([
            
//            title label
            
            titleLbl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLbl.heightAnchor.constraint(equalToConstant: 30),
            titleLbl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLbl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            
//          content stack view (question + answers)
            
            contentStackVw.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 32),
            contentStackVw.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            contentStackVw.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
    
//            continue button
            
            continueBtn.topAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -100),
            continueBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            continueBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
        ])
        
    }
    
    
    func updateContinueBtn(isEnabled: Bool) {
        
        continueBtn.isEnabled = isEnabled
        continueBtn.backgroundColor = isEnabled ? .black : .white
        continueBtn.setTitleColor(isEnabled ? .white : .customMediumGray, for: .normal)
        
    }
    
    
    func clearAnswerButtons() {
        answersStackVw.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
        
    func addAnswerButton(_ btn: UIButton) {
        answersStackVw.addArrangedSubview(btn)
    }

}
