//
//  AppointmentsVC.swift
//  HomeworkMe 2.0
//
//  Created by Radiance Okuzor on 1/8/19.
//  Copyright © 2019 RayCo. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import UserNotifications

class AppointmentsVC: UIViewController {

    @IBOutlet weak var receivdAptsTable: UITableView!
    @IBOutlet weak var sentAptsTable: UITableView!
    @IBOutlet weak var requestersView: UIView!
    @IBOutlet weak var setScedulView: UIView!
    @IBOutlet weak var switchRequstBtn: UIButton!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var ratingsLbl: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var aptTime: UILabel!
    @IBOutlet weak var stackViewToHide: UIStackView!
    @IBOutlet weak var textCall: UIStackView!
    @IBOutlet weak var datePicker: UIDatePicker!

    
    let ref = Database.database().reference()
    var handle: DatabaseHandle?
    var receivedApts = Student()
    var sentApts = Student()
    var functions = CommonFunctions()
    var isSender: Bool?
    var userStorage: StorageReference!
    var request: Request!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = Date()
        let storage = Storage.storage().reference(forURL: "gs://hmwrkme.appspot.com")
        userStorage = storage.child("Students")
        // Do any additional setup after loading the view.
        fetchApts()
        editImage(image: profPic)
    }
    
    @IBAction func acceptApt(_ sender: Any) {
        acceptRequest()
        UIView.animate(withDuration: 0.5) {
            self.requestersView.isHidden = true
        }
    }
    
    
    @IBAction func rescdApt(_ sender: Any) {
        
        let alert = UIAlertController(title: "Reschedule Appointment", message: "Make sure to contact \(request.senderName ?? "") to agree on a time and date before setting a different schedule, otherwise they might cancel", preferredStyle: .alert)
        let text = UIAlertAction(title: "Text", style: .default) { (_) in
            //
        }
        
        let call = UIAlertAction(title: "Call", style: .default) { (_) in
            //
        }
        
        let setSchedule = UIAlertAction(title: "Set Schedule", style: .default) { (_) in
            self.setScedulView.isHidden = false
        }
        
        alert.addAction(text); alert.addAction(call); alert.addAction(setSchedule)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func setScdlDon(_ sender: Any) {
        self.setScedulView.isHidden = true
        let par = ["aptDate": String(describing: self.datePicker.date) as AnyObject]
        self.ref.child("Students").child(request.receiverId ?? "").child("received").child(request.reqID).updateChildValues(par)
        self.ref.child("Students").child(request.senderId ?? "").child("sent").child(request.reqID).updateChildValues(par)
        
        if Auth.auth().currentUser?.uid == self.request.senderId {
            
//            self.setupPushNotification(fromDevice: self.request.receiverId, title: "Session Cancellation", body: "\(self.request.senderName!) canceld the session, based on the case you might get some compensaton")
        } else {
            
//            self.setupPushNotification(fromDevice: self.request.senderDevice, title: "Session Cancellation", body: "\(self.request.receiverName!) canceld the session, kindly send out another request.")
        }
    }
    
    @IBAction func donePrsd(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.requestersView.isHidden = true
        }
    }
    
    @IBAction func switchTableView(_ sender: Any) {
        if receivdAptsTable.isHidden == true {
            pageTitle.text = "Received Appointments"
            switchRequstBtn.setTitle("Sent", for: .normal)
            receivdAptsTable.isHidden = false
            sentAptsTable.isHidden = true
        } else {
            switchRequstBtn.setTitle("Received", for: .normal)
            pageTitle.text = "Sent Appointments"
            receivdAptsTable.isHidden = true
            sentAptsTable.isHidden = false
        }
    }
    
    @IBAction func denyApt(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.requestersView.isHidden = true
        }
        let dateString = String(describing: Date())
        let par = ["time": dateString as AnyObject,
                   "status":"rejected"] as! [String: Any]
        self.ref.child("Students").child(request.receiverId ?? "").child("received").child(request.reqID).updateChildValues(par)
        self.ref.child("Students").child(request.senderId ?? "").child("sent").child(request.reqID).updateChildValues(par)
        
        if Auth.auth().currentUser?.uid == self.request.senderId {
            
//            self.setupPushNotification(fromDevice: self.request.receiverId, title: "Session Cancellation", body: "\(self.request.senderName!) canceld the session, based on the case you might get some compensaton")
        } else {
            
//            self.setupPushNotification(fromDevice: self.request.senderDevice, title: "Session Cancellation", body: "\(self.request.receiverName!) canceld the session, kindly send out another request.")
        }
    }
    
    
    func fetchApts() {
        let ref = Database.database().reference()
        handle = ref.child("Students").child(Auth.auth().currentUser?.uid ?? " ").queryOrderedByKey().observe( .value, with: { response in
            if response.value is NSNull {
            } else {
                let tutDict = response.value as! [String:AnyObject]
                
                if let json = tutDict["received"] as? [String:AnyObject] {
                    //                    self.tutor.receivedObject = json
                    self.receivedApts = self.setUpReqArr(tableArr: self.receivedApts, object: json, table: self.receivdAptsTable, isSender: false)
                }
                if let json = tutDict["sent"] as? [String:AnyObject] {
                    //                    self.tutor.receivedObject = json
                    self.sentApts = self.setUpReqArr(tableArr: self.sentApts, object: json, table: self.sentAptsTable, isSender: true)
                }
                
            }
        })
    }
    
    func setUpReqArr (tableArr: Student, object:[String : AnyObject], table:UITableView, isSender:Bool) -> Student {
        if isSender {
            tableArr.sendAptsAcptd.removeAll()
            tableArr.sendAptsPending.removeAll()
            tableArr.sentAptsRjctd.removeAll()
            for (_,b) in object {
                var req = Request()
                req.senderName = b["senderName"] as? String
                req.receiverName = b["receiverName"] as? String
                req.senderId = b["senderId"] as? String
                req.receiverId = b["receiverId"] as? String
                let ts = b["time"] as? String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                let dat = dateFormatter.date(from: ts as! String)
                req.timeString = functions.getTimeSince(date: dat ?? Date())
                req.reqID = b["reqId"] as? String
                req.senderDevice = b["senderDevice"] as? String
                req.recieverDevice = b["receiverDevice"] as? String
                req.postTite = b["postTitle"] as? String
                req.senderPhone = b["senderPhone"] as? String
                req.senderPicUrl = b["senderPic"] as? String
                req.receiverCustomerId = b["receiverCustomerId"] as? String
                req.senderCustomerId = b["senderCustomerId"] as? String
                req.sessionPrice = b["price"] as? Int
                req.reqStatus = b["status"] as? String
                req.receiverPicUrl = b["receiverPic"] as? String//aptDate
                req.receiverPayment = b["receiverPayment"] as? [String]
                req.apointmentDate = b["aptDate"] as? String
                if req.reqStatus == "pending" {
                    tableArr.sendAptsPending.append(req)
                } else if req.reqStatus == "approved" {
                    tableArr.sendAptsAcptd.append(req)
//                    self.notificationRepeats = true
                } else if req.reqStatus == "rejected" {
                    tableArr.sentAptsRjctd.append(req)
                } else if req.reqStatus == "finished" {
                    tableArr.sendAptsPending.append(req)
                }
            }
        } else {
            tableArr.receivedAptsAcptd.removeAll()
            tableArr.receivedAptsRjctd.removeAll()
            tableArr.receivedAptsPending.removeAll()
            for (_,b) in object {
                var req = Request()
                req.senderName = b["senderName"] as? String
                req.receiverName = b["receiverName"] as? String
                req.senderId = b["senderId"] as? String
                req.receiverId = b["receiverId"] as? String
                let ts = b["time"] as? String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                let dat = dateFormatter.date(from: ts as! String)
                req.timeString = functions.getTimeSince(date: dat ?? Date())
                req.reqID = b["reqId"] as? String
                req.senderDevice = b["senderDevice"] as? String
                req.recieverDevice = b["receiverDevice"] as? String
                req.postTite = b["postTitle"] as? String
                req.senderPhone = b["senderPhone"] as? String
                req.senderPicUrl = b["senderPic"] as? String
                req.receiverCustomerId = b["receiverCustomerId"] as? String
                req.senderCustomerId = b["senderCustomerId"] as? String
                req.sessionPrice = b["price"] as? Int
                req.apointmentDate = b["aptDate"] as? String
                req.receiverPicUrl = b["receiverPic"] as? String
                req.receiverPayment = b["receiverPayment"] as? [String]
                req.reqStatus = b["status"] as? String
                if req.reqStatus == "pending" {
                    tableArr.receivedAptsPending.append(req)
                } else if req.reqStatus == "approved" {
                    tableArr.receivedAptsAcptd.append(req)
                    //                    self.notificationRepeats = true
                } else if req.reqStatus == "rejected" {
                    tableArr.receivedAptsRjctd.append(req)
                } else if req.reqStatus == "finished" {
                    tableArr.sendAptsPending.append(req)
                }
            }
        }
        table.reloadData()
        return tableArr
    }
    
    func acceptRequest() {
        let dateString = String(describing: Date())
        var calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
        formatter.calendar.date(byAdding: .minute, value: 20, to: Date())
        let strDate = formatter.string(from: Date())
        let datesss = calendar.date(byAdding: .minute, value: 20, to: formatter.date(from: strDate)!)
        let y = formatter.string(from: datesss!)
        var payOut: [Int]
        let title = "HomeworkMe"
        payOut = convMony(price: request.sessionPrice)
        let desc = "Description: Payment to: \(request.receiverName ?? "") from: \(request.senderName ?? "") for \(request.postTite ?? "") total paid \(payOut[1])"
        
        let receiptParam = ["tutor":request.receiverName,
                            "tutorPhone":request.receiverPhone,
                            "tutorPay":request.receiverPayment,
                            "studentPhon":request.senderPhone,
                            "studentCust":request.senderCustomerId,
                            "student":request.senderName,
                            "price":request.sessionPrice,
                            "date":payOut,
                            "description":desc] as! [String:AnyObject]
        
        let locParam = ["time": dateString as AnyObject,
                        "status":"approved"] as! [String: Any]
        
        let priceParam = ["price":payOut[1]] as! [String: Any]
        
        
        self.ref.child("Students").child(request.senderId ?? "").child("sent").child(request.reqID).updateChildValues(locParam)
        self.ref.child("Students").child(request.receiverId ?? "").child("received").child(request.reqID).updateChildValues(locParam)
        
        self.ref.child("Students").child(request.senderId ?? "").child("sent").child(request.reqID).updateChildValues(priceParam)
        self.ref.child("Students").child(request.receiverId ?? "").child("received").child(request.reqID).updateChildValues(priceParam)
        
        self.ref.child("Receipt").child(request.reqID).updateChildValues(receiptParam)
        self.ref.child("Students").child(request.senderId ?? "").child("receipt").child(request.reqID).updateChildValues(receiptParam)
        self.ref.child("Students").child(request.receiverId ?? "").child("receipt").child(request.reqID).updateChildValues(receiptParam)
        requestersView.isHidden = true
        
        setupPushNotification(fromDevice: request.senderDevice, title: title, body: "\(request.receiverName ?? "") Has accepted your assignment help session and is on his way to \(request.place.name!)")

    }
    
    var storageRef: Storage {
        return Storage.storage()
    }
    
    func setupReqView(req: Request, isReceiverView: Bool){
        if isReceiverView{
            downlaodPic2(url: req.senderPicUrl)
            name.text = req.senderName
            aptTime.text = req.apointmentDate
            postTitle.text = req.postTite
            stackViewToHide.isHidden = false
            if req.reqStatus == "pending" {
               stackViewToHide.isHidden = true
            }
        } else {
            downlaodPic2(url: req.receiverPicUrl)
            name.text = req.receiverName
            aptTime.text = req.apointmentDate
            postTitle.text = req.postTite
            stackViewToHide.isHidden = true
        }
    }
    
    func convMony(price:Int) -> [Int] {
        let total = price * 100
        let payOut = Int(floor(Double(total) * 0.25))
        let pay = [total, total - payOut]
        return pay
    }
    
    func editImage(image:UIImageView){
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
    }
    
    func downlaodPic2(url:String) {
        if url != nil && url != "" && url != " " {
            self.storageRef.reference(forURL:url).getData(maxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                if error == nil {
                    if let data = imgData{
                        self.profPic.image = UIImage(data: data)
                    }
                }
                else {
                    print(error?.localizedDescription)
                }
            })
        } else {
            self.profPic.image = UIImage(named: "engineering")
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
}

extension AppointmentsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == receivdAptsTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "receivedAptsCell", for: indexPath)
            if indexPath.section == 0 {
                //                timerLabel.isHidden = true
                cell.textLabel?.text = "\( receivedApts.receivedAptsPending[indexPath.row].senderName ?? "")\n\(receivedApts.receivedAptsPending[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = receivedApts.receivedAptsPending[indexPath.row].postTite
                return cell
            } else if indexPath.section == 1 {
                cell.textLabel?.text = "\(receivedApts.receivedAptsAcptd[indexPath.row].senderName ?? "")\n\(receivedApts.receivedAptsAcptd[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = receivedApts.receivedAptsAcptd[indexPath.row].postTite
                return cell
            } else if indexPath.section == 2 {
                cell.textLabel?.text = "\(receivedApts.receivedAptsHstry[indexPath.row].senderName ?? "")\n\(receivedApts.receivedAptsHstry[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = receivedApts.receivedAptsHstry[indexPath.row].postTite
                return cell
            } else if indexPath.section == 3 {
                
            }
            return cell
        }  else if tableView == sentAptsTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sentAptsCell", for: indexPath)
            if indexPath.section == 0 {
                //                timerLabel.isHidden = true
                cell.textLabel?.text = "\( sentApts.sendAptsPending[indexPath.row].senderName ?? "")\n\(sentApts.sendAptsPending[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = sentApts.sendAptsPending[indexPath.row].postTite
                return cell
            } else if indexPath.section == 1 {
                cell.textLabel?.text = "\(sentApts.sendAptsAcptd[indexPath.row].senderName ?? "")\n\(sentApts.sendAptsAcptd[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = sentApts.sendAptsAcptd[indexPath.row].postTite
                return cell
            } else if indexPath.section == 2 {
                cell.textLabel?.text = "\(sentApts.sentAptsHstry[indexPath.row].senderName ?? "")\n\(sentApts.sentAptsHstry[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = sentApts.sentAptsHstry[indexPath.row].postTite
                return cell
            } else if indexPath.section == 3 {
                cell.textLabel?.text = "\(sentApts.sentAptsRjctd[indexPath.row].senderName ?? "")\n\(sentApts.sentAptsRjctd[indexPath.row].postTite ?? "")"
                cell.detailTextLabel?.text = sentApts.sentAptsRjctd[indexPath.row].postTite
                return cell
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "sentAptsCell", for: indexPath)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == receivdAptsTable {
            if section == 0 {
                return "Pending Appointments"
            } else if section == 1 {
                return "Upcoming Appointments"
            } else if section == 2 {
                return "Requests History"
            } else if section == 3 {
                return "Rejected Appointments"
            }
            return ""
        }
        if tableView == sentAptsTable {
            if section == 0 {
                return "Pending Appointments"
            } else if section == 1 {
                return "Approved Appointments"
            } else if section == 2 {
                return "Requests History"
            } else if section == 3 {
                return "Rejected Appointments"
            }
            return ""
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == receivdAptsTable {
            switch (section) {
            case 0:
                return receivedApts.receivedAptsPending.count
            case 1:
                return receivedApts.receivedAptsAcptd.count
            case 2:
                return receivedApts.receivedAptsHstry.count
            case 3:
                return receivedApts.receivedAptsRjctd.count
            default:
                return 0
            }
        }  else if tableView == sentAptsTable {
            switch (section) {
            case 0:
                return sentApts.sendAptsPending.count
            case 1:
                return sentApts.sendAptsAcptd.count
            case 2:
                return sentApts.sentAptsHstry.count
            case 3:
                return sentApts.sentAptsRjctd.count
            default:
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        requestersView.isHidden = false
        if tableView == sentAptsTable {
            if indexPath.section == 0 { // pending
                request = sentApts.sendAptsPending[indexPath.row]
                setupReqView(req: sentApts.sendAptsPending[indexPath.row], isReceiverView: false)
            } else if indexPath.section == 1 {// accepted
                request = sentApts.sendAptsAcptd[indexPath.row]
                setupReqView(req: sentApts.sendAptsAcptd[indexPath.row], isReceiverView: false)
                
            } else if indexPath.section == 2 { // history
                request = sentApts.sentAptsHstry[indexPath.row]
                setupReqView(req: sentApts.sentAptsHstry[indexPath.row], isReceiverView: false)
                
            } else if indexPath.section == 3 { // rejected
                request = sentApts.sentAptsRjctd[indexPath.row]
                setupReqView(req: sentApts.sentAptsRjctd[indexPath.row], isReceiverView: false)
            }
        }
        if tableView == receivdAptsTable {
            isSender = false
            if indexPath.section == 0 { // pending
                request = receivedApts.sendAptsPending[indexPath.row]
                setupReqView(req: receivedApts.sendAptsPending[indexPath.row], isReceiverView: true)
            } else if indexPath.section == 1 {// accepted
                request = receivedApts.receivedAptsAcptd[indexPath.row]
                setupReqView(req: receivedApts.receivedAptsAcptd[indexPath.row], isReceiverView: true)
                
            } else if indexPath.section == 2 { // history
               setupReqView(req: receivedApts.receivedAptsHstry[indexPath.row], isReceiverView: true)
                
            } else if indexPath.section == 3 { // rejected
                setupReqView(req: receivedApts.receivedAptsRjctd[indexPath.row], isReceiverView: true)
            }
        }
    }
}
