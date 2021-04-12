//
//  ViddeoDetailsViewController.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 1.04.21.
//

import UIKit

class VideoDetailsViewController: UIPageViewController {
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    var pages = [UIStoryboard.main.instantiateViewController(identifier: "ShowVideoDetailsViewController"),
                 UIStoryboard.main.instantiateViewController(identifier: "ShowVideoDetailsViewController")]
    var dataWrapper: SensorDataWrapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.blue
        self.pages = setupControllers()
        self.dataSource = self
        self.setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }
    
    private func setupControllers() -> [UIViewController] {
        var viewControllerPages = [UIViewController]()
        for index in 0 ..< pages.count {
            guard let showDetailsViewController = pages[index] as? ShowVideoDetailsViewController else { return pages }
            showDetailsViewController.isRGB = index == 0
            showDetailsViewController.sensorDataWrapper = dataWrapper
            viewControllerPages.append(showDetailsViewController)
        }
        return viewControllerPages
    }
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let object = dataWrapper else { return }
        let rgbVideoUrl = URL(fileURLWithPath: object.rgbVideoURL)
        let depthVideoUrl = URL(fileURLWithPath: object.depthVideoURL)
        let jsonUrl = URL(fileURLWithPath: object.jsonFileURL!)
        depthVideoUrl.startAccessingSecurityScopedResource()
        rgbVideoUrl.startAccessingSecurityScopedResource()
        jsonUrl.startAccessingSecurityScopedResource()
        sendActivity(urls: [depthVideoUrl, rgbVideoUrl, jsonUrl])
    }
    
    private func sendActivity(urls: [URL]){
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(activityItems: urls, applicationActivities: [])
            activityViewController.popoverPresentationController?.barButtonItem = self.shareBarButton
            //UIApplication.topViewController?.present(activityViewController, animated: true, completion: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}

extension VideoDetailsViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let currentIndex = self.pages.firstIndex(of: viewController) else {
            return nil
        }

       guard currentIndex > 0 else {
           return nil
       }

       return self.pages[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let currentIndex = self.pages.firstIndex(of: viewController) else {
            return nil
        }

        guard currentIndex < self.pages.count - 1 else {
            return nil
        }

        return self.pages[currentIndex + 1]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let controllerIndex = self.pages.firstIndex(of: pageViewController) else {
                return 0
        }

        return controllerIndex
    }
}
