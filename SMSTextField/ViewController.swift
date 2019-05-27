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
        
        let button = UIBarButtonItem(title: "Text", style: .plain, target: self, action: #selector(onTest(sender:)))
        navigationItem.leftBarButtonItem = button
    }

    @objc private func onTest(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: codeTextField.text, message: "SMS code is \(codeTextField.text)", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

