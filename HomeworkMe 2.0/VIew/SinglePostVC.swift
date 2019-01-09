//
//  SinglePostVC.swift
//  HomeworkMe 2.0
//
//  Created by Radiance Okuzor on 1/7/19.
//  Copyright © 2019 RayCo. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class SinglePostVC: UIViewController {

    @IBOutlet weak var setUpMetngBtn: UIButton!
    @IBOutlet weak var callNowBtn: UIButton!
    @IBOutlet weak var sendAptReqBtn: UIButton!
    @IBOutlet weak var requestHelpBtn: UIButton!
    @IBOutlet weak var bkScrnView: UIView!
    @IBOutlet weak var callTutorView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var ratingsLbl: UILabel!
    @IBOutlet weak var firstAndLNameLbl: UILabel!
    @IBOutlet weak var postTitleLbl: UILabel!
    @IBOutlet weak var postPictureView: UIImageView!
    
    
    var fetchObject = Post()
    var postImage = UIImage()
    var tutor = Student()
    var userStorage: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storage = Storage.storage().reference(forURL: "gs://hmwrkme.appspot.com")
        userStorage = storage.child("Students")

        datePicker.minimumDate = Date()
        if postImage != nil {
            postPictureView.image = postImage
        }
        
        editImage(image: postPictureView)
        
        if fetchObject != nil {
            postTitleLbl.text = fetchObject.title
            firstAndLNameLbl.text = fetchObject.authorFullName
        }
        
        fetchTutor()
    }
    
    @IBAction func reqBtnPrsd(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.callTutorView.isHidden = false
            self.bkScrnView.isHidden = false
        }
    }
    
    @IBAction func sendAptReq(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.callTutorView.isHidden = true
            self.bkScrnView.isHidden = true
        }
        sendAptRequest()
    }
    
    @IBAction func setupMetingPrsd(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.datePicker.isHidden = false
            self.sendAptReqBtn.isHidden = false
            self.callNowBtn.isHidden = true
        }
    }
    
    @IBAction func callNow(_ sender: Any) {
        
    }
    
    func fetchTutor(){
        let ref = Database.database().reference()
        ref.child("Students").child(fetchObject.authorID ?? " ").queryOrderedByKey().observeSingleEvent(of: .value, with: { response in
            if response.value is NSNull {
            } else {
                let tutDict = response.value as! [String:AnyObject]
                if let did = tutDict["customerId"] as? String {
                    self.tutor.customerId = did
                }
                if let phn = tutDict["pictureUrl"] as? String {
                    self.tutor.pictureUrl = phn
                    self.tutor.profilepic = self.downloadImage(url: phn as! String)
                }
                if let status = tutDict["status"] as? String {
                    self.tutor.tutorStatus = status
                }
                if let fromDevice = tutDict["fromDevice"] as? String {
                    self.tutor.deviceNotificationTokern = fromDevice
                }
                if let paymentSource = tutDict["paymentSource"] as? [String] {
                    self.tutor.paymentSource = paymentSource
                }
                if let phn = tutDict["phoneNumber"] as? String {
                    self.tutor.phoneNumber = phn
                }
            }
        })
    }
    
    func sendAptRequest(){
        let ref = Database.database().reference()
        let postKey = ref.child("Requests").childByAutoId().key
        let dateString = String(describing: Date())
        let senderId = Auth.auth().currentUser!.uid
        
        let date = datePicker.date
        let scheduledDate = String(describing: date)
        
        if fetchObject.authorID != senderId {
            let parameters: [String:AnyObject] = ["senderId":senderId as AnyObject,
                                                  "receiverId":self.fetchObject.authorID as AnyObject,
                                                  "time":dateString as AnyObject,
                                                  "senderName":ProfileVC.student.fullName as AnyObject,
                                                  "receiverName":fetchObject.authorFullName as AnyObject,
                                                  "reqId":postKey as AnyObject,
                                                  "postTitle":self.fetchObject.title as AnyObject,
                                                  "senderPhone":ProfileVC.student.phoneNumber as AnyObject,
                                                  "receiverPhone":self.tutor.phoneNumber as AnyObject,
                                                  "receiverPic":self.tutor.pictureUrl as AnyObject,
                                                  "senderPic":ProfileVC.student.pictureUrl as AnyObject,
                                                  "status":"pending" as AnyObject,
                                                  "senderCustomerId":ProfileVC.student.customerId as AnyObject,
                                                  "receiverCustomerId":self.tutor.customerId as AnyObject,
                                                  "price":self.fetchObject.price as AnyObject,
                                                  "senderDevice":ProfileVC.student.deviceNotificationTokern as AnyObject,
                                                  "receiverDevice":self.tutor.deviceNotificationTokern as AnyObject,
                                                  "receiverPayment":tutor.paymentSource as AnyObject,
                                                  "aptDate":scheduledDate as AnyObject]
            let par = [postKey : parameters] as! [String: Any]
            ref.child("Students").child(Auth.auth().currentUser?.uid ?? "").child("sent").updateChildValues(par)
            ref.child("Students").child(self.fetchObject.authorID ?? "").child("received").updateChildValues(par)
            self.setupPushNotification(fromDevice: tutor.deviceNotificationTokern!, title: "HomeworkMe", body: "Congrats you got an appointment request \(ProfileVC.student.fullName ?? "")")
        } else {
            // you cant send a request to yourself.
            let alert = UIAlertController(title: "This is your post", message: "You can't book a post with yourself.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    fileprivate func setupPushNotification(fromDevice:String, title:String, body:String)
    {
        //        guard let message = "text.text" else {return}
        let toDeviceID = fromDevice
        var headers:HTTPHeaders = HTTPHeaders()
        
        headers = ["Content-Type":"application/json","Authorization":"key=\(AppDelegate.SERVERKEY)"
            
        ]
        let notification = ["to":"\(toDeviceID)","notification":["body":body,"title":title,"badge":1,"sound":"default"]] as [String:Any]
        
        Alamofire.request(AppDelegate.NOTIFICATION_URL as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            print(response)
        }
        
    }
    
    var storageRef: Storage {
        return Storage.storage()
    }
    
    func editImage(image:UIImageView){
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
    }
    
    func downloadImage(url:String) -> Data {
        var datas = Data()
        
        self.storageRef.reference(forURL: url).getData(maxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
            if error == nil {
                if let data = imgData{
                    self.postPictureView.image = UIImage(data: data)
                }
            }
            else {
                print(error?.localizedDescription)
            }
        })
        
        return datas
    }
}
