//
//  PostDetailVC.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 02/05/24.
//

import UIKit
import Combine

class PostDetailVC: UIViewController, Storyboarded {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var favBtn: UIButton!
    
    var favBarBtnItem: UIBarButtonItem?
    
    var post: Post!
    
    private let eventSubject = PassthroughSubject<EventPublisher, Never>()
    var eventPublisher: AnyPublisher<EventPublisher, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    var garbageBag = Set<AnyCancellable>()
    
    deinit {
        print("PostDetailVC de-initialised")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingUI()
        fillData()
    }
    
    private func settingUI() {
        favBtn.customBtnConfiguration(tintColor: .white, bgColor: .systemBlue, img: nil, title: "Favourite")
        favBtn.layer.cornerRadius = 20
    }
    
    private func fillData() {
        titleLabel.text = post.title
        descLabel.text = post.body
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction private func handleFavBtnTapped(_ sender: UIBarButtonItem) {
        post.isFavorite.toggle()
        favBarBtnItem?.image = post.isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        
        eventSubject.send(.PostDetailVCFavouriteTappedEvent(post: post))
    }
}
