//
//  CardsViewController.swift
//  UniverseTest
//
//  Created by Veronika Petrushka on 30/10/2025.
//

import UIKit

class CardsViewController: UIViewController {
    
    //    INITIALIZE
    
    private let cardsVM = CardsViewModel()
        
//        init(cardsVM: CardsViewModel) {
//            self.cardsVM = cardsVM
//            super.init(nibName: nil, bundle: nil)
//        }
        
//        required init?(coder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
    
    
//    UI
    
    private let pv: UIProgressView = {
        
        let pv = UIProgressView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.progressTintColor = .systemBlue
        pv.trackTintColor = .systemGray5
        return pv
        
    }()
    
    
    private let questionLbl: UILabel = {
        
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 24, weight: .bold)
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
        
    }()
    
    
    private let answersStackVw: UIStackView = {
        
        let vw = UIStackView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.axis = .vertical
        vw.spacing = 12
        return vw
        
    }()
    
    
    private let continueBtn: UIButton = {
        
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Continue", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.heightAnchor.constraint(equalToConstant: 56).isActive = true
        btn.isEnabled = false
        btn.alpha = 0.6
        return btn
        
    }()
    
    
    
// LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardsVM.getCardsData()
        setupUI()
        setupActions()
        updateUI()
        print("Hey, I'm in !")
    }
    
    
//    SETUP
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(pv)
        view.addSubview(questionLbl)
        view.addSubview(answersStackVw)
        view.addSubview(continueBtn)
        
        NSLayoutConstraint.activate([
            
//            progress view
            
            pv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pv.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, constant: 4),
            pv.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            pv.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            
//            question label
            
            questionLbl.topAnchor.constraint(equalTo: pv.bottomAnchor, constant: 16),
            questionLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            questionLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            
//            answer stack view
            
            answersStackVw.topAnchor.constraint(equalTo: questionLbl.bottomAnchor, constant: 20),
            answersStackVw.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            answersStackVw.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            
//            continue button
            
            continueBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -82),
            continueBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            continueBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
        ])
        
    }
    
    
    
    private func setupActions() {
        continueBtn.addTarget(self, action: #selector(continueBtnTapped), for: .touchUpInside)
    }
    
    
    private func updateUI() {
        
        guard let currentCard = cardsVM.currentCard else { return }
        
        pv.progress = cardsVM.progress
        questionLbl.text = currentCard.question
        
        updateAnswerButtons()
        
        updateContinueBtn()
        
    }
    
    
    private func updateAnswerButtons() {
        
        answersStackVw.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let currentCard = cardsVM.currentCard else { return }
        
        for answer in currentCard.answers {
            
            let btn = UIButton(type: .system)
            btn.setTitle(answer, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            btn.backgroundColor = .systemGray6
            btn.setTitleColor(.black, for: .normal)
            btn.layer.cornerRadius = 12
            btn.heightAnchor.constraint(equalToConstant: 56).isActive = true
            btn.addTarget(self, action: #selector(answerBtnTapped(_:)), for: .touchUpInside)
            
            if answer.lowercased().contains("prefer not to answer") {
                btn.backgroundColor = .clear
                btn.setTitleColor(.systemGray, for: .normal)
                btn.layer.borderWidth = 1
                btn.layer.borderColor = UIColor.systemGray3.cgColor
            }
            
            answersStackVw.addArrangedSubview(btn)
        }
        
    }
    
    
    private func updateContinueBtn() {
        
        let hasSelectedAnswer = cardsVM.getSelectedAnswer(for: cardsVM.currentCard?.id ?? 0) != nil
        continueBtn.isEnabled = hasSelectedAnswer
        continueBtn.alpha = hasSelectedAnswer ? 1.0 : 0.6
        
    }
    
    
    private func updateSelectedAnswerStyle() {
        
        guard let currentCard = cardsVM.currentCard,
              let selectedAnswer = cardsVM.getSelectedAnswer(for: currentCard.id) else { return }
        
        for case let btn as UIButton in answersStackVw.arrangedSubviews {
            let isSelected = btn.titleLabel?.text == selectedAnswer
            btn.backgroundColor = isSelected ? .systemBlue : .systemGray
            btn.setTitleColor(isSelected ? .white : .black, for: .normal)
            
            
            if btn.titleLabel?.text?.lowercased().contains("prefer not to answer") == true {
                
                if isSelected {
                    
                    btn.backgroundColor = .systemBlue
                    btn.setTitleColor(.white, for: .normal)
                    btn.layer.borderWidth = 0
                    
                } else {
                    
                    btn.backgroundColor = .clear
                    btn.setTitleColor(.systemGray, for: .normal)
                    btn.layer.borderWidth = 1
                    btn.layer.borderColor = UIColor.systemGray3.cgColor
                    
                }
                
            }
            
            
        }
        
    }
    
    
    @objc private func answerBtnTapped(_ sender: UIButton) {
        
        guard let answer = sender.titleLabel?.text,
              let currentCard = cardsVM.currentCard else { return }
        
        cardsVM.selectAnswer(answer)
        updateSelectedAnswerStyle()
        updateContinueBtn()
        
    }
    
    
    @objc private func continueBtnTapped() {
        
        if cardsVM.hasNextCard{
            cardsVM.goToNextCard()
            updateUI()
        } else  {
            showCompletionAlert()
        }
        
    }
    
    
    private func showCompletionAlert() {
        
        let alert = UIAlertController(
            title: "Completed!",
            message: "You have answered all questions",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
    }
    

}


extension CardsViewController: CardsViewModelDelegate {
    
    
    func didSucceed() {
        updateUI()
    }
    
    
    func didFailed(error: Error) {
        
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
    }
    
    
    func didUpdateCurrentCard() {
        updateUI()
    }
    
    
    func didCompleteAllCards() {
        showCompletionAlert()
    }
    
    
//    func setup() {
//        self.view.backgroundColor = .white
//    }
    
    
}
