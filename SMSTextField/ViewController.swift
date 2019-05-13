//
//  ViewController.swift
//  SMSTextField
//
//  Created by jhunter on 2019/5/8.
//  Copyright © 2019 com.jh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var codeTextField: JHCodeTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeTextField.update(textLimited: 6, textColor: .blue, font: UIFont.systemFont(ofSize: 30), underlineColor: .darkGray)
    }


}

