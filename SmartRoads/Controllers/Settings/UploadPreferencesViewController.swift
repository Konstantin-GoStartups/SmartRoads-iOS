//
//  UploadPreferencesViewController.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 11.04.21.
//

import UIKit

class UploadPreferencesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private enum Constants {
        static let wifiCellIndentifier      = "wifiCellIdentifier"
        static let cellularCellIdentifier   = "cellularCellIdentifier"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
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

extension UploadPreferencesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.wifiCellIndentifier, for: indexPath) as! WiFiUploadTableViewCell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellularCellIdentifier, for: indexPath) as! CellularUploadTableViewCell
            cell.cellularLabel.text = row == 3 ? "4G" : "5G"
            cell.checkBox.style = .tick
            cell.checkBox.backgroundColor = .lightGray
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
