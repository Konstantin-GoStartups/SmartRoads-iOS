//
//  DeveloperModeViewController.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 11.04.21.
//

import UIKit

class DeveloperModeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dimensionalArray = [ExpandableCellItems(isExpanded: true, items: ["GPS recipient lost","IMU wrong signal"]),
        ExpandableCellItems(isExpanded: true, items: ["None for now"])]
    var kind: String = ""

    private enum Constans {
        static let developerCellIdentifier      = "developerCellIdentifier"
        static let developerHeaderIndentifier   = "headerIdentifier"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        // Do any additional setup after loading the view.
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
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

extension DeveloperModeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dimensionalArray[section].isExpanded == false {
            return 0
        }
        return dimensionalArray[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constans.developerCellIdentifier, for: indexPath) as! DeveloperModeCollectionViewCell
        let message = dimensionalArray[indexPath.section].items[indexPath.item]
        cell.errorLabel.text = message
        cell.timeLabel.text = "10:00"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constans.developerHeaderIndentifier, for: indexPath) as! HeaderCollectionReusableView
        self.kind = kind
        headerView.backgroundColor = .white
        headerView.section = indexPath.section
        headerView.delegate = self
        headerView.titleLabel.clipsToBounds = false
        switch dimensionalArray[indexPath.section].isExpanded {
        case true:
            headerView.hideButton.setTitle("Hide", for: .normal)
        case false:
            headerView.hideButton.setTitle("Show", for: .normal)
        }
        switch indexPath.section {
        case 0:
            headerView.titleLabel.text = "Error Log"
        case 1:
            headerView.titleLabel.text = "Other functions"
        default:
            break
        }
        return headerView
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width , height: 120)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 12
//    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    
}

extension DeveloperModeViewController: WillExpandOrColapseDelegate {
    func willExpandOrColapse(from: HeaderCollectionReusableView,in section: Int) {
        let headerView = self.collectionView(self.collectionView, viewForSupplementaryElementOfKind: kind, at: IndexPath(row: 0, section: section)) as! HeaderCollectionReusableView
        var indexPaths = [IndexPath]()
        for row in dimensionalArray[section].items.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        let isExpanded = !dimensionalArray[section].isExpanded
        dimensionalArray[section].isExpanded = isExpanded
        print("is expanded -> \(isExpanded)")
        if isExpanded {
            headerView.hideButton.setTitle("Hide", for: .normal)
            NSLog("CHANGED BUTTON LABEL - > HIDE")
        }  else {
            headerView.hideButton.setTitle("Show", for: .normal)
            NSLog("CHANGED BUTTON LABEL - > SHOW")
        }
        collectionView.reloadSections([section])
    }

    func indexPathsAreValid(indexPaths: [IndexPath]) -> Bool {
        for indexPath in indexPaths {
            if indexPath.section >= numberOfSections(in: self.collectionView) {
                return false
            }
            if indexPath.row >= collectionView.numberOfItems(inSection: indexPath.section) {
                return false
            }
        }
        return true
    }
}
