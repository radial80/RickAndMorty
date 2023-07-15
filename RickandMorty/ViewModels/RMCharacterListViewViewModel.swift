import UIKit

protocol RMCharacterListViewViewModelDelegate: AnyObject {
    func didLoadInitialCharacters()
    func didSelectCharacter(_ character: RMCharacter)
    func didLoadMoreCharacters(with newIndexPath: [IndexPath])
}

final class RMCharacterListViewViewModel: NSObject {

    public weak var delegate: RMCharacterListViewViewModelDelegate?

    private var isLoadingMore = false

    private var counter = 0


    private var characters: [RMCharacter] = [] {
        didSet {
            for character in characters {
                let viewModel = RMCharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatus: character.status,
                    characterImageURL: URL(string: character.image)
                )
                if !cellViewModels.contains(viewModel) {
                    cellViewModels.append(viewModel)
                }
            }
        }
    }

    private var cellViewModels: [RMCharacterCollectionViewCellViewModel] = []
    private var apiinfo: RMGetAllCharactersResponse.Info? = nil

    public func fetchCharacters () {
        
        RMService.shared.execute(.listCharactersRequest, expecting: RMGetAllCharactersResponse.self) { [weak self] result in
            switch result {
                case .success(let responseModel):
                    let results = responseModel.results
                    let info = responseModel.info
                    self?.characters = results
                    self?.apiinfo = info
                    DispatchQueue.main.async {
                        self?.delegate?.didLoadInitialCharacters()
                    }
                case .failure(let error):
                    print(String(describing: error))
            }
        }
    }

    public func fetchAdditionalCharacters(url: URL)  {
        guard !isLoadingMore else {
            return
        }
        isLoadingMore = true
        guard let request = RMRequest(url: url) else {
            isLoadingMore = false
             return
        }
        RMService.shared.execute(request,
                                expecting: RMGetAllCharactersResponse.self) {[weak self] result in
            guard let Strongself = self else {
                return }
            switch result {
                case .success(let responseModel):
                    let moreResult = responseModel.results
                    let info = responseModel.info
                    Strongself.apiinfo = info
                    let originalCount = Strongself.characters.count
                    let newCount = moreResult.count
                    let total = originalCount+newCount
                    let startigIndex = total - newCount
                    let indexPathsToAdd: [IndexPath] = Array(startigIndex..<(startigIndex+newCount)).compactMap({
                        return IndexPath(row: $0, section:0)
                    })

                    Strongself.characters.append(contentsOf: moreResult)
                    DispatchQueue.main.async {
                        Strongself.delegate?.didLoadMoreCharacters(with: indexPathsToAdd)
                        Strongself.isLoadingMore = false
                    }
                case .failure(let failure):
                    print(String(describing: failure))
                    self?.isLoadingMore = false
            }
        }
    }

    public var shouldShowLoadMoreIndicator: Bool {
        return apiinfo?.next != nil
    }
}
    


// MARK: - CollectionView Implementation

extension RMCharacterListViewViewModel: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier,
        for: indexPath
        ) as? RMCharacterCollectionViewCell else {
            fatalError("unsupported cell")
        }

        cell.configure(with: cellViewModels[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier,
                for: indexPath
            )as? RMFooterLoadingCollectionReusableView
            else {
                fatalError("Unsupported")

            }
            footer.startAnimating()
            return footer
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        guard shouldShowLoadMoreIndicator else {
            return .zero

        }
        return CGSize(width: collectionView.frame.width, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width-30)/2
        return CGSize(
            width: width,
            height: width*1.5)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let character = characters[indexPath.row]
        delegate?.didSelectCharacter(character)
    }
}

// MARK: ScrollView Implementation

extension RMCharacterListViewViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndicator,
              !isLoadingMore,
              !cellViewModels.isEmpty,
              let nextURLString = apiinfo?.next,
              let url = URL(string: nextURLString)
        else {
            return
        }
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            let offSet = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height

            if offSet >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                self?.fetchAdditionalCharacters(url: url)
//                self!.counter += 1
//                if self!.counter >= 70 {
//                    print("Should Start Fetching Data")
//                    self?.fetchAdditionalCharacters(url: url)
//                    self?.isLoadingMore = true
//                }
                t.invalidate()
                //        print("offSet:  \(offSet)")
                //        print("totalContentHeight:  \(totalContentHeight)")
                //        print("totalScrollViewFixedHeight:  \(totalScrollViewFixedHeight)")
            }
        }
    }
}
