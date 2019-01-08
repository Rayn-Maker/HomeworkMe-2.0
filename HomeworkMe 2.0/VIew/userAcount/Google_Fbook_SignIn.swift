//
//  Google_Fbook_SignIn.swift
//  HomeworkMe 2.0
//
//  Created by Radiance Okuzor on 1/3/19.
//  Copyright © 2019 RayCo. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class Google_Fbook_SignIn: UIViewController {

    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    
    var window: UIWindow?
    var ref: DatabaseReference!
    var alert: CommonFunctions!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        dismissKeyboard()
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        ref = Database.database().reference()
        guard emailField.text != "", pwField.text != "" else {return}
        
        Auth.auth().signIn(withEmail: emailField.text!, password: pwField.text!, completion: { (user, error) in
            
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "dismiss", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true)
            }
            
            
            if let user = user {
               
                let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.logUser()
            }
        })
    }
    
    func dismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func addCustomer(child:String, userEmail:String){
        StripeClient.shared.creatCustomer(email: userEmail, completion: { (res) in
            print(res)
            do {
                guard let json = try JSONSerialization.jsonObject(with: res.data!, options: .mutableContainers) as? JSON else {return}
                print("the Json \( json)")
                let par = ["customerId": json["id"]] as [String: Any]
                self.ref.child("Students").child(Auth.auth().currentUser?.uid ?? "").updateChildValues(par)
                UserDefaults.standard.set(json["id"], forKey: "customerId")
            } catch {
                
            }
        })
    }
    
}

extension Google_Fbook_SignIn: GIDSignInUIDelegate, GIDSignInDelegate  {
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        //
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        //
    }
    
    
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        // ...
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            ref = Database.database().reference()
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            // Perform any operations on signed in user here.
            let userId = user.userID
            user.userID// For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            // ...
            
            
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    
                    return
                } else {
                    self.ref.child("Students").observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.hasChild(Auth.auth().currentUser?.uid ?? ""){
                            // already has account.... do nothing regarding firebase direct them to first screen.
                            
                            ProfileVC.student.firstName = user.profile.givenName
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let newViewController = storyBoard.instantiateViewController(withIdentifier: "signUpIn") as! PreSignUpSceenVC
                            self.present(newViewController, animated: true, completion: nil)
                            
                        } else {
                            ProfileVC.student.firstName = user.profile.givenName
                            let userInfo: [String: Any] = ["uid": Auth.auth().currentUser?.uid ?? "",
                                                           "fName": user.profile.givenName ?? " ",
                                                           "lName": user.profile.familyName ?? " ",
                                                           "full_name": user.profile.name ?? " ",
                                                           "email": user.profile.email ?? " "]
                            
                            
                            self.ref.child("Students").child(Auth.auth().currentUser?.uid ?? "").setValue(userInfo, withCompletionBlock: { (err, resp) in
                                if err != nil {
                                    
                                } else {
                                    
                                }
                            })
                            self.addCustomer(child: Auth.auth().currentUser?.uid ?? "", userEmail: user.profile.email)
                        }
                    })
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signUpIn") as! PreSignUpSceenVC
                    self.window?.rootViewController = vc
                }
            }
        }
    }
}
