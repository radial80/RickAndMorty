

import UIKit

/// Controller to show and search for Character
final class RMCharacterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Characters"

        let request = RMRequest(
            endPoint: .character,
            querryParameters: [
                URLQueryItem(name: "name", value: "rick"),
                URLQueryItem(name: "status", value: "alive")

            ]

        )

        print(request.url )
        RMService.shared.execute(request, expecting: RMCharacter.self) { result in

            }

        }
    } 
