//
//  VIdeoCollectionViewController.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 1.04.21.
//

import UIKit
import AVFoundation
import RealmSwift

class VideoCollectionViewController: UIViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var result = [SensorDataWrapper()]
    var fetchedFileURLs = [URL]()
    var sortedData = [SensorDataWrapper()]
    var isArrayEmpty: Bool {
        return result.isEmpty
    }
    
    var documentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileManager = FileManager.default
    let reuseIdentifier: String = "videoCellIndentifier"
    let segue = "toVideoDetailsController"
    let backgroundRealm = LocalDataManager.backgroundRealm
    let refreshControl = UIRefreshControl()
    var row = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Data ...", attributes: nil)
        navigationController?.navigationBar.topItem?.title = "Recordings"
        refreshData((Any).self)
        //createJSON()
        // Do any additional setup after loading the view.
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Weather Data
        let objects = backgroundRealm.objects(SensorDataWrapper.self).sorted(byKeyPath: "id", ascending: false)
        result.removeAll()
        sortedData.removeAll()
        fetchedFileURLs.removeAll()
        for object in objects {
            result.append(object)
//            print(object.depthVideoURL)
//            print(object.rgbVideoURL)
//            print(object.startDate)
//            print(object.endDate)
//            for data in object.sensorDataList {
//                print(data)
//            }
        }
        if !isArrayEmpty {
            //fetchURLsFromFileManager()
        }
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func createJSON() {
        try! backgroundRealm.write {
            let predicate = NSPredicate(format: "uuid = %@", "2021/04/01-06/45-Biznes-park-Sofia-Sofia" as CVarArg)
            let object = backgroundRealm.objects(SensorDataWrapper.self).filter(predicate).first
            if object?.uuid ==  "2021/04/01-06/45-Biznes-park-Sofia-Sofia" {
                let url = LocalDataManager.shared.getDocumentsDirectory().appendingPathComponent("JSON-\(object!.uuid).json")
                let dict2 = object!.toDictionary2()
                let data = try! (dict2 as Dictionary).toJson()
                try! data.description.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
    
    private func fetchURLsFromFileManager() {
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: documentsDirectory.absoluteURL, includingPropertiesForKeys: nil, options: [])
            for directory in directoryContents {
                if directory.isDirectory {
                    let urls = try fileManager.contentsOfDirectory(at: directory.absoluteURL, includingPropertiesForKeys: nil)
                    for url in urls {
                        fetchedFileURLs.append(url)
                    }
                }
            }
            for url in fetchedFileURLs {
                print(url)
            }
            
//            for wrapper in result {
//                let rgbURL = URL(fileURLWithPath: wrapper.rgbVideoURL)
//                let depthURL = URL(fileURLWithPath: wrapper.depthVideoURL)
//                for url in fetchedFileURLs {
//                    try backgroundRealm.write {
//                        if rgbURL.lastPathComponent.contains(url.lastPathComponent) {
//                            wrapper.rgbVideoURL = url.absoluteString
//                        }
//                        if depthURL.lastPathComponent.contains(url.lastPathComponent) {
//                            wrapper.depthVideoURL = url.absoluteString
//                        }
//                    }
//                }
//                self.sortedData.append(wrapper)
//            }
//            tableView.reloadData()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? VideoDetailsViewController {
            destination.dataWrapper   = result[row]
        }
    }

}

extension VideoCollectionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if result.count > 0 {
            return result.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isArrayEmpty{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? VideoTableViewCell else { return UITableViewCell() }
            
            let sensorDataWrapper = result[indexPath.row]
            cell.durationLabel.text = "Duration: 4:26:13"
            let rgbURL = URL(fileURLWithPath: sensorDataWrapper.rgbVideoURL)
            let depthURL = URL(fileURLWithPath: sensorDataWrapper.depthVideoURL)
            rgbURL.startAccessingSecurityScopedResource()
            let name = rgbURL.lastPathComponent
            cell.nameLabel.text = name
            cell.durationLabel.text = Helper.calculateDurationforVideoAt(rgbURL)
            let rgbSize = Helper.calculateSizeOfObjectAt(rgbURL)
            let depthSize = Helper.calculateSizeOfObjectAt(depthURL)
            cell.sizeLabel.text = "RGB: \(rgbSize) Depth: \(depthSize)"
            cell.sizeLabel.adjustsFontSizeToFitWidth = true
            if let thumbnailImage = rgbURL.generateThumbnail() {
                cell.thumbnailImageView.image = thumbnailImage
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicIdentifier")!
            cell.textLabel?.text = "No videos to show"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        row = indexPath.row
        if !isArrayEmpty {
            self.performSegue(withIdentifier: segue, sender: nil)
        }
    }
}
