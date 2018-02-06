//
//  ViewController.swift
//  testPullDown
//
//  Created by osu on 2018/02/05.
//  Copyright © 2018 osu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchTextField: SearchTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let contryCode:[SearchTextFieldItem] = [
            SearchTextFieldItem("ABW", "Aruba"),
            SearchTextFieldItem("AFG", "Afghanistan"),
            SearchTextFieldItem("AGO", "Angola"),
            SearchTextFieldItem("AIA", "Anguilla"),
            SearchTextFieldItem("ALA", "Åland Islands"),
            SearchTextFieldItem("ALB", "Albania"),
            SearchTextFieldItem("AND", "Andorra"),
            SearchTextFieldItem("ARE", "United Arab Emirates"),
            SearchTextFieldItem("ARG", "Argentina"),
            SearchTextFieldItem("ARM", "Armenia"),
            SearchTextFieldItem("ASM", "American Samoa"),
            SearchTextFieldItem("ATA", "Antarctica")
        ]
        searchTextField.filterDataSource = contryCode
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


