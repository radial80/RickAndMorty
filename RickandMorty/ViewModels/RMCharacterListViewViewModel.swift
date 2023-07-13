import UIKit

protocol RMCharacterListViewViewModelDelegate: AnyObject {
    func didLoadInitialCharacters()
    func didSelectCharacter(_ character: RMCharacter)
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
                cellViewModels.append(viewModel)
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

    public func fetchAdditionalCharacters() {

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
        guard shouldShowLoadMoreIndicator, !isLoadingMore else {
            return
        }
        let offSet = scrollView.contentOffset.y
        let totalContentHeight = scrollView.contentSize.height
        let totalScrollViewFixedHeight = scrollView.frame.size.height

        if offSet >= (totalContentHeight - totalScrollViewFixedHeight) {

            counter += 1
            if counter >= 2 {
                print("Should Start Fetching Data")
                isLoadingMore = true
            }
            //        print("offSet:  \(offSet)")
            //        print("totalContentHeight:  \(totalContentHeight)")
            //        print("totalScrollViewFixedHeight:  \(totalScrollViewFixedHeight)")
        }
    }
}
