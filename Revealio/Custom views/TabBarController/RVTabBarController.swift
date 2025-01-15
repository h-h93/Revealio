//
//  TabBarController.swift
//  Revealio
//
//  Created by hanif hussain on 01/12/2024.
//
import UIKit

class RVTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    private func configure() {
        delegate = self
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = .secondaryLabel
        viewControllers = [createHomeVCTab(), createChatsVCTab(), createLoginVCTab()]
    }
    
    
    private func createHomeVCTab() -> UINavigationController {
        let homeVC = HomeVC()
        homeVC.title = "Home"
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: Images.homeTabImage, tag: 0)
        return UINavigationController(rootViewController: homeVC)
    }
    
    
    private func createChatsVCTab() -> UINavigationController {
        let chatsVC = ChatsVC()
        chatsVC.title = "Chats"
        chatsVC.tabBarItem = UITabBarItem(title: "Chats", image: Images.chatTabImage, tag: 1)
        return UINavigationController(rootViewController: chatsVC)
    }
    
    
    private func createLoginVCTab() -> UINavigationController {
        let loginVC = LoginVC()
        loginVC.tabBarItem = UITabBarItem(title: "Login", image: Images.homeTabImage, tag: 2)
        return UINavigationController(rootViewController: loginVC)
    }
}
