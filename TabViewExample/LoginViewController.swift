//
//  LoginViewController.swift
//  TabViewExample
//
//  Created by Pritesh Patel on 2017-07-20.
//  Copyright © 2017 MoxDroid. All rights reserved.
//

import UIKit
import PinCodeTextField
import FTPopOverMenu_Swift
class LoginViewController: BaseViewController {

    var rb : UIBarButtonItem!
    @IBOutlet weak var pinCodeTextField: PinCodeTextField!
    var menuOptionNameArray : [String] = ["Share","Delete","Upload","Download"]
    var menuOptionImageNameArray : [String] = ["Pokemon_Go_01","Pokemon_Go_01","Pokemon_Go_01","Pokemon_Go_01"]
    override func viewDidLoad() {
        super.viewDidLoad()
         addSlideMenuButton()
        // Do any additional setup after loading the view.
        rb = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
         self.navigationItem.rightBarButtonItem = rb
        
        
    }
    func addTapped()  {
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginClick(_ sender: UIButton) {
        // Swift 3.0
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "mainTabView")
        if let navigator = navigationController {
            navigator.pushViewController(controller, animated: true)
        }
        //self.present(controller, animated: true, completion: nil)
        */
        FTPopOverMenu.showForSender(sender: sender, with: menuOptionNameArray, menuImageArray: menuOptionImageNameArray, done: { (selectedIndex) -> () in
            print(selectedIndex)
        }) {
            
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
