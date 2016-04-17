//
//  ViewController.swift
//  fambam
//
//  Created by Eric Torigian on 4/6/16.
//  Copyright © 2016 Eric Torigian. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class ViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
			self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
		}
	}
	
	@IBAction func fbBtnPressed(sender: UIButton!) {
		let facebookLogin = FBSDKLoginManager()
		
		facebookLogin.logInWithReadPermissions(["email"]) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
			
			if facebookError != nil {
				print("Facebook login failed.  Error \(facebookError)")
			} else {
				let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
				print("successfully logged in with facebook. \(accessToken)")
				
				DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
					
					if error != nil {
						print("Login failed.  \(error.description)")
					} else {
						print("Logged in! \(authData)")
						NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
						self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
					}
					
				})
			}
		}
	}

	@IBAction func attemptLogin(sender: UIButton! ) {
		
		if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
			
			DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
				if error != nil {

					if error.code == STATUS_ACCOUNT_NONEXISTS {
						DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, results in
							if error != nil {
								self.showErrorAlert("Could not create account", msg: "Problem creating account on server \(error.description)")
							} else {
								DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: nil)
								NSUserDefaults.standardUserDefaults().setValue(results[KEY_UID], forKey: KEY_UID)
								self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
							}
						})
					} else if error.code == STATUS_INVALID_PWD {
						self.showErrorAlert("Error logging in", msg: "Invalid password/email combination.   Please try again")
						
					} else 	{
						self.showErrorAlert("Error logging in", msg: error.description)
					}
				}  else {
					NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
					self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
					
				}
			})
			
			
		} else {
			showErrorAlert("Login Error", msg: "You must include both an email and password to login")
		}
		
	}
	
	func showErrorAlert(title: String, msg: String) {
		let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert )
		let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
		alert.addAction(action)
		presentViewController(alert, animated: true, completion: nil)
	}
	

}

