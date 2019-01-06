//
//  Objects.swift
//  HomeworkMe 2.0
//
//  Created by Radiance Okuzor on 1/3/19.
//  Copyright © 2019 RayCo. All rights reserved.
//


import UIKit
import Firebase

class Student {
    var firstName: String?
    var lastName: String?
    var fullName: String?
    var email: String?
    var password: String?
    var school: [String]?
    var classes: [Classroom]?
    var meetUpLocations: [Place]?
    var customerId: String?
    var deviceNotificationTokern: String?
    var phoneNumber: Int?
    var status: Status?
    var uid: String?
    var paymentSource: [String:[String]]?
    var currLoc: Place?
    var hasCard: Bool?
    var notificationKey: String?
    var pictureUrl: String?
    var posts: [Post]?
    var profilepic: Data?
    var ratings: String?
    var endTime = Date()
    var isTutor = Bool()
    
    
    
//    var schedule: [String]! schedule a date with a tutor, tutor must accept ammend or reject.
//    var major: String!
//    var schoolEmail:String!
//    var requestsArrPending = [Request]()
//    var requestsArrAccepted = [Request]()
//    var requestsArrRejected = [Request]()
//    var requestsArrHistory = [Request]()
//    var requestsSentPending = [Request]()
//    var requestsSentApprd = [Request]()
//    var requestsSentReject = [Request]()
//    var request = Request()
//    var sentObject = [String:AnyObject]()
//    var receivedObject = [String:AnyObject]()
//    var coorLocCoord = String()
//    var coorLocName = String()
}

class Request {
    var place = Place()
    var reqID: String!
    var senderName: String!
    var senderId: String!
    var senderPhone: String!
    var senderPicUrl: String!
    var senderDevice: String!
    var senderCustomerId:String!
    
    var receiverPhoneNumber: String!
    var receiverCustomerId:String!
    var receiverName: String!
    var receiverId: String!
    var receiverPhone: String!
    var receiverPicUrl: String!
    var recieverDevice: String!
    var receiverPayment: [String]!
    var time: Date!
    var timeString: String!
    var postTite: String!
    var reqStatus: String!
    var sessionDidStart = false
    var endTimeStrn: String!
    var endTimeDte: Date!
    var endTimeToMeet: String!
    var endTimeToMeetDate: Date!
    var sessionPrice:Int!
}

enum Status {
    case off
    case on
}

enum Location {
    case startLocation
    case destinationLocation
}

class Classroom {
    var university: String?
    var subject: Subject?
    var students: [Student]?
    var teacher: String?
    var title: String?
    var createdBy: String?
    var uid: String?
}


class Post {
    var classs: Classroom?
    var author: Student?
    var subject: Subject?
    var title: String?
    var seller: Student?
    var buyer: Student?
    var timeStamp: Date?
    var uid: String?
    var category:String?
    var authorName: String?
    var authorEmail: String!
    var authorID: String?
    var price: Int!
    var data: Data!
    var postPic: String!
    var studentInClas: Bool!
    var schedule = [String]()
    var likers = [String]()
    var disLikers = [String]()
    var notes = [Note]()
    var noteDict = [String:String]()
    var phoneNumber = String()
    
    var caption: String!
    var downloadURL: String?
    var authorEmal: String!
    var authorFullName: String!
    var authorPicUrl: String!
    var postId: String!
    var postText: String!
    var timeStampDate: Date!
    var timeSince: String!
    var picUrl: String!
    var authId: String!
    
    var functions = CommonFunctions()
    
    var userStorage: StorageReference!
    private var image: UIImage!
    
    let storage = Storage.storage().reference(forURL: "gs://hmwrkme.appspot.com")
    let ref = Database.database().reference()
    
    init() {
        
    }
    
    init(image: UIImage, caption:String, authorEmail:String, authorFullName:String, authorPicUrl:String) {
        self.image = image
        self.caption = caption
        self.authorPicUrl = authorPicUrl
        self.authorFullName = authorFullName
        self.authorEmal = authorEmail
    }
    
    init(b:AnyObject) {
            if let fname = b["authorName"] as? String {
                self.authorName = fname
            } else {
                self.authorName = " "
            }
            if let uid = b["uid"] {
                self.uid = uid as? String
            }
            if let title = b["name"] {
                self.title = title as? String
            }
            if let authId = b["authorID"] {
                self.authorID = authId as? String
            } //postPic
        if let postPic = b["postPic"] {
            self.postPic = postPic as? String
        }
            if let authEmal = b["authorEmail"] {
                self.authorEmail = authEmal as? String
            }
            if let tmStmp = b["timeStamp"] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                let dat = dateFormatter.date(from: tmStmp as! String )
                self.timeSince = functions.getTimeSince(date: dat ?? Date())
                self.timeStamp = dat
            }
        if self.timeStamp == nil {
            self.timeStamp = Date()
        }
            if let catgry = b["category"] {
                self.category = catgry as? String
            }
            if let price = b["price"] {
                self.price = price as! Int
            } else {
                self.price = 0
            }
    }
    /*
    func save() {
        let storage = Storage.storage().reference(forURL: "gs://eventapp2-225e3.appspot.com")
        userStorage = storage.child("Posts")
        let newPostKey = Database.database().reference().child("Posts").childByAutoId().key
        let user = Auth.auth().currentUser
        let timeStamp = String(describing: Date())
        let imageRef = self.userStorage.child("\(newPostKey ?? "").jpg")
        let data = self.image!.jpegData(compressionQuality: 0.5)
        
        let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
            if err != nil {
            } else {
                
            }
            imageRef.downloadURL(completion: { (url, er) in
                if er != nil {
                    print(er!.localizedDescription)
                }
                if let url = url {
                    let params: [String:Any] = ["authorEmail": Auth.auth().currentUser?.email ?? "",
                                                "authId":Auth.auth().currentUser?.uid,
                                                "url":url.absoluteString,
                                                "authorPicUrl":self.authorPicUrl,
                                                "authorFullName":self.authorFullName!,
                                                "timeStamp":timeStamp,
                                                "postId":newPostKey!,
                                                "caption":self.caption]
                    self.ref.child("Users").child(user!.uid).child("MyPosts/\(newPostKey!)").updateChildValues(params)
                    self.ref.child("Posts/\(newPostKey!)").updateChildValues(params)
                }
            })
            
        })
        uploadTask.resume()
    }
 */
}

struct Place {
    var name: String!
    var long: String!
    var lat: String!
    var address: String!
}

struct Note {
    var note: String!
    var time: String!
    var author: String!
    var key: String!
}

struct Subject {
    var title:String?
    var classrooms: [Classroom]?
    var uid: String?
}

struct University {
    var title:String?
    var subjects: [Subject]?
    var uid: String?
}

struct FetchObject {
    var title: String?
    var uid: String?
    var dict: [String:AnyObject]?
    var subjectID: String?
    var subName:String!
    var uniID: String?
    var uniName: String?
    var Notification_Devices = [String]()
}

class CommonFunctions {
    func getTimeSince(date:Date) -> String {
        var calendar = NSCalendar.autoupdatingCurrent
        calendar.timeZone = NSTimeZone.system
        let components = calendar.dateComponents([ .month, .day, .minute, .hour, .second ], from: date, to: Date())
        //        let months = components.month
        let days = components.day
        let hours = components.hour
        let minutes = components.minute
        let secs = components.second
        var time:Int = days!; var measur:String = "Days ago"
        
        if days == 1 {
            measur = "Day ago"
        } else if days! < 1 {
            measur = "hours ago"
            time = hours!
            if hours == 1 {
                measur = "hour ago"
            } else if hours! < 1 {
                measur = "minutes ago"
                time = minutes!
                if minutes == 1 {
                    measur = "minute ago"
                } else if minutes! < 1 {
                    measur = "seconds ago"
                    time = secs!
                }
            }
        }
        return "\(time)\(measur)"
    }
    
    func editImage(image:UIImageView) -> UIImageView {
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
        
        return image
    }
}

extension UIImageView {
    
    func downloadImage(from imgURL: String!) {
        
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
            
        }
        
        task.resume()
    }
}
