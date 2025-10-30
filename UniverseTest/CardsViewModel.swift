//
//  PeopleViewModel.swift
//  UniverseTest
//
//  Created by Veronika Petrushka on 30/10/2025.
//

import Foundation

protocol CardsViewModelDelegate: AnyObject {
    func didSucceed()
    func didFailed(error: Error)
    func didUpdateCurrentCard()
    func didCompleteAllCards()
}


class CardsViewModel {
    
    private(set) var cards = [ItemResponse]()
    private(set) var currentCardIndex = 0
    private(set) var selectedAnswers: [Int: String] = [:]
    
    weak var delegate: CardsViewModelDelegate?
    
    var currentCard: ItemResponse? {
        guard currentCardIndex < cards.count else { return nil }
        return cards[currentCardIndex]
    }
    
    var progress: Float {
        guard !cards.isEmpty else { return 0 }
        return Float(currentCardIndex) / Float(cards.count)
    }
    
    var hasNextCard: Bool {
        return currentCardIndex < cards.count - 1
    }
    
    
    @MainActor
    func getCardsData() {
        
        Task { [weak self] in
            
            do {
                
                let url = URL(string: "https://test-ios.universeapps.limited/onboarding")!
                let(data, _) = try await URLSession.shared.data(from: url)
                
                print(String(data: data, encoding: .utf8)!)
                
                let jsonDecoder = JSONDecoder()
                let response = try jsonDecoder.decode(CardsResponse.self, from: data)
                self?.cards = response.items
                
                
                self?.delegate?.didSucceed()
                
            } catch {
                self?.delegate?.didFailed(error: error)
            }
            
        }
        
    }
    
    
    func selectAnswer(_ answer: String) {
        guard let currentCard = currentCard else { return }
        selectedAnswers[currentCard.id] = answer
    }
    
    func getSelectedAnswer(for cardId: Int) -> String? {
        return selectedAnswers[cardId]
    }
    
    func goToNextCard() {
        guard hasNextCard else {
            delegate?.didCompleteAllCards()
            return
        }
        
        currentCardIndex += 1
        delegate?.didUpdateCurrentCard()
    }
    
//    remove previous later
    
//    func goToPreviousCard() {
//        guard currentCardIndex > 0 else { return }
//        currentCardIndex -= 1
//        delegate?.didUpdateCurrentCard()
//    }
    
}
