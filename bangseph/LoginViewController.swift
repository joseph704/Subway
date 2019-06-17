//
//  LoginViewController.swift
//  bangseph
//
//  Created by 차요셉 on 03/06/2019.
//  Copyright © 2019 차요셉. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var PressBtnd: UIButton!
    
    @IBAction func signin(_ sender: Any) {
        audioController.playerEffect(name: SoundDing)
        
        let explore = ExplodeView(frame: CGRect(x: (PressBtnd.imageView?.center.x)!, y:(PressBtnd.imageView?.center.y)!, width:10,height:10))
        PressBtnd.imageView?.superview?.addSubview(explore)
        PressBtnd.imageView?.superview?.sendSubviewToBack(_: explore)
        
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (authResult, error) in
            // ...
            
            if(error != nil) {
                Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                    self.performSegue(withIdentifier: "Home", sender: nil)
                }
            }else {
                let alert = UIAlertController(title: "알림", message: "회원가입완료", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.performSegue(withIdentifier: "Home", sender: nil)
            }
            
            
            
            
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        Auth.auth().addStateDidChangeListener ({ (user, err) in
//            if user != nil {
//                self.performSegue(withIdentifier: "Home", sender: nil)
//            }
//        })
    }
    
    var audioController: AudioController
    required init?(coder aDecoder: NSCoder) {
        audioController = AudioController()
        audioController.preloadAudioEffects(audioFileNames: AudioEffectFiles)
        
        super.init(coder: aDecoder)
    }
    
    
    }
