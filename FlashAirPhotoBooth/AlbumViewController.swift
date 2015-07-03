//
//  AlbumViewController.swift
//  FlashAirPhotoBooth
//
//  Created by Janosch Achenbach on 7/2/15.
//  Copyright (c) 2015 Janosch Achenbach. All rights reserved.
//

import UIKit
import Photos

class AlbumViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    var albumFound : Bool = false
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    var index: Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        //self.navigationController?.hidesBarsOnTap = true    //!!Added Optional Chaining
        
        //self.checkAlbum()
    }
    
    
    //UICollectionViewDataSource Methods
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        var count: Int = 0
        if(self.photosAsset != nil){
            count = self.photosAsset.count
        }
        return count;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell: PhotoThumbnail = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoThumbnail
        
        //Modify the cell
        let asset: PHAsset = self.photosAsset[indexPath.item] as! PHAsset
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: nil, resultHandler: {(result, info)in
            cell.setThumbnailImage(result)
        })
        
        return cell
    }
    
    
    
    
    //UICollectionViewDelegateFlowLayout methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 4
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "viewLargePhoto"){
            if let controller:PhotoViewController = segue.destinationViewController as? PhotoViewController{
                if let cell = sender as? UICollectionViewCell{
                    
                    if let indexPath: NSIndexPath = self.collectionView?.indexPathForCell(cell){
                        controller.index = indexPath.item
                        controller.photosAsset = self.photosAsset
                        controller.assetCollection = self.assetCollection
                    }
                }
            }
        }
    }
    
    func checkAlbum(){
        
        //Check if the folder exists, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if((collection.firstObject) != nil){
            
            NSLog("\nFolder \(albumName) found!..")
            //found the album
            self.albumFound = true
            self.assetCollection = collection.firstObject as! PHAssetCollection
            self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
            self.index = self.photosAsset.indexOfObject(self.photosAsset.lastObject)
            
        }else{
            
            var albumPlaceholder:PHObjectPlaceholder!
            //create the folder
            NSLog("\nFolder \"%@\" does not exist\nCreating now...", albumName)
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName)
                albumPlaceholder = request.placeholderForCreatedAssetCollection
                },
                completionHandler: {(success:Bool, error:NSError!)in
                    if(success){
                        println("Successfully created folder")
                        self.albumFound = true
                        if let collection = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([albumPlaceholder.localIdentifier], options: nil){
                            self.assetCollection = collection.firstObject as! PHAssetCollection
                        }
                    }else{
                        println("Error creating folder:")
                        println(error.description)
                        self.albumFound = false
                    }
            })
            
            
        }
        
        
    }

}
