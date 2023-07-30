

import UIKit

final class MainViewController: UIViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var yearLabel: UILabel!
  @IBOutlet weak var hostLabel: UILabel!
  @IBOutlet weak var medalCountButton: UIButton!
  @IBOutlet weak var logoImageView: UIImageView!

  // MARK: - Properties
  lazy var slideInTransitioningDelegate = SlideInPresentationManager()
  private let dataStore = GamesDataStore()
  private var presentedGames: Games? {
    didSet {
      configurePresentedGames()
    }
  }

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    presentedGames = nil
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let controller = segue.destination as? GamesTableViewController {
      if segue.identifier == "SummerSegue" {
        controller.gamesArray = dataStore.allGames.summer
        slideInTransitioningDelegate.direction = .left
      } else if segue.identifier == "WinterSegue" {
        controller.gamesArray = dataStore.allGames.winter
        slideInTransitioningDelegate.direction = .right
      }
      controller.delegate = self
      controller.transitioningDelegate = slideInTransitioningDelegate
      controller.modalPresentationStyle = .custom
      slideInTransitioningDelegate.disableCompactHeight = false
    } else if let controller = segue.destination as? MedalCountViewController {
      controller.medalWinners = presentedGames?.medalWinners
      slideInTransitioningDelegate.direction = .bottom
      controller.transitioningDelegate = slideInTransitioningDelegate
      controller.modalPresentationStyle = .custom
      slideInTransitioningDelegate.disableCompactHeight = true
    }
  }
}

// MARK: - Private
private extension MainViewController {
  func configurePresentedGames() {
    guard let presentedGames = presentedGames else {
      logoImageView.image = UIImage(named: "medals")
      hostLabel.text = nil
      yearLabel.text = nil
      medalCountButton.isHidden = true
      return
    }

    logoImageView.image = UIImage(named: presentedGames.flagImageName)
    hostLabel.text = presentedGames.host
    yearLabel.text = presentedGames.seasonYear
    medalCountButton.isHidden = false
  }
}

// MARK: - GamesTableViewControllerDelegate
extension MainViewController: GamesTableViewControllerDelegate {
  func gamesTableViewController(controller: GamesTableViewController, didSelectGames selectedGames: Games) {
    presentedGames = selectedGames
    dismiss(animated: true)
  }
}
