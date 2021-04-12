//
//  SettingsViewController.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 9.04.21.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logInButton: UIButton!
    
    private enum Constants {
        static let userCellIdentifier       = "userCellIdentifier"
        static let normalCellIdenfier       = "normalCellIdentifier"
        static let developerModeSegue       = "developerModeSegue"
        static let systemSettingsSegue      = "systemSettingSegue"
        static let uploadPreferencesSegue   = "uploadPreferencesSegue"
        static let resolutionFpsSegue       = "resolutionFPSsegue"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupLoginButton()
        // Do any additional setup after loading the view.
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    private func setupLoginButton() {
        //logic for log in and sign out
    }
    

    @IBAction func didTapLoginOrSingOut(_ sender: Any) {
        
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

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.userCellIdentifier) as? UserTableViewCell else {
                return UITableViewCell()
            }
            cell.userName.text = "Konstantin"
            cell.title.text = "Developer"
            cell.imageView?.image = UIImage(named: "earth-rise")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.normalCellIdenfier)!
            cell.textLabel?.text = "Developer mode"
            cell.detailTextLabel?.text = "Error log, disable functions"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.normalCellIdenfier)!
            cell.textLabel?.text = "System"
            cell.detailTextLabel?.text = "Time and date, language"
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.normalCellIdenfier)!
            cell.textLabel?.text = "Upload preferences"
            cell.detailTextLabel?.text = "Wifi, preferred networks"
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.normalCellIdenfier)!
            cell.textLabel?.text = "Video options"
            cell.detailTextLabel?.text = "Resolution, frames per second"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        switch row {
        case 1:
            self.performSegue(withIdentifier: Constants.developerModeSegue, sender: nil)
        case 2:
            self.performSegue(withIdentifier: Constants.systemSettingsSegue, sender: nil)
        case 3:
            self.performSegue(withIdentifier: Constants.uploadPreferencesSegue, sender: nil)
        case 4:
            self.performSegue(withIdentifier: Constants.resolutionFpsSegue, sender: nil)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 100
        default:
            return 60
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
}
