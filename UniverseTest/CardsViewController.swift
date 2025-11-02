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
    private let cardVw = CardView()
    private let saleVw = SaleView()
    private let subscriptionManager = SubscriptionManager()
    private let closedSaleVw = ClosedSaleView()
    
    
// LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardsVM.delegate = self
        
        setupCardVw()
        setupActions()
        setupSaleVw()
        setupClosedSaleVw()
        
        cardsVM.getCardsData()
        
        print("Hey, I'm in !")
    }
    
    
    
//    SETUP
    
    
    private func setupCardVw() {
        
        view.addSubview(cardVw)
        cardVw.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardVw.topAnchor.constraint(equalTo: view.topAnchor),
            cardVw.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardVw.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardVw.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    
        
    }
    
    
    private func setupSaleVw() {
        
        view.addSubview(saleVw)
        saleVw.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saleVw.topAnchor.constraint(equalTo: view.topAnchor),
            saleVw.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            saleVw.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            saleVw.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        saleVw.alpha = 0
        
    }
    
    
    private func setupActions() {
        
        cardVw.continueBtn.addTarget(self, action: #selector(continueBtnTapped), for: .touchUpInside)
        
        saleVw.onCloseTapped = { [weak self] in
                self?.closeSaleTapped()
            }
        
        saleVw.onSubscribeTapped = { [weak self] in
                self?.handleSubscribeTapped()
            }
        
    }
    
    
    private func updateUI() {
        
        print("Updating UI, currentCardIndex: \(cardsVM.currentCardIndex)")
        print("Total cards: \(cardsVM.cards.count)")
        
        guard let currentCard = cardsVM.currentCard else {
            print("No current card available")
            return
        }
        
        print("Current card: \(currentCard.question)")
        
        cardVw.questionLbl.text = currentCard.question
        
        updateAnswerButtons()
        
        updateContinueBtn()
        
    }
    
    
    private func showSaleVw() {

        view.bringSubviewToFront(saleVw)
        
        UIView.animate(withDuration: 0.3) {
            self.cardVw.alpha = 0
            self.saleVw.alpha = 1
        }
        
    }
    
    
    private func setupClosedSaleVw() {
        
        view.addSubview(closedSaleVw)
        closedSaleVw.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closedSaleVw.topAnchor.constraint(equalTo: view.topAnchor),
            closedSaleVw.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            closedSaleVw.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closedSaleVw.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    
    private func updateAnswerButtons() {
        
        cardVw.clearAnswerButtons()
        
        guard let currentCard = cardsVM.currentCard else { return }
        
        for answer in currentCard.answers {
            
            let btn = UIButton(type: .system)
            btn.setTitle(answer, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            btn.backgroundColor = .white
            btn.setTitleColor(.black, for: .normal)
            btn.layer.cornerRadius = 16
            btn.heightAnchor.constraint(equalToConstant: 56).isActive = true
            btn.addTarget(self, action: #selector(answerBtnTapped(_:)), for: .touchUpInside)
            
            btn.contentHorizontalAlignment = .left
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            
            cardVw.addAnswerButton(btn)
        }
        
    }
    
    
    private func updateContinueBtn() {
        
        let hasSelectedAnswer = cardsVM.getSelectedAnswer(for: cardsVM.currentCard?.id ?? 0) != nil
        cardVw.updateContinueBtn(isEnabled: hasSelectedAnswer)
        
    }
    
    
    private func updateSelectedAnswerStyle() {
        
        guard let currentCard = cardsVM.currentCard,
              let selectedAnswer = cardsVM.getSelectedAnswer(for: currentCard.id) else { return }
        
        for case let btn as UIButton in cardVw.answersStackVw.arrangedSubviews {
            let isSelected = btn.titleLabel?.text == selectedAnswer
            btn.backgroundColor = isSelected ? .customGreen : .white
            btn.setTitleColor(isSelected ? .white : .black, for: .normal)
            
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
            UIView.animate(withDuration: 0.25, animations: {
                self.cardVw.contentStackVw.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                self.cardVw.contentStackVw.alpha = 0
            }) { _ in
                self.cardsVM.goToNextCard()
                
//              new card
                
                self.cardVw.contentStackVw.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                self.updateUI()
                
//              slide in new card
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    self.cardVw.contentStackVw.transform = .identity
                    self.cardVw.contentStackVw.alpha = 1
                })
            }
        } else  {
            showSaleVw()
        }
        
    }
    
    
    @objc private func closeSaleTapped() {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.saleVw.alpha = 0
            self.cardVw.alpha = 0
            
        }) { _ in
            
            self.view.sendSubviewToBack(self.saleVw)
            self.showClosedSaleVw()
            
        }
        
    }
    

    private func handleSubscribeTapped() {
        
        Task { @MainActor in
            await purchaseSubscription()
        }
        
    }
    
    
    private func showClosedSaleVw() {
        
        view.bringSubviewToFront(closedSaleVw)
        closedSaleVw.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.hideClosedSaleVw()
        }
        
    }
    
    
    private func hideClosedSaleVw() {
        
        closedSaleVw.hide { [weak self] in
            self?.view.sendSubviewToBack(self!.closedSaleVw)
            self?.restartOnboardingFlow()
        }
        
    }

    
    private func restartOnboardingFlow() {
        
        cardsVM.resetToFirstCard()
        
        cardVw.clearAnswerButtons()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.cardVw.alpha = 1
        }) { _ in
            self.updateUI()
        }
        
    }
    
    
    private func purchaseSubscription() async {
        
        do {
            
            await MainActor.run {
                self.subscriptionManager.isLoading = true
            }
            
            // Load product if not already loaded
            if subscriptionManager.product == nil {
                _ = try await subscriptionManager.loadSubscriptionProduct()
            }
            
            // Attempt purchase
            let transaction = try await subscriptionManager.purchaseSubscription()
            
            // Success
            await MainActor.run {
                self.subscriptionManager.isLoading = false
            }
            
            print("Purchase successful: \(transaction)")
            
            // Show success and navigate
            showSuccessAlert()
            
        } catch SubscriptionError.userCancelled {
            
            await MainActor.run {
                self.subscriptionManager.isLoading = false
            }
            print("User cancelled purchase")
            
        } catch {
            
            await MainActor.run {
                self.subscriptionManager.isLoading = false
            }
            print("Purchase failed: \(error.localizedDescription)")
            showErrorAlert(error: error)
            
        }
        
    }
    
    
    private func showLoadingIndicator() {
        
        let alert = UIAlertController(title: "Processing...", message: "Please wait", preferredStyle: .alert)
        present(alert, animated: true)
        
    }
    
    
    private func hideLoadingIndicator() {
        dismiss(animated: true)
    }
    
    
    private func showSuccessAlert() {
        
        let alert = UIAlertController(
            title: "Success!",
            message: "Your subscription has been activated",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            
//      navigate to main screen
            
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}



extension CardsViewController: CardsViewModelDelegate {
    
    
    func didSucceed() {
        print("Data loaded successfully!")
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
        showSaleVw()
    }
    
    
}


//      CUSTOM COLORS

extension UIColor {
    static let customGreen = UIColor(red: 71/255, green: 190/255, blue: 154/255, alpha: 1.0) // #47BE9A
    static let customLightGray = UIColor(red: 241/255, green: 241/255, blue: 245/255, alpha: 1.0) // #F1F1F5
    static let customMediumGray = UIColor(red: 202/255, green: 202/255, blue: 202/255, alpha: 1.0) // #CACACA
    static let customDarkGray = UIColor(red: 110/255, green: 110/255, blue: 115/255, alpha: 1.0) // #6E6E73
}
