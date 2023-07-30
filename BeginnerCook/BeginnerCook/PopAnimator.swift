//
//  PopAnimator.swift
//  BeginnerCook
//
//  Created by Quốc Huy Nguyễn on 7/30/23.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  let duration = 1.0
  var presenting = true
  var originFrame = CGRect.zero
  var dismissCompletion: (() -> Void)?
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    let herbDetailsViewController = (presenting ? transitionContext.viewController(forKey: .to) : transitionContext.viewController(forKey: .from)) as? HerbDetailsViewController
    let herbView = presenting ?
      transitionContext.view(forKey: .to) :
      transitionContext.view(forKey: .from)
    guard let herbView = herbView else {
      transitionContext.completeTransition(false)
      return
    }
    let initialFrame = presenting ? originFrame : herbView.frame
    let finalFrame = presenting ? herbView.frame : originFrame

    let xScaleFactor = presenting ?
      initialFrame.width / finalFrame.width :
      finalFrame.width / initialFrame.width

    let yScaleFactor = presenting ?
      initialFrame.height / finalFrame.height :
      finalFrame.height / initialFrame.height
    let scaleTransform = CGAffineTransform(
      scaleX: xScaleFactor,
      y: yScaleFactor)
    if presenting {
      herbView.layer.cornerRadius = 20.0 / xScaleFactor
      herbDetailsViewController?.containerView.alpha = .zero
      herbView.transform = scaleTransform
      herbView.center = CGPoint(
        x: initialFrame.midX,
        y: initialFrame.midY)
      herbView.clipsToBounds = true
    }

    // if present
    if let toView = transitionContext.view(forKey: .to) {
      containerView.addSubview(toView)
    }

    containerView.bringSubviewToFront(herbView)
    UIView.animate(
      withDuration: duration,
      delay: 0.0,
      usingSpringWithDamping: 0.4,
      initialSpringVelocity: 0.0,
      animations: {
        herbView.layer.cornerRadius = self.presenting ? 0.0 : 20.0 / xScaleFactor
        herbView.transform = self.presenting ?
          CGAffineTransform.identity : scaleTransform
        herbView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        herbDetailsViewController?.containerView.alpha = self.presenting ? 1 : 0
      },
      completion: { _ in
        if !self.presenting {
          self.dismissCompletion?()
        }
        transitionContext.completeTransition(true)
      })
  }
}
