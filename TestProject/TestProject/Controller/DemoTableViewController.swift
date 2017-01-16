//
//  DemoTableViewController.swift
//  TestCollectionView
//
//  Created by Alex K. on 24/05/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit

import expanding_collection

class DemoTableViewController: ExpandingTableViewController {
    
    private var scrollOffsetY: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        let image1 = UIImage(named: "BackgroundImage")
        tableView.backgroundView = UIImageView(image: image1)
    }
}
// MARK: Helpers

extension DemoTableViewController {
    
    private func configureNavBar() {
        navigationItem.leftBarButtonItem?.image = navigationItem.leftBarButtonItem?.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        navigationItem.rightBarButtonItem?.image = navigationItem.rightBarButtonItem?.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    }
}

// MARK: Actions

extension DemoTableViewController {
    
    @IBAction func backButtonHandler(sender: AnyObject) {
        // buttonAnimation
//        let viewControllers: [DemoViewController?] = navigationController?.viewControllers.map { $0 as? DemoViewController } ?? []
//        
//        for viewController in viewControllers {
//            if let rightButton = viewController?.navigationItem.rightBarButtonItem as? AnimatingBarButton {
//                rightButton.animationSelected(false)
//            }
//        }
//        popTransitionAnimation()
    }
}

// MARK: UIScrollViewDelegate

extension DemoTableViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        scrollOffsetY = scrollView.contentOffset.y
    }
}
