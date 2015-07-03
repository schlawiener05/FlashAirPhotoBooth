//
//  PhotoThumbnail.swift
//  FlashAirPhotoBooth
//
//  Created by Janosch Achenbach on 7/3/15.
//  Copyright (c) 2015 Janosch Achenbach. All rights reserved.
//

import UIKit

class PhotoThumbnail: UICollectionViewCell {
    
    
    @IBOutlet weak var imgView: UIImageView!
    
    func setThumbnailImage(thumbnailImage: UIImage){
        self.imgView.image = thumbnailImage
    }
    
}
