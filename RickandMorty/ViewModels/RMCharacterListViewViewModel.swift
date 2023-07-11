import UIKit

final class RMCharacterListViewViewModel: NSObject {

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

    public func fetchCharacters () {
        
        RMService.shared.execute(.listCharactersRequest, expecting: RMGetAllCharactersResponse.self) { [weak self] result in
            switch result {
                case .success(let responseModel):
                    let results = responseModel.results
                    self?.characters = results
                case .failure(let error):
                    print(String(describing: error))
            }
        }
    }
}

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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width-30)/2
        return CGSize(
            width: width,
            height: width*1.5)
    }
}
