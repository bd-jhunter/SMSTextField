//
//  SMSTextField.swift
//  SMSTextField
//
//  Created by jhunter on 2019/5/8.
//  Copyright © 2019 com.jh. All rights reserved.
//

import UIKit

private class SMSInnerTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: -20.0))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: -20.0))
    }
}

@available(iOS, deprecated: 12.0, message: "So many problem implement grid UI via setting blanking between characters.")
class SMSTextField: UIView {
    
    // Mark: - Properties
    var textLimited: Int {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var underlineColor: UIColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var font: UIFont {
        get { return textField.font ?? UIFont.systemFont(ofSize: 12.0) }
        set {
            textField.font = newValue
            setNeedsDisplay()
        }
    }
    
    private weak var textField: SMSInnerTextField!
    private weak var paddingConstraint: NSLayoutConstraint!
    private var underlineLayer: CALayer?

    private var fullyTextSpace: CGSize {
        let text = String(repeating: "9", count: textLimited) as NSString
        let fontAttributes: [NSAttributedString.Key: Any] = [.font: font]
        let rect = text.boundingRect(with: bounds.size, options: .usesLineFragmentOrigin, attributes: fontAttributes, context: nil)
        return rect.size
    }
    
    private var space: Float {
        let textRect = bounds
        let totalSize = fullyTextSpace
        let spacing = textRect.size.width - totalSize.width
        return Float(spacing) / Float(textLimited + 1)
    }
    

    // MARK: - Lifecycle
    init(frame: CGRect, textLimited: Int = 6, underlineColor: UIColor = .darkGray) {
        self.textLimited = textLimited
        self.underlineColor = underlineColor
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.textLimited = 6
        self.underlineColor = .red
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateUnderline()
        updateText()
    }
    
    // MARK: - Public methods
    
    
    // MARK: - Private methods
    private func setupView() {
        let textField: SMSInnerTextField = {
            addSubview($0)
            $0.borderStyle = .none
            $0.textAlignment = .left
            $0.tintColor = .clear
            $0.font = UIFont.systemFont(ofSize: 14.0)
            
            if #available(iOS 12.0, *) {
                $0.textContentType = .oneTimeCode
            }
            
            return $0
        }(SMSInnerTextField(frame: .zero))
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged(textField:)), for: .editingChanged)
        self.textField = textField

        textField.translatesAutoresizingMaskIntoConstraints = false
        var constraint = NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: CGFloat(space))
        addConstraint(constraint)
        paddingConstraint = constraint

        constraint = NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        addConstraint(constraint)

        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[textField]-(3)-|",
                                                     options: [],
                                                     metrics: nil,
                                                     views: ["textField": textField])
        addConstraints(constraints)
    }
    
    private func updateUnderline() {
        if underlineLayer == nil {
            let underlineLayer = CALayer()
            self.underlineLayer = underlineLayer
            layer.addSublayer(underlineLayer)
            underlineLayer.backgroundColor = underlineColor.cgColor
        }
        
        let rect = bounds
        underlineLayer?.frame = CGRect(x: rect.origin.x, y: rect.origin.y + rect.size.height - 2, width: rect.size.width, height: 2.0)
        
        paddingConstraint.constant = CGFloat(space)
    }
    
    private func updateText() {
        if let text = textField.text {
            var attributes: [NSAttributedString.Key : Any] = [:]
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textField.textAlignment
            attributes[.font] = font
            attributes[.paragraphStyle] = paragraphStyle
            attributes[.foregroundColor] = textField.textColor
            attributes[.kern] = space
            textField.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
    }
    
    @objc private func textChanged(textField: UITextField) {
        updateText()
    }
}

extension SMSTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.count == 0 || textField.text?.count ?? 0 < textLimited
    }
}
