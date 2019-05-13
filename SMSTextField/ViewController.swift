//
//  ViewController.swift
//  SMSTextField
//
//  Created by jhunter on 2019/5/8.
//  Copyright © 2019 com.jh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var smsTextField: SMSTextField!
    @IBOutlet weak var codeTextField: JHCodeTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        smsTextField.font = UIFont.systemFont(ofSize: 30)
        
        codeTextField.update(textLimited: 6, textColor: .blue, font: UIFont.systemFont(ofSize: 30), underlineColor: .red)
    }


}

