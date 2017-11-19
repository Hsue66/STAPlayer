//
//  VideoTableViewCell.swift
//  SimpleSTAPlayer
//
//  Created by Sumin Hong on 2017. 11. 7..
//  Copyright © 2017년 Sumin Hong. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var VideoImage: UIImageView!
    @IBOutlet weak var VideoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
