//
//  ViewController.swift
//  Examples
//
//  Created by Demetrio Filocamo on 12/03/2016.
//  Copyright © 2016 Novaware Ltd. All rights reserved.
//

import UIKit
import Eureka
import SwiftValidator

class ViewController: FormViewController {

    var testHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()

        form =
                Section("Insert your data")

                <<< SVTextRow("hidden") {
            $0.title = "Hidden"
            $0.placeholder = "Hidden field"
            $0.rules = [RequiredRule(), FullNameRule(), MinLengthRule(length: 5), MaxLengthRule(length: 20)]
            $0.autoValidation = false
            $0.hidden = Condition.Function([""], {
                (form) -> Bool in
                return !self.testHidden
            })
        }

                <<< SVTextRow() {
            $0.title = "Name"
            $0.placeholder = "Insert your full name"
            $0.rules = [RequiredRule(), FullNameRule(), MinLengthRule(length: 5), MaxLengthRule(length: 20)]
            $0.autoValidation = false
        }

                <<< SVEmailRow() {
            $0.title = "Email"
            $0.placeholder = ""
            $0.rules = [RequiredRule(), EmailRule(message: "Please insert a valid email address")]
            $0.autoValidation = false
        }

                <<< SVTextRow() {
            $0.title = "Street"
            $0.placeholder = "First line"
            $0.rules = [RequiredRule(), MinLengthRule(length: 5), MaxLengthRule(length: 30)]
            $0.autoValidation = false
        }

                <<< SVTextRow() {
            $0.title = " "
            $0.placeholder = "Optional second line"
            $0.autoValidation = false
        }

                <<< SVTextRow() {
            $0.title = "City"
            $0.placeholder = ""
            $0.rules = [RequiredRule()]
            $0.autoValidation = false
        }

                <<< SVTextRow() {
            $0.title = "Post Code"
            $0.placeholder = ""
            $0.rules = [RequiredRule()]
            $0.autoValidation = false
        }

                <<< SVTextRow() {
            $0.title = "Country"
            $0.placeholder = ""
            $0.value = "United Kingdom"
            $0.rules = [RequiredRule()]
            $0.autoValidation = false
        }

                <<< SVPasswordRow() {
            $0.title = "Password"
            $0.placeholder = ""
            $0.rules = [RequiredRule()]
            $0.autoValidation = false
        }

                <<< SVPhoneRow() {
            $0.title = "Phone"
            $0.placeholder = ""
            $0.rules = [RequiredRule()]
            $0.autoValidation = false
        }

                <<< SVIntRow() {
            $0.title = "Int"
            $0.placeholder = ""
            $0.rules = [RequiredRule()]
            $0.autoValidation = false
        }

                +++ Section("") {
            $0.tag = "result"
        }

                <<< SwitchRow() {
            $0.title = "Hidden field?"
            $0.value = self.testHidden
        }.onChange {
            [weak self] row in
            if row.value ?? false {
                self!.testHidden = true
            } else {
                self!.testHidden = false
            }
            let hiddenField = self!.form.rowByTag("hidden")
            hiddenField!.evaluateHidden()
        }

                <<< LabelRow("formValid") {
            $0.title = "Form valid?"
            $0.value = "No"
        }
    }

    @IBAction func saveClicked(sender: AnyObject) {
        let dataValid = form.validateAll()

        if dataValid {
            NSLog("Valid")
        } else {
            NSLog("Invalid")
        }

        let result = form.rowByTag("formValid")
        result!.baseValue = dataValid ? "Yes" : "No"
        result!.updateCell()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

