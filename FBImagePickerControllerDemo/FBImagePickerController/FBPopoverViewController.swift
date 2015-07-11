//
//  FBPopoverViewController.swift
//  FBImagePickerControllerDemo
//
//  Created by ZhangAo on 15/6/27.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

class FBPopoverViewController: UIViewController {
    
    class func popoverViewController(viewController: UIViewController, fromView: UIView) {
        let window = UIApplication.sharedApplication().keyWindow!
        
        let popoverViewController = FBPopoverViewController()
        
        popoverViewController.contentViewController = viewController
        popoverViewController.fromView = fromView
        
        popoverViewController.showInView(window)
        window.rootViewController!.addChildViewController(popoverViewController)
    }
    
    class func dismissPopoverViewController() {
        let window = UIApplication.sharedApplication().keyWindow!

        for vc in window.rootViewController!.childViewControllers {
            if vc is FBPopoverViewController {
                (vc as! FBPopoverViewController).dismiss()
            }
        }
    }
    
    class FBPopoverView: UIView {
        
        var contentView: UIView! {
            didSet {
                contentView.layer.cornerRadius = 5
                contentView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                self.addSubview(contentView)
            }
        }
        
        let arrowWidth: CGFloat = 20
        let arrowHeight: CGFloat = 10
        private let arrowImageView: UIImageView = UIImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.commonInit()
        }

        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            self.commonInit()
        }
        
        func commonInit() {
            arrowImageView.image = self.arrowImage()
            self.addSubview(arrowImageView)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.arrowImageView.frame = CGRect(x: (self.bounds.width - self.arrowWidth) / 2, y: 0, width: arrowWidth, height: arrowHeight)
            self.contentView.frame = CGRect(x: 0, y: self.arrowHeight, width: self.bounds.width, height: self.bounds.height - arrowHeight)
        }
        
        func arrowImage() -> UIImage {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: arrowWidth, height: arrowHeight), false, UIScreen.mainScreen().scale)
            
            let context = UIGraphicsGetCurrentContext()
            UIColor.clearColor().setFill()
            CGContextFillRect(context, CGRect(x: 0, y: 0, width: arrowWidth, height: arrowHeight))
            
            var arrowPath = CGPathCreateMutable()
            
            CGPathMoveToPoint(arrowPath, nil,  arrowWidth / 2, 0)
            CGPathAddLineToPoint(arrowPath, nil, arrowWidth, arrowHeight)
            CGPathAddLineToPoint(arrowPath, nil, 0, arrowHeight)
            CGPathCloseSubpath(arrowPath)

            CGContextAddPath(context, arrowPath)
            
            CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
            CGContextDrawPath(context, kCGPathFill)

            let arrowImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return arrowImage
        }
        
    }
    
    var contentViewController: UIViewController!
    var fromView: UIView!
    private let popoverView = FBPopoverView()
    private var popoverViewHeight: CGFloat!
    
    override func loadView() {
        super.loadView()
        
        let backgroundView = UIControl(frame: self.view.frame)
        backgroundView.backgroundColor = UIColor(white: 0.4, alpha: 0.2)
        backgroundView.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        backgroundView.autoresizingMask = self.view.autoresizingMask
        self.view = backgroundView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(popoverView)
    }

#if iOSVersionMinRequired8
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        let popoverY = self.fromView.convertPoint(self.fromView.frame.origin, toView: self.view).y + self.fromView.bounds.height

        self.popoverViewHeight = min(self.contentViewController.preferredContentSize.height + self.popoverView.arrowHeight, self.view.bounds.height - popoverY - 40)
        
        coordinator.animateAlongsideTransition({ context in
                self.popoverView.frame = CGRect(x: 6, y: popoverY,
                    width: size.width - 12, height: self.popoverViewHeight)
            }, completion: { context in
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.popoverView.frame.origin.y = self.fromView.convertPoint(self.fromView.frame.origin, toView: self.view).y + self.fromView.bounds.height
                    
                })
                
        })
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

#else
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
            super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        let popoverY = self.fromView.convertPoint(self.fromView.frame.origin, toView: self.view).y + self.fromView.bounds.height
        self.popoverViewHeight = min(self.contentViewController.preferredContentSize.height + self.popoverView.arrowHeight, self.view.bounds.height - popoverY - 40)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.popoverView.frame = CGRect(x: 6, y: popoverY,
                width: self.view.bounds.width - 12, height: self.popoverViewHeight)
        })
        
    }

#endif
    
    func showInView(view: UIView) {
        let popoverY = self.fromView.convertPoint(self.fromView.frame.origin, toView: view).y + self.fromView.bounds.height
        self.popoverViewHeight = min(self.contentViewController.preferredContentSize.height + self.popoverView.arrowHeight, view.bounds.height - popoverY - 40)
        
        self.popoverView.frame = CGRect(x: 6, y: popoverY,
            width: view.bounds.width - 12, height: popoverViewHeight)
        self.popoverView.contentView = self.contentViewController.view
        
        view.addSubview(self.view)
        
        self.popoverView.transform = CGAffineTransformScale(CGAffineTransformTranslate(self.popoverView.transform, 0, -(self.popoverViewHeight / 2)), 0.1, 0.1)
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.3, options: .CurveEaseInOut, animations: { () -> Void in
            self.popoverView.transform = CGAffineTransformIdentity
        }, completion: nil)
    }
    
    func dismiss() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.popoverView.transform = CGAffineTransformScale(CGAffineTransformTranslate(self.popoverView.transform, 0, -(self.popoverViewHeight / 2)), 0.01, 0.01)
            self.view.backgroundColor = UIColor.clearColor()
        }) { (result) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
}
