//
//  ViewController.swift
//  postStatsTest
//
//  Created by Vadym Sushko on 3/12/19.
//  Copyright © 2019 Vadym Sushko. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var slugTextField: UITextField!
    
    @IBOutlet weak var getStatsOutlet: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK:- TectField Delegate
  
    func textFieldDidBeginEditing(_ textField: UITextField) {
        getStatsOutlet.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if !(textField.text?.isEmpty)! {
            getStatsOutlet.isEnabled = true
        }
        return true
    }
    //MARK:-
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostStatsVC" {
            let vc = segue.destination as! PostStatsViewController
            vc.postSlug = slugTextField.text!
        }
    }

}

