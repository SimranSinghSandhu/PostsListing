//
//  PostsVC.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 01/05/24.
//

import UIKit
import Combine
import CoreData

class PostsVC: LoadingIndicatorViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModal = PostsVM()
    var garbageBag = Set<AnyCancellable>()
    
    var viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        settingCollectionView()
        observe()
        fetchData(shouldReset: true)
        
        navigationItem.title = "Posts"
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        
        if let fetchedPosts = fetchPostsFromCoreData() {
            self.viewModal.posts = mapPostEntityToPost(postEntities: fetchedPosts)
            print("Count =", fetchedPosts.count)
        }
    }
    
    // Listening to instances created in ViewModal
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
                guard let posts = posts else {return}
                self?.loadingIndicator.stopAnimating()
                self?.collectionView.refreshControl?.endRefreshing()
                self?.bottomLoadingIndicator.stopAnimating()
                self?.collectionView.reloadData()
                
                self?.savingData(posts: posts)
            }.store(in: &garbageBag)
    }
    
    // Handling events for communication from differenct screens
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

    // Mapping the fetched posts from CoreData to other class, so we can show it in the collectionView
    func mapPostEntityToPost(postEntities: [PostEntity]) -> [Post] {
        return postEntities.map { postEntity in
            return Post(id: Int(postEntity.id), title: postEntity.title ?? "", body: postEntity.body ?? "")
        }
    }
    
    // Fetching Posts from server
    private func fetchData(shouldReset: Bool = false) {
        self.viewModal.isLoading = true
        if shouldReset { // If fetching first time, or using refreshControl to refresh the data
            viewModal.currentPage = 1
        } else { // If using with Pagination
            viewModal.currentPage += 1
        }
        viewModal.fetchPosts(query: [URLQueryItem(name: "page", value: String(viewModal.currentPage))])
    }
    
    // Will be called when user scrolls the collectionView down
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

// MARK: - Collection View Delegate and Datasource Methods
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

// MARK: - CoreData
extension PostsVC {
    
    // Saving data inside coredata after fetching it from the API
    private func savingData(posts: [Post]) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        deleteAllPostsFromCoreData()
        for post in posts {
            let postManagedObject = post.managedObject(context: viewContext)
            // Handle any additional operations or validations
        }
        
        appDelegate.saveContext() // Save changes
    }
    
    // Before saving the new data, removing the previous, so we wont have any duplicates
    func deleteAllPostsFromCoreData() {
        
        let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        
        do {
            let posts = try viewContext.fetch(fetchRequest)
            for post in posts {
                viewContext.delete(post)
            }
            try viewContext.save()
        } catch let error {
            print("Error deleting posts: \(error.localizedDescription)")
        }
    }
    
    // Fetching Posts from CoreData
    func fetchPostsFromCoreData() -> [PostEntity]? {
        let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true) // Use the appropriate key
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let posts = try viewContext.fetch(fetchRequest)
            return posts
        } catch let error {
            print("Error fetching posts: \(error.localizedDescription)")
            return nil
        }
    }
}
