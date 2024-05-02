//
//  PostColViewCell.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 02/05/24.
//

import UIKit
import Combine

class PostColViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PostColViewCell"
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private let eventSubject = PassthroughSubject<EventPublisher, Never>()
    var eventPublisher: AnyPublisher<EventPublisher, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    var garbageBag = Set<AnyCancellable>()
    
    var viewModal: PostViewModal? {
        didSet {
            guard let viewModal = viewModal else {return}
        
            titleLabel.text = viewModal.title
            descriptionLabel.text = viewModal.desc
            favButton.backgroundColor = viewModal.favorite.0
            favButton.setImage(UIImage(systemName: viewModal.favorite.1), for: .normal)
            
            self.layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        settingUI()
    }
    
    private func settingUI() {
        self.bgView.layer.cornerRadius = 10
        self.bgView.layer.shadowColor = UIColor.black.cgColor
        self.bgView.layer.shadowOffset = .zero
        self.bgView.layer.shadowOpacity = 0.2
        self.bgView.layer.shadowRadius = 5
    }
    
    @IBAction private func didPressArrowBtn(_ sender: UIButton) {
        guard let post = viewModal?.post else {return}
        eventSubject.send(.PostColViewCellArrowTappedEvent(post: post))
    }
}

class PostViewModal {
    var post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    var id: Int {
        return post.id
    }
    
    var title: String? {
        return "\(post.id). \(post.title)"
    }
    
    var desc: String? {
        return post.body
    }
    
    var favorite: (UIColor, String) {
        if post.isFavorite {
            return (CustomColors.customYellow, "star.fill")
        } else {
            return (CustomColors.customBlue, "star")
        }
    }
}
