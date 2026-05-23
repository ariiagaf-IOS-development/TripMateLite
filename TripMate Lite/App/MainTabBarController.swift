//
//  MainTabBarController.swift
//  TripMate Lite
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    private enum Layout {
        static let plusIconSize: CGFloat = 26
        static let tabIconSize: CGFloat = 20
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        setupTabs()
        setupTabBarAppearance()
        setupNotifications()
    }
    
    private func setupTabs() {
        let tripsListViewController = TripsListViewController()
        let tripsNavigationController = UINavigationController(
            rootViewController: tripsListViewController
        )
        
        let homeConfig = UIImage.SymbolConfiguration(
            pointSize: Layout.tabIconSize,
            weight: .semibold
        )
        
        let homeImage = UIImage(
            systemName: "airplane",
            withConfiguration: homeConfig
        )
        
        let homeSelectedImage = UIImage(
            systemName: "airplane.circle.fill",
            withConfiguration: homeConfig
        )
        
        tripsNavigationController.tabBarItem = UITabBarItem(
            title: nil,
            image: homeImage,
            selectedImage: homeSelectedImage
        )
        
        tripsNavigationController.tabBarItem.imageInsets = UIEdgeInsets(
            top: 6,
            left: 0,
            bottom: -6,
            right: 0
        )
        
        let plusConfig = UIImage.SymbolConfiguration(
            pointSize: Layout.plusIconSize,
            weight: .semibold
        )
        
        let plusImage = UIImage(
            systemName: "plus.circle.fill",
            withConfiguration: plusConfig
        )
        
        let addPlaceholderViewController = UIViewController()
        addPlaceholderViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: plusImage,
            selectedImage: plusImage
        )
        
        addPlaceholderViewController.tabBarItem.imageInsets = UIEdgeInsets(
            top: 4,
            left: 0,
            bottom: -4,
            right: 0
        )
        
        let infoViewController = InfoViewController()
        let infoNavigationController = UINavigationController(
            rootViewController: infoViewController
        )
        
        let infoImage = UIImage(
            systemName: "info.circle",
            withConfiguration: homeConfig
        )
        
        let infoSelectedImage = UIImage(
            systemName: "info.circle.fill",
            withConfiguration: homeConfig
        )
        
        infoNavigationController.tabBarItem = UITabBarItem(
            title: nil,
            image: infoImage,
            selectedImage: infoSelectedImage
        )
        
        infoNavigationController.tabBarItem.imageInsets = UIEdgeInsets(
            top: 6,
            left: 0,
            bottom: -6,
            right: 0
        )
        
        viewControllers = [
            tripsNavigationController,
            addPlaceholderViewController,
            infoNavigationController
        ]
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        appearance.shadowColor = UIColor.systemGray5.withAlphaComponent(0.7)
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .secondaryLabel
        tabBar.isTranslucent = true
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openAddTripFromNotification),
            name: .openAddTrip,
            object: nil
        )
    }

    @objc private func openAddTripFromNotification() {
        openAddTripScreen()
    }
    
    func openAddTripScreen() {
        let addTripViewController = AddTripViewController()
        
        addTripViewController.onTripCreated = { [weak self] trip in
            TripStorage.shared.saveTrip(trip)
            
            self?.selectedIndex = 0
            
            if let navigationController = self?.viewControllers?.first as? UINavigationController,
               let tripsListViewController = navigationController.viewControllers.first as? TripsListViewController {
                tripsListViewController.loadTrips()
            }
        }
        
        let navigationController = UINavigationController(
            rootViewController: addTripViewController
        )
        
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        
        if index == 1 {
            openAddTripScreen()
            return false
        }
        
        return true
    }
}
