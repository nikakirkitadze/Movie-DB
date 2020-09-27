//
//  ViewController.swift
//  Movie DB
//
//  Created by Nika Kirkitadze on 9/25/20.
//

import UIKit

protocol MainViewControllerDelegate: class {
    func openDetails(pass viewModel: TVShowViewModel)
}

class MainViewController: BaseViewController {
    
    // MARK: IBOutlets
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var viewModel = TVShowsViewModel()
    private var showViewModels = [TVShowViewModel]()
    private var isLoading = false
    private var hasNextPage = false
    private var paginated = true
    private var currentPage = 1
    private let paginationIndicatorInset: CGFloat = 25
    
    weak var delegate: MainViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.debug("INIT")
        
        configureCollectionView()
        configureViewModel()
        load(page: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isBackgroundHidden = false
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(class: TVShowCell.self)
    }
    
    private func configureViewModel() {
        viewModel.isRefreshing = { loading in
            UIApplication.shared.isNetworkActivityIndicatorVisible = loading
        }
    }
    
    func load(page: Int) {
        guard !isLoading else { return }
        isLoading = true
        hasNextPage = false
        
        // calls api
        viewModel.ready(for: page)
        
        // callbacks response
        viewModel.didFetchShowsData = { [weak self] shows in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false
            
            if shows.isEmpty {
                strongSelf.collectionView.contentInset.bottom = 50
            } else {
                strongSelf.hasNextPage = true
            }
            
            strongSelf.showViewModels.append(contentsOf: shows)
            DispatchQueue.main.async { strongSelf.collectionView.reloadData() }
        }
    }
}

// MARK: UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deque(TVShowCell.self, for: indexPath)
        cell.size = itemSize(cv: collectionView)
        cell.configure(with: showViewModels[indexPath.row])
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Taptic.light()
        delegate?.openDetails(pass: showViewModels[indexPath.row])
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize(cv: collectionView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard paginated else { return }
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        let height = scrollView.contentSize.height
        let reloadDistance: CGFloat = 10
        if y > height + reloadDistance && !isLoading && hasNextPage {
            let inset = tabBarController?.tabBar.frame.height ?? 0
            collectionView.contentInset.bottom = inset + paginationIndicatorInset
            
            let background = UIView(frame: collectionView.bounds)
            let indicator = UIActivityIndicatorView(style: .white)
            
            indicator.startAnimating()
            background.addSubview(indicator)
            
            indicator.center = background.center
            indicator.frame.origin.y = background.frame.height - indicator.frame.height - (inset + 20)
            
            collectionView.backgroundView = background
            
            // wait two seconds to simulate some work happening
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("Should reomve bottom spinner")
                // then remove the spinner view controller
                indicator.stopAnimating()
                //                background.removeFromSuperview()
            }
            
            currentPage += 1
            load(page: currentPage)
        }
    }
}
