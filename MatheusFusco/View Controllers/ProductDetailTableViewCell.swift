//
//  ProductDetailTableViewCell.swift
//  MatheusFusco
//
//  Created by Matheus Pacheco Fusco on 18/04/2018.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit

class ProductDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
