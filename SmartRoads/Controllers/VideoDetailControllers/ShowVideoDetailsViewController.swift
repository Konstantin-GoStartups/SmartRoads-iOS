//
//  ShowVideoDetailsViewController.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 1.04.21.
//

import UIKit
import AVFoundation
import AVKit

class ShowVideoDetailsViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var kmsCoveredLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var framesLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    var path: String?
    var isRGB: Bool = false
    var player = AVPlayer()
    var playerViewControlller = AVPlayerViewController()
    var sensorDataWrapper: SensorDataWrapper?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Video Details"
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        if isRGB {
            path = sensorDataWrapper?.rgbVideoURL
        } else {
            path = sensorDataWrapper?.depthVideoURL
        }
        setupView()
    }
    private func setupView() {
        guard let urlPath = path, let dataWrapper = sensorDataWrapper else { return }
        let url = URL(fileURLWithPath: urlPath)
        nameLabel.text = url.lastPathComponent
        let lastComponent =  Array(url.lastPathComponent)
        if isRGB {
            dateLabel.text = String(lastComponent[4..<20])
        } else {
            dateLabel.text = String(lastComponent[6..<22])
        }
        locationLabel.text = "Location: \(dataWrapper.city), \(dataWrapper.country)"
        kmsCoveredLabel.text = "Kms covered: ???"
        framesLabel.text = "No. frames: \(dataWrapper.sensorDataList.count)"
        durationLabel.text = "Duration: \(Helper.calculateDurationforVideoAt(url))"
        fileSizeLabel.text = "File size: \(Helper.calculateSizeOfObjectAt(url))"
        if let thumbmnailImage = url.generateThumbnail() {
            self.imageView.image = thumbmnailImage
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        playerViewControlller.player = player
        self.present(playerViewControlller, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
