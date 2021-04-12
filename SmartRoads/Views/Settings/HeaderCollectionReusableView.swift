//
//  HeaderCollectionReusableView.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 9.04.21.
//

import UIKit

protocol WillExpandOrColapseDelegate {
    func willExpandOrColapse(from: HeaderCollectionReusableView, in section: Int)
}

class HeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hideButton: UIButton!
    var delegate: WillExpandOrColapseDelegate?
    var section: Int?

    @IBAction func didTapHide(_ sender: Any) {
        delegate?.willExpandOrColapse(from: self, in: section ?? 0)
    }
}
