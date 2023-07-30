

import UIKit

let herbs = HerbModel.all()

class ViewController: UIViewController {
  @IBOutlet var listView: UIScrollView!
  @IBOutlet var bgImage: UIImageView!
  var selectedImage: UIImageView?
  var transition = PopAnimator()
  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if listView.subviews.count < herbs.count {
      while let view = listView.viewWithTag(0) {
        view.tag = 1000 // prevent confusion when looking up images
      }
      setupList()
    }
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate { _ in
      self.bgImage.alpha = size.width > size.height ? 0.25 : 0.55
      self.positionListItems()
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: View setup

  // add all images to the list
  func setupList() {
    for i in herbs.indices {
      // create image view
      let imageView = UIImageView(image: UIImage(named: herbs[i].image))
      imageView.tag = i
      imageView.contentMode = .scaleAspectFill
      imageView.isUserInteractionEnabled = true
      imageView.layer.cornerRadius = 20.0
      imageView.layer.masksToBounds = true
      listView.addSubview(imageView)

      // attach tap detector
      imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageView)))
    }

    listView.backgroundColor = UIColor.clear
    positionListItems()
  }

  // position all images inside the list
  func positionListItems() {
    let listHeight = listView.frame.height
    let itemHeight: CGFloat = listHeight * 1.33
    let aspectRatio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
    let itemWidth: CGFloat = itemHeight / aspectRatio

    let horizontalPadding: CGFloat = 10.0

    for i in herbs.indices {
      guard let imageView = listView.viewWithTag(i) as? UIImageView else { continue }
      imageView.frame = CGRect(
        x: CGFloat(i) * itemWidth + CGFloat(i + 1) * horizontalPadding,
        y: 0.0,
        width: itemWidth,
        height: itemHeight)
    }

    listView.contentSize = CGSize(
      width: CGFloat(herbs.count) * (itemWidth + horizontalPadding) + horizontalPadding,
      height: 0)
  }

  // MARK: Actions

  @objc func didTapImageView(_ tap: UITapGestureRecognizer) {
    selectedImage = tap.view as? UIImageView

    guard let index = selectedImage?.tag else { return }
    let selectedHerb = herbs[index]

    // present details view controller
    guard let herbDetails = storyboard?.instantiateViewController(
      identifier: "HerbDetailsViewController", creator: { coder in
        HerbDetailsViewController(coder: coder, herb: selectedHerb)
      }) else {
      return
    }
    herbDetails.modalPresentationStyle = .popover
    herbDetails.transitioningDelegate = self
    present(herbDetails, animated: true, completion: nil)
  }
}

extension ViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    guard let selectedImage else {
      return nil
    }
    transition.originFrame = selectedImage.convert(selectedImage.bounds, to: nil)
    transition.presenting = true
    selectedImage.isHidden = true
    return transition
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.presenting = false
    transition.dismissCompletion = {
      self.selectedImage?.isHidden = false
    }
    return transition
  }
}
