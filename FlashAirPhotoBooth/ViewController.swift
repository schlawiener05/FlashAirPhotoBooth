//
//  ViewController.swift
//  FlashAirPhotoBooth
//
//  Created by Janosch Achenbach on 7/2/15.
//  Copyright (c) 2015 Janosch Achenbach. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifier = "PhotoCell"
let albumName = "FlashAirPhotoAlbum"            //App specific folder name

class ViewController: UIViewController,UIPrintInteractionControllerDelegate {

    // maybe create selectable urls ?
    let baseURL:NSURL? = NSURL(string:"http://flashair.local/command.cgi?op=100&DIR=/DCIM/100__TSB")
    let url102:NSURL? = NSURL(string:"http://flashair.local/command.cgi?op=102")
    
    var status:Bool = false
    var pathArray : [String] = []
    
    var albumFound : Bool = false
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    var index: Int = 0

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var connectButton: UIBarButtonItem!
    @IBOutlet weak var printButton: UIBarButtonItem!

    @IBAction func btnConnect(sender: UIBarButtonItem) {
        
        if !self.status {
            
            self.title = "connected"
            self.connectButton.title="disconnect"
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                self.checkUpdate()
            })
            
            //                self.camButton.enabled=false
        }else {
            self.status=false
            self.title = "disconnected"
            self.connectButton.title="connect"
        }
        
        
    }
    @IBAction func btnPrint(sender: AnyObject) {
        
        let controler:UIPrintInteractionController = UIPrintInteractionController.sharedPrintController()!
        var dictionary = NSDictionary()
        var printInfo:UIPrintInfo = UIPrintInfo(dictionary:dictionary as [NSObject : AnyObject])
        controler.printingItem = self.imgView.image
        printInfo.outputType = UIPrintInfoOutputType.Photo
        controler.delegate = self
        controler.showsPageRange = false
        controler.showsNumberOfCopies = false
        controler.presentFromBarButtonItem(self.printButton, animated:false){
            controller, completed, error in
            if (completed && error != nil) {
                println("FAILED! due to error in domain %@ with error code %u", error.domain, error.code)
            }else {
                println("printed")
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        println("check for album")
        self.checkAlbum()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true
        
        //        self.displayPhoto()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showAlbumAction(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("showAlbum", sender: self)
        
        
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        
        if(segue.identifier  == "showAlbum"){
            
            self.checkAlbum()
            
            let controller:AlbumViewController = segue.destinationViewController as! AlbumViewController
            //let indexPath: NSIndexPath = self.collectionView.indexPathForCell(sender as! UICollectionViewCell)!
            //controller.index = indexPath.item
            controller.photosAsset = self.photosAsset
            controller.assetCollection = self.assetCollection
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
    
    
    
    func checkUpdate(){
        
        self.status=true
        
//        var sts:String?
        var counter = 0
        var errorcounter = 0
        
        println("try to connect")
        
        //var req: NSURLRequest?=nil;
        
        
        while(self.status){
            
            //println("now in loop")
             println("loop:\(counter++) ")
            
            //sts = NSString(contentsOfURL: self.url102!, encoding: NSUTF8StringEncoding, error: &myerror) as! String?
            //sts = String(contentsOfURL: self.url102!, encoding: NSUTF8StringEncoding, error: &myerror)
            var myerror:NSError?
            var resp: NSURLResponse?
            let req = NSURLRequest(URL: self.url102!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 10)
            
            // Sending Synchronous request using NSURLConnection
            
            let responseData = NSURLConnection.sendSynchronousRequest(req,returningResponse: &resp, error: &myerror)

            if let error = myerror {
                
                println("request error: \(error.localizedDescription)")
                errorcounter+=1
                if errorcounter == 5 {
                    self.title="SD-Card not reachable, please reconnect."
                    self.status=false
                    self.connectButton.title="reconnect"
                }
            }
            else
            {
                errorcounter=0
                //Converting data to String
                let sts = NSString(data:responseData!, encoding:NSUTF8StringEncoding) as! String?
                
                if let i = sts?.toInt(){
                    
                    if i == 1 {
                        println(i)
                        //dispatch_async(dispatch_get_main_queue(), {
                            
                            //self.activityIndicatorView.startAnimating()
                            self.fetchFileList()
                            println("fetched pathList")
                            
                            self.downloadCurrentImage()
                            println("download image pathList")
                            
                            //                        self.title = "got new images"
                            //self.activityIndicatorView.stopAnimating()
                            
                            
                            
                        //    return
                        //})
                        
                    }
                }
                
            }
            
            
            
            NSThread.sleepForTimeInterval(1.0)
            
        }
        
        
    }
    
    func fetchFileList(){
        
        var txt:NSString = NSString(contentsOfURL: self.baseURL!, encoding: NSUTF8StringEncoding, error: nil)!
        //println(txt)
        //var pathArray :[String] = txt.componentsSeparatedByString( "\r\n") as! [String]
       
        self.pathArray = txt.componentsSeparatedByString( "\r\n") as! [String]
        
        
    }
    
    func getLastImagePath()-> String{
        
        var lastString: String = self.pathArray[self.pathArray.count-2]
        
        var components:[String] = lastString.componentsSeparatedByString( ",") as [String]
        
        var dir:String = components[0]
        println(dir)
        var filename: String = components[1]
        println(filename)
        //self.title=filename
        
        //var path: String = "http://flashair.local/thumbnail.cgi?"+dir+"/"+filename
        
        var path: String = "http://flashair.local"+dir+"/"+filename
        println(path)
        
        return path
        
    }
    
    func downloadCurrentImage(){
        
        var path = getLastImagePath()
        var lastImageUrl:NSURL = NSURL(string: path)!
        
        var imgData:NSData = NSData(contentsOfURL: lastImageUrl)!
        var img: UIImage = UIImage(data: imgData)!
        
        dispatch_async(dispatch_get_main_queue(), {
            self.imgView.image = img
            return
        })
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0), {
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(img)
                let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection, assets: self.photosAsset)
                
                albumChangeRequest.addAssets([assetPlaceholder])
                }, completionHandler: {(success, error)in
                    dispatch_async(dispatch_get_main_queue(), {
                        NSLog("Adding Image to Library -> %@", (success ? "Sucess":"Error!"))
                        //picker.dismissViewControllerAnimated(true, completion: nil)
                    })
            })
            
        })
        
        
        
        
        
        
        //add to second screen
        ////        self.mirroredControler?.setImage(img)
        //self.mirroredControler?.addImage(img)
        
    }
    

}

