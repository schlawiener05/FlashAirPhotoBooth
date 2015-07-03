//
//  PhotoViewController.swift
//  FlashAirPhotoBooth
//
//  Created by Janosch Achenbach on 7/3/15.
//  Copyright (c) 2015 Janosch Achenbach. All rights reserved.
//

import UIKit
import Photos

class PhotoViewController: UIViewController {

    
    var albumFound : Bool = false
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    var index: Int = 0
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true    //!!Added Optional Chaining
        
        self.displayPhoto()
    }
    
    func displayPhoto(){
        // Set targetSize of image to iPhone screen size
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let targetSize = CGSizeMake(screenSize.width, screenSize.height)
        self.imgView.sizeToFit()
        let imageManager = PHImageManager.defaultManager()
        var ID = imageManager.requestImageForAsset(self.photosAsset[self.index] as! PHAsset, targetSize: targetSize, contentMode: .AspectFit, options: nil, resultHandler: {
            (result, info)->Void in
            self.imgView.image = result
        })
    }

}
