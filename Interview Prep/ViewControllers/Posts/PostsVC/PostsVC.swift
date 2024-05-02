//
//  PostsVC.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 01/05/24.
//

import UIKit
import Combine

class PostsVC: LoadingIndicatorViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModal = PostsVM()
    var garbageBag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        settingCollectionView()
        observe()
        fetchData()
        
        navigationItem.title = "Posts"
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
    }
    
    private func fetchData(shouldReset: Bool = false) {
        self.viewModal.isLoading = true
        if shouldReset {
            viewModal.currentPage = 1
        } else {
            viewModal.currentPage += 1
        }
        viewModal.fetchPosts(query: [URLQueryItem(name: "page", value: String(viewModal.currentPage))])
    }
    
    private func observe() {
        viewModal.$error.receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error = error else {return}
                self?.loadingIndicator.stopAnimating()
                self?.collectionView.refreshControl?.endRefreshing()
                self?.bottomLoadingIndicator.stopAnimating()
                self?.showToast(message: error, attachTo: .top)
            }.store(in: &garbageBag)
        
        viewModal.$posts.receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                guard let _ = posts else {return}
                self?.loadingIndicator.stopAnimating()
                self?.collectionView.refreshControl?.endRefreshing()
                self?.bottomLoadingIndicator.stopAnimating()
                self?.collectionView.reloadData()
            }.store(in: &garbageBag)
    }
    
    private func handleEvents(event: EventPublisher) {
        switch event {
        case .PostColViewCellArrowTappedEvent(let post):
            navigateToDetailScreen(post: post)
        case .PostDetailVCFavouriteTappedEvent(let post):
            for index in 0..<(viewModal.posts?.count ?? 0) {
                if viewModal.posts?[index].id == post.id {
                    self.viewModal.posts?[index].isFavorite = post.isFavorite
                    break
                }
            }
        }
    }
    
    @objc private func refresher() {
        fetchData(shouldReset: true)
    }
    
    private func navigateToDetailScreen(post: Post) {
        let vc = PostDetailVC.instantiate(storyBoardName: StorybordName.main.rawValue)
        vc.post = post
        vc.eventPublisher.sink { [weak self] event in
            self?.handleEvents(event: event)
        }.store(in: &garbageBag)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom(identifier: .small, resolver: { context in
                    let font = UIFont.boldSystemFont(ofSize: 20.0)
                    let decsFont = UIFont.systemFont(ofSize: 18.0)
                    let padding = 94.0
                    let labelWidth = self.view.frame.width * 0.9
                    let titleHeight = post.title.height(withConstrainedWidth: labelWidth, font: font)
                    let bodyHeight = post.body.height(withConstrainedWidth: labelWidth, font: decsFont)
                    return titleHeight + bodyHeight + padding
                })
            ]
            sheet.preferredCornerRadius = 24
            sheet.prefersGrabberVisible = true
        }
        // Presenting vc modally
        self.present(vc, animated: true, completion: nil)
    }
}

extension PostsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func settingCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = generateLayout()
        
        refreshControl.addTarget(self, action: #selector(refresher), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        collectionView.register(UINib(nibName: PostColViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PostColViewCell.reuseIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModal.posts?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostColViewCell.reuseIdentifier, for: indexPath) as! PostColViewCell
        if let post = viewModal.posts?[indexPath.row] {
            cell.viewModal = .init(post: post)
            cell.eventPublisher.receive(on: DispatchQueue.main)
                .sink { [weak self] event in
                    self?.handleEvents(event: event)
                }.store(in: &cell.garbageBag)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            collectionView.cellForItem(at: indexPath)?.transform = .init(scaleX: 0.94, y: 0.94)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            collectionView.cellForItem(at: indexPath)?.transform = .identity
        }
    }
    
    // Dynamic Sizing
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
                                                            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            return self.estimatedHeightLayout()
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        layout.configuration = config
        
        return layout
    }
    
    private func estimatedHeightLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        section.decorationItems.removeAll()
        section.interGroupSpacing = 0
        
        return section
    }
}

// MARK: - Pagination
extension PostsVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - scrollView.frame.size.height
        
        if offsetY > (contentHeight) && !viewModal.isLoading && viewModal.currentPage < viewModal.totalPages {
            // Load more data
            self.bottomLoadingIndicator.startAnimating()
            fetchData()
        }
    }
}
