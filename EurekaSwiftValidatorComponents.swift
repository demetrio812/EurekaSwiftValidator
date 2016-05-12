//
//  EurekaCustomCells.swift
//
//  Created by Demetrio Filocamo on 29/01/2016.
//

import UIKit
import Foundation
import Eureka
import SwiftValidator
import WebKit

import ObjectiveC

/**
*  Protocol for cells that contain a UITextField that can be validated
*/
public protocol SVTextFieldCell : TextFieldCell {
    var errorColor : UIColor { get }
    func setErrorColor(errorColor: UIColor)
    var rules : [Rule]? { get }
    func setRules(rules: [Rule]?)
    var autoValidation : Bool { get }
    func setAutoValidation(autoValidation: Bool)
    var valid : Bool { get }

    func validate()
}

public class _SVFieldCell<T where T: Equatable, T: InputTypeInitiable>: _FieldCell<T>, SVTextFieldCell{

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    lazy public var validationLabel: UILabel = {
        [unowned self] in
        let validationLabel = UILabel()
        validationLabel.translatesAutoresizingMaskIntoConstraints = false
        validationLabel.font = validationLabel.font.fontWithSize(10.0)
        return validationLabel
    }()

    public override func setup() {
        super.setup()
        textField.autocorrectionType = .Default
        textField.autocapitalizationType = .Sentences
        textField.keyboardType = .Default

        self.height = {
            60
        }
        contentView.addSubview(validationLabel)

//        let viewDictionary = ["cell": self, "validationLabel": self.validationLabel, "textField": self.textField, "label": self.titleLabel!]
//        let fixedHeight: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("V:[validationLabel(15)]", options: .AlignAllCenterX, metrics: nil, views: viewDictionary)
//        let yPosition: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("V:[textField]-4-[validationLabel]", options: .AlignAllCenterX, metrics: nil, views: viewDictionary)
//        let xPosition: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[validationLabel]-|", options: .AlignAllCenterX, metrics: nil, views: viewDictionary)
        let sameLeading: NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: .Leading, relatedBy: .Equal, toItem: self.validationLabel, attribute: .Leading, multiplier: 1, constant: -20)
        let sameTrailing: NSLayoutConstraint = NSLayoutConstraint(item: self.textField, attribute: .Trailing, relatedBy: .Equal, toItem: self.validationLabel, attribute: .Trailing, multiplier: 1, constant: 0)
        let sameBottom: NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: .Bottom, relatedBy: .Equal, toItem: self.validationLabel, attribute: .Bottom, multiplier: 1, constant: 4)
        var all: [NSLayoutConstraint] = [sameLeading, sameTrailing, sameBottom]
//        all += fixedHeight
//        all += yPosition
//        all += xPosition

        contentView.addConstraints(all)

        validationLabel.textAlignment = NSTextAlignment.Right
        validationLabel.adjustsFontSizeToFitWidth = true
        validationLabel.text = ""
        resetField()


    }

    public func setRules(rules: [Rule]?) {
        self.rules = rules
    }

    public func setErrorColor(errorColor: UIColor) {
        self.errorColorI = errorColor
    }

    public func setAutoValidation(autoValidation: Bool) {
        self.autoValidationI = autoValidation
    }

    override public func textFieldDidChange(textField: UITextField) {
        super.textFieldDidChange(textField)

        if autoValidation {
            validate()
        }
    }

    // MARK: - Validation management

    public func validate() {
        if let v = self.validator {
            // Registering the rules
            if !rulesRegistered {
                v.unregisterField(textField)  //  in case the method has already been called
                if let r = rules {
                    v.registerField(textField, errorLabel: validationLabel, rules: r)
                }
                self.rulesRegistered = true
            }

            self.valid = true

            v.validate({
                (errors) -> Void in
                self.resetField()
                for (field, error) in errors {
                    self.valid = false
                    self.showError(field, error: error)
                }
            })
        } else {
            self.valid = false
        }
    }

    func resetField() {
        validationLabel.hidden = true
        textField.textColor = UIColor.blackColor()
        self.textLabel?.textColor = UIColor.blackColor()
    }

    func showError(field: UITextField, error: ValidationError) {
        // turn the field to red
        field.textColor = errorColor
        if let ph = field.placeholder {
            let str = NSAttributedString(string: ph, attributes: [NSForegroundColorAttributeName: errorColor])
            field.attributedPlaceholder = str
        }
        self.textLabel?.textColor = errorColor
        self.validationLabel.textColor = errorColor
        error.errorLabel?.text = error.errorMessage // works if you added labels
        error.errorLabel?.hidden = false
    }

    var validator: Validator? {
        get {
            if let fvc = formViewController() {
                return fvc.form.validator
            }
            return nil;
        }
    }
    private var rulesRegistered = false
    private var errorColorI : UIColor = UIColor.redColor()
    private var autoValidationI = true

    public var errorColor : UIColor{
        get {
            return errorColorI
        }
    }
    public var autoValidation : Bool {
        get {
            return autoValidationI
        }
    }
    public var rules: [Rule]? = nil

    public var valid = false
}

//             FieldRow<T: Any, Cell: CellType where Cell: BaseCell, Cell: TypedCellType, Cell: TextFieldCell, Cell.Value == T>: Row<T, Cell>, FieldRowConformance, KeyboardReturnHandler
public class SVFieldRow<T: Any, Cell: CellType where Cell: BaseCell, Cell: TypedCellType, Cell: SVTextFieldCell, Cell.Value == T>: FieldRow<T, Cell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }

    public var errorColor: UIColor {
        get {
            return self.cell.errorColor
        }
        set {
            self.cell.setErrorColor(newValue)
        }
    }

    /*public var validator: Validator {
        get {
            return self.cell.validator
        }
        set {
            self.cell.setValidator(newValue)
        }
    }*/

    public var rules: [Rule]? {
        get {
            return self.cell.rules
        }
        set {
            self.cell.setRules(newValue)
        }
    }

    public var autoValidation: Bool {
        get {
            return self.cell.autoValidation
        }
        set {
            self.cell.setAutoValidation(newValue)
        }
    }

    public var valid: Bool {
        get {
            return self.cell.valid
        }
    }

    public func validate() {
        self.cell.validate()
    }
}

public class _SVTextRow: SVFieldRow<String, SVTextCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _SVIntRow: SVFieldRow<Int, SVIntCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = .currentLocale()
        numberFormatter.numberStyle = .DecimalStyle
        numberFormatter.minimumFractionDigits = 0
        formatter = numberFormatter
    }
}

public class _SVEmailRow: SVFieldRow<String, SVEmailCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _SVPhoneRow: SVFieldRow<String, SVPhoneCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public class _SVPasswordRow: SVFieldRow<String, SVPasswordCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A String valued row where the user can enter arbitrary text.

public final class SVTextRow: _SVTextRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        /*onCellHighlight {
            cell, row in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight {
                cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }*/
    }
}

/// A row where the user can enter an integer number.
public final class SVIntRow: _SVIntRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        /*onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }*/
    }
}

/// A String valued row where the user can enter an email address.
public final class SVEmailRow: _SVEmailRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        /*onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }*/
    }
}

/// A String valued row where the user can enter a phone number.
public final class SVPhoneRow: _SVPhoneRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        /*onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }*/
    }
}

public final class SVPasswordRow: _SVPasswordRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        /*onCellHighlight { cell, row  in
         let color = cell.textLabel?.textColor
         row.onCellUnHighlight { cell, _ in
         cell.textLabel?.textColor = color
         }
         cell.textLabel?.textColor = cell.tintColor
         }*/
    }
}

public class SVTextCell: _SVFieldCell<String>, CellType  {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public override func setup() {
        super.setup()
        textField.autocorrectionType = .Default
        textField.autocapitalizationType = .Sentences
        textField.keyboardType = .Default
    }
}

public class SVIntCell : _SVFieldCell<Int>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public override func setup() {
        super.setup()
        textField.autocorrectionType = .Default
        textField.autocapitalizationType = .None
        textField.keyboardType = .NumberPad
    }
}

public class SVEmailCell : _SVFieldCell<String>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public override func setup() {
        super.setup()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.keyboardType = .EmailAddress
    }
}

public class SVPhoneCell : _SVFieldCell<String>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public override func setup() {
        super.setup()
        textField.keyboardType = .PhonePad
    }
}

public class SVPasswordCell: _SVFieldCell<String>, CellType  {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.keyboardType = .ASCIICapable
        textField.secureTextEntry = true
    }
}

// TODO extend _FieldCell and _FieldRow to avoid custom components
// TODO better way for styleTransformers

extension Form {

    private struct AssociatedKey {
        static var validator: UInt8 = 0
        static var dataValid: UInt8 = 0
    }

    var validator: Validator {
        get {
            if let validator = objc_getAssociatedObject(self, &AssociatedKey.validator) {
                return validator as! Validator
            } else {
                let v = Validator()
                self.validator = v
                return v
            }
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKey.validator, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var dataValid: Bool {
        get {
            if let dv = objc_getAssociatedObject(self, &AssociatedKey.dataValid) {
                return dv as! Bool
            } else {
                let dv = false
                self.dataValid = dv
                return dv
            }
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKey.dataValid, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func validateAll() -> Bool {
        dataValid = true

        let rows = allRows
        for row in rows {
            if row is SVTextRow {
                let svRow = (row as! SVTextRow)
                svRow.evaluateHidden()
                if !svRow.isHidden { // skip if hidden
                    svRow.validate()
                    let rowValid = svRow.valid
                    svRow.autoValidation = true // from now on autovalidation is enabled
                    if !rowValid && dataValid {
                        dataValid = false
                    }
                }
            }
        }
        return dataValid
    }
}
