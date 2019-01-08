//
//  PreSignUpSceenVC.swift
//  HomeworkMe 2.0
//
//  Created by Radiance Okuzor on 1/7/19.
//  Copyright © 2019 RayCo. All rights reserved.
//

import UIKit
import Firebase

class PreSignUpSceenVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var phoneNumbrTxt: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var welcom: UILabel!
    let picker = UIImagePickerController()
    var userStorage: StorageReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        welcom.text = "Welcome! \(ProfileVC.student.firstName ?? "")"
        picker.delegate = self
        let storage = Storage.storage().reference(forURL: "gs://hmwrkme.appspot.com")
        userStorage = storage.child("Students")
        
        dismissKeyboard()
        editImage(image: profilePic)
    }
    
    @IBAction func editPicPrsd(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func donePrsd(_ sender: Any) {
        if phoneNumbrTxt.text != "" && ProfileVC.student.pictureUrl != nil {
            save()
        } else {
            let alert = UIAlertController(title: "Missing Information", message: "Kindly make sure you add a picture and phone number", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.profilePic.image = image
            ProfileVC.student.pictureUrl = "url"
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
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

    func save() {
        let ref = Database.database().reference()
        let userId = Auth.auth().currentUser?.uid
        let imageRef = self.userStorage.child("\(userId ?? "").jpg")
        let data = self.profilePic.image?.jpegData(compressionQuality: 0.5)
        
        let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            } else {
                UserDefaults.standard.set(data, forKey: "pictureData")
            }
            
            imageRef.downloadURL(completion: { (url, er) in
                if er != nil {
                    print(er!.localizedDescription)
                }
                if let url = url {
                    ProfileVC.student.pictureUrl = url.absoluteString
                    ref.child("Students").child(userId ?? "").child("pictureUrl").setValue(url.absoluteString)
                    ref.child("Students").child(userId ?? "").child("phoneNumber").setValue(self.phoneNumbrTxt.text)
                }
            })
        })
        let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDel.logUser()
        uploadTask.resume()
    }
    
}
