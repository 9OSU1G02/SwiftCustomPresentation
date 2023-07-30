

import UIKit

class SlideInPresentationController: UIPresentationController {
  private var direction: PresentationDirection
  private var dimmingView: UIView!
  init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, direction: PresentationDirection) {
    self.direction = direction
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    setupDimmingView()
  }

  override func presentationTransitionWillBegin() {
    print("presentationTransitionWillBegin")
    guard let containerView, let dimmingView else { return }
    containerView.insertSubview(dimmingView, at: 0)
    dimmingView.frame = containerView.bounds
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 1.0
      return
    }
    coordinator.animate { _ in
      dimmingView.alpha = 1.0
    } completion: { _ in
      
    }
  }

  override func dismissalTransitionWillBegin() {
    print("dismissalTransitionWillBegin")
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 0.0
      return
    }
    coordinator.animate { _ in
      self.dimmingView.alpha = 0
    } completion: { _ in
      
    }
  }

  override func containerViewWillLayoutSubviews() {
    print("containerViewWillLayoutSubviews")
    presentedView?.frame = frameOfPresentedViewInContainerView
  }

  override var frameOfPresentedViewInContainerView: CGRect {
    print("frameOfPresentedViewInContainerView")
    var frame: CGRect = .zero
    frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
    switch direction {
    case .right:
      frame.origin.x = containerView!.frame.width * (1.0/3.0)
    case .bottom:
      frame.origin.y = containerView!.frame.height * (1.0/3.0)
    default:
      frame.origin = .zero
    }
    return frame
  }

  override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
    print("size(forChildContentContainer")
    switch direction {
    case .left, .right:
      return .init(width: parentSize.width * (2/3), height: parentSize.height)
    case .top, .bottom:
      return .init(width: parentSize.width, height: parentSize.height * (2/3))
    }
  }
}

// MARK: - Private

private extension SlideInPresentationController {
  func setupDimmingView() {
    dimmingView = UIView()
    dimmingView.tag = 1902
    dimmingView.translatesAutoresizingMaskIntoConstraints = false
    dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    dimmingView.alpha = 0.0
    let recognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(handleTap(recognizer:)))
    dimmingView.addGestureRecognizer(recognizer)
  }

  @objc func handleTap(recognizer: UITapGestureRecognizer) {
    presentingViewController.dismiss(animated: true)
  }
}
