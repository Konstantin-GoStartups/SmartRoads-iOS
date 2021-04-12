//
//  VideoSettingsViewController.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 11.04.21.
//

import UIKit

class VideoSettingsViewController: UIViewController {
    @IBOutlet weak var videoResolutionLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    @IBOutlet weak var resolutionDropDown: DropDownMenu!
    @IBOutlet weak var fpsDropDown: DropDownMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDropDowns()
        // Do any additional setup after loading the view.
    }
    
    private func setupDropDowns() {
        resolutionDropDown.optionArray = ["1920x1440", "1200x800", "192x256"]
        //Its Id Values and its optional
        resolutionDropDown.optionIds = [1,2,3,4]

        // The the Closure returns Selected Index and String
        resolutionDropDown.didSelect{(selectedText , index ,id) in
            self.resolutionDropDown.text = selectedText
        }
        
        fpsDropDown.optionArray = ["60", "30", "15"]
        //Its Id Values and its optional
        fpsDropDown.optionIds = [5,6,7,8]

        // The the Closure returns Selected Index and String
        fpsDropDown.didSelect{(selectedText , index ,id) in
            self.fpsDropDown.text = selectedText
        }
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
