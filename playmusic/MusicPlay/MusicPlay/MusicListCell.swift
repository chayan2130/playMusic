//
//  MusicListCell.swift
//  MusicPlay
//
//  Created by User on 5/22/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

class MusicListCell: UITableViewCell {

    @IBOutlet weak var labelMusicTitle: UILabel!
    @IBOutlet weak var labelMusicDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
