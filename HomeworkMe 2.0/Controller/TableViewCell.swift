//
//  TableViewCell.swift
//  eventApp2
//
//  Created by Radiance Okuzor on 12/7/18.
//  Copyright © 2018 RayCo. All rights reserved.
//

import UIKit
import Firebase

class TableViewCell: UITableViewCell {

    @IBOutlet weak var getHelpImage: UIImageView!
    @IBOutlet weak var getHelpPostTitle: UILabel!
    @IBOutlet weak var getHelpPostAuthr: UILabel!
    @IBOutlet weak var getHelpPostTime: UILabel!
    @IBOutlet weak var giveHelpImage: UIImageView!
    @IBOutlet weak var givetHelpPostTitle: UILabel!
    @IBOutlet weak var giveHelpPostAuthr: UILabel!
    @IBOutlet weak var giveHelpPostTime: UILabel!
//    @IBOutlet weak var postMenuBtn: UIButton!
    
    var giveHelpPicData: Data!
    
    var giveHelpPost: Post! {
        didSet {
//            self.postText.numberOfLines = 0
            self.updateGiveHelpUI()
        }
    }
    
    
    func updateGiveHelpUI() {
        self.givetHelpPostTitle.text = giveHelpPost.title
        self.giveHelpPostTime.text = giveHelpPost.timeSince
        self.giveHelpPostAuthr.text = giveHelpPost.authorName
        
        if let imageDownloadURL = giveHelpPost.picUrl {
            let imageStorageRef = Storage.storage().reference(forURL: imageDownloadURL)
            imageStorageRef.getData(maxSize: 2 * 1024 * 1024) { [weak self] (data, error) in
                if let error = error {
                    print("******** \(error)")
                } else {
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            self?.giveHelpImage.image = image
                        }
                    }
                }

            }
        }
        if let imageDownloadURL = giveHelpPost.picUrl {
            let imageStorageRef = Storage.storage().reference(forURL: imageDownloadURL)
            imageStorageRef.getData(maxSize: 2 * 1024 * 1024) { [weak self] (data, error) in
                if let error = error {
                    print("******** \(error)")
                } else {
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            self?.giveHelpImage.image = image
                            self?.giveHelpPicData = data 
                            self?.editImage(image: self!.giveHelpImage)
                        }
                    }
                }
                
            }
        }
    }
    
    var getHelpPicData: Data!
    
    var getHelpPost: Post! {
        didSet {
            //            self.postText.numberOfLines = 0
            self.updateGetHelpUI()
        }
    }
    
    
    func updateGetHelpUI() {
        self.getHelpPostTitle.text = getHelpPost.title
        self.getHelpPostTime.text = getHelpPost.timeSince
        self.getHelpPostAuthr.text = getHelpPost.authorName
        
        //        if let imageDownloadURL = giveHelpPost.picUrl {
        //            let imageStorageRef = Storage.storage().reference(forURL: imageDownloadURL)
        //            imageStorageRef.getData(maxSize: 2 * 1024 * 1024) { [weak self] (data, error) in
        //                if let error = error {
        //                    print("******** \(error)")
        //                } else {
        //                    if let imageData = data {
        //                        let image = UIImage(data: imageData)
        //                        DispatchQueue.main.async {
        //                            self?.getHelpImage.image = image
        //                        }
        //                    }
        //                }
        //
        //            }
        //        }
        if let imageDownloadURL = getHelpPost.picUrl {
            let imageStorageRef = Storage.storage().reference(forURL: imageDownloadURL)
            imageStorageRef.getData(maxSize: 2 * 1024 * 1024) { [weak self] (data, error) in
                if let error = error {
                    print("******** \(error)")
                } else {
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            self?.getHelpImage.image = image
                            self?.getHelpPicData = data
                            self?.editImage(image: self!.getHelpImage)
                        }
                    }
                }
                
            }
        }
    }
    
    func editImage(image:UIImageView){
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
    }
 
}
