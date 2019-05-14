//
//  TabbarController.swift
//  BDOTabbar
//
//  Created by Srikanth on 24/04/19.
//  Copyright © 2019 Srikanth. All rights reserved.
//

import UIKit

protocol PayTabProtocol: class {
    func scanToPay() -> Void
    func importQRFromPhotos() -> Void
    func sendMoney() -> Void

}

protocol RequestTabProtocol: class {
    func requestViaQR() -> Void
    func requestMoney() -> Void
}




class TabbarController: UIViewController {

    private let tabbar = UITabBar()
    private var tabbar_height_Constraint: NSLayoutConstraint!
    
    weak var payTabDelegate: PayTabProtocol?
    weak var requestTabDelegate: RequestTabProtocol?

    private var tabbarHeight: CGFloat = 50
    private var transperentBgView: UIView!
    private var tempTableViewObject: SelfSizedTableView!

    
    private var viewSize: CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - (bottomSafeArea + tabbarHeight))
    }
    
    private lazy var moreController: UIViewController = {
        let moreController = UIViewController()
        moreController.view.backgroundColor = UIColor.red
        return moreController
    }()
    
    private lazy var tableView: SelfSizedTableView = {
        let tableView = SelfSizedTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.estimatedRowHeight = 60 + bottomSafeArea/2.5
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60 + bottomSafeArea/2.5
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    
    private lazy var subMenuItems: [[(title: String, imageName: String)]] = [
        [(title: String, imageName: String)](),
        [(title: "Sub List Item-> 1", imageName: "q"), (title: "Sub List Item-> 2", imageName: "q"), (title: "Sub List Item", imageName: "se")],
        [(title: "Sub List Item", imageName: "q"), (title: "Sub List Item", imageName: "q")],
        [(title: String, imageName: String)]()
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabbar.delegate = self
        tabbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabbar)
        
        
        let tabBarItems = [UITabBarItem(title: "Home", image: UIImage(named: "h") , tag: 0),
                           UITabBarItem(title: "Pay", image: UIImage(named: "q") , tag: 1),
                           UITabBarItem(title: "Request", image: UIImage(named: "r") , tag: 2),
                           UITabBarItem(title: "More", image: UIImage(named: "m") , tag: 3)]
        
        tabbar.setItems(tabBarItems, animated: true)
        tabbar.selectedItem = tabBarItems.first
        
        
        tabbar_height_Constraint = tabbar.heightAnchor.constraint(equalToConstant: tabbarHeight)
        
        let containerContraint = [
            
            tabbar_height_Constraint!,
            tabbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(containerContraint)
        
    }
    
    private var bottomSafeArea: CGFloat = 0
    
    private func updateBottomLayoutIfNeeded() {
        
        var newBottomSafeArea: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            newBottomSafeArea = view.safeAreaInsets.bottom
        } else {
            newBottomSafeArea = bottomLayoutGuide.length
        }
        
        guard newBottomSafeArea != bottomSafeArea else { return }
        
        bottomSafeArea = newBottomSafeArea
        tabbar_height_Constraint.constant = bottomSafeArea + tabbarHeight
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateBottomLayoutIfNeeded()
        
        //        tabbar.frame = CGRect(x: 0, y: view.frame.maxY - 50, width: view.frame.width, height: 50)
    }
    
    private var previousSelectedIndex: Int = 0
    private var isSubMenuAnimating = false
}

extension TabbarController: UITabBarDelegate {
    
    func tabbarWillSelect( _ item: UITabBarItem, at index: Int) -> Bool {
        return true
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    
        guard let index = tabbar.items?.firstIndex(of: item),
            tabbarWillSelect(item, at: index) else { return }
        guard previousSelectedIndex != index else { return }

        if index == 3 {
            hideSubMenu(selected: index)
            displayMoreController()
        } else {
            
            hideMoreController()
            
            if index == 0 {
                hideSubMenu(selected: index)
            } else {
                previousSelectedIndex = index
                showSubMenuForTabBarItem(at: index)
            }
        }
        
        previousSelectedIndex = index

    }
    
    
}

//MARK: - Sub Menu Extention
private extension TabbarController {
    
    func showSubMenuForTabBarItem(at index: Int) {
        
        guard !isSubMenuAnimating else {
            return
        }
        isSubMenuAnimating = true
        
        if transperentBgView == nil {
        transperentBgView = UIView(frame: CGRect(origin: .zero, size: viewSize))
        transperentBgView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        transperentBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideSubMenu)))
        transperentBgView.alpha = 0.0
        
        view.insertSubview(transperentBgView, belowSubview: tabbar)
        }
        
        
        
        if tempTableViewObject == nil {
            tempTableViewObject = tableView

            tempTableViewObject.frame = CGRect(origin: CGPoint(x: 0, y: viewSize.height),
                                               size: CGSize(width: viewSize.width, height: self.tempTableViewObject.intrinsicContentSize.height))
            view.insertSubview(tempTableViewObject, belowSubview: tabbar)
        }
        
        tableView.reloadData()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.transperentBgView.alpha = 1.0
            self.tempTableViewObject.frame = CGRect(origin: CGPoint(x: 0, y: self.viewSize.height - self.tempTableViewObject.intrinsicContentSize.height + 0.5), size: self.tempTableViewObject.intrinsicContentSize)

        }) { (isFinished) in

            self.isSubMenuAnimating = false
        }
    }
    
    @objc func hideSubMenu(selected index: Int) {
        
        guard !isSubMenuAnimating else { return }
        guard transperentBgView != nil else { return }
        
        isSubMenuAnimating = true

        
        UIView.animate(withDuration: 0.25, animations: {
            self.transperentBgView.alpha = 0.35
            self.tempTableViewObject.frame.origin = CGPoint(x: 0, y: self.viewSize.height)

        }) { (isFinished) in
            
            self.resetToDefaults(selected: index)
            self.tempTableViewObject.removeFromSuperview()
            UIView.animate(withDuration: 0.15, animations: {
                
                self.transperentBgView.alpha = 0.0
                
            }, completion: { (isFinished) in
                
                self.transperentBgView = nil
                self.tempTableViewObject = nil
                self.isSubMenuAnimating = false

            })
            
        }
    }
    
    
    
    func resetToDefaults(selected index: Int) {
        
        guard index != 3 else { return }
        tabbar.selectedItem = tabbar.items?.first
        previousSelectedIndex = 0
    }
}

//MARK: - Morecontroller Extention
private extension TabbarController {
    
    func displayMoreController() {
        addChild(moreController)
        moreController.view.frame = CGRect(origin: CGPoint(x: view.frame.maxX, y: 0), size: viewSize)
        self.view.addSubview(moreController.view)
        self.view.insertSubview(moreController.view, belowSubview: tabbar)
        moreController.didMove(toParent: self)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.moreController.view.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
        }) { (isFinished) in
            self.title = "More"
        }
    }
    
    func hideMoreController() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.moreController.view.transform = CGAffineTransform.identity
            
        }) { (isFinished) in
            
            self.title = "BDO Pay"
            
            self.moreController.willMove(toParent: nil)
            self.moreController.view.removeFromSuperview()
            self.moreController.removeFromParent()
        }
    }
    
}

extension TabbarController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subMenuItems[previousSelectedIndex].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        guard !subMenuItems[previousSelectedIndex].isEmpty else { return cell }
        
        let obj = subMenuItems[previousSelectedIndex][indexPath.row]
        
        cell.imageView?.image = UIImage(named: obj.imageName)
        cell.imageView?.image = UIImage(named: obj.imageName)

        cell.textLabel?.text =  obj.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch previousSelectedIndex {
        case 1:
            
            switch indexPath.row {
                case 0: payTabDelegate?.scanToPay()
                case 2: payTabDelegate?.importQRFromPhotos()
                case 3: payTabDelegate?.sendMoney()
                default: break
            }
        case 2:
            
            switch indexPath.row {
                case 0: requestTabDelegate?.requestViaQR()
                case 2: requestTabDelegate?.requestMoney()
                default: break
            }
            
        default: break
        }

         hideSubMenu(selected: previousSelectedIndex)
    }
    
}



private class SelfSizedTableView: UITableView {
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        var frame = self.frame
        frame.size.height = self.contentSize.height
        return frame.size
    }
}
