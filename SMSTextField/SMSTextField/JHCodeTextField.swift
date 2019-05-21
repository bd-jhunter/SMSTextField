//
//  JHCodeTextField.swift
//  SMSTextField
//
//  Created by jhunter on 2019/5/9.
//  Copyright © 2019 com.jh. All rights reserved.
//

import UIKit

struct JHCodeTextFieldConfig {
    var textLimited: Int
    var font: UIFont
    var textColor: UIColor
}

private class JHCodeCharacterView: UIView {
    
    // MARK: - Properties
    var config: JHCodeTextFieldConfig {
        didSet {
            if oldValue.textLimited != config.textLimited {
                setupView()
            } else {
                updateView()
            }
        }
    }
    
    var text: String {
        get {
            guard contentView != nil && contentView.arrangedSubviews.count > 0 else { return "" }
            var ret = ""
            let texts = contentView.arrangedSubviews.map({($0 as? UILabel)?.text ?? ""})
            ret = texts.joined()
            return ret
        }
        
        set {
            let lables = contentView.arrangedSubviews
            var index = 0
            for character in newValue {
                var attributes: [NSAttributedString.Key : Any] = [:]
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                attributes[.font] = config.font
                attributes[.paragraphStyle] = paragraphStyle
                attributes[.foregroundColor] = config.textColor
                let attribuesString = NSAttributedString(string: String(character), attributes: attributes)
                if let label = lables[index] as? UILabel {
                    label.attributedText = attribuesString
                }
                
                index += 1
                if index >= lables.count {
                    break
                }
            }
            
            for leftLableIndex in index..<lables.count {
                if let label = lables[leftLableIndex] as? UILabel {
                    label.text = ""
                }
            }
        }
    }
    
    private weak var contentView: UIStackView!
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        config = JHCodeTextFieldConfig(textLimited: 4, font: UIFont.systemFont(ofSize: 14.0), textColor: .black)
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        config = JHCodeTextFieldConfig(textLimited: 4, font: UIFont.systemFont(ofSize: 14.0), textColor: .black)
        super.init(coder: aDecoder)
        isUserInteractionEnabled = false
    }
    
    // MARK: - Public methods
    class func view(_ config: JHCodeTextFieldConfig) -> JHCodeCharacterView {
        return JHCodeCharacterView(frame: .zero)
    }
    
    // MARK: - Private methods
    private func setupView() {
        let stackView: UIStackView
        if contentView == nil {
            stackView = {
                $0.axis = .horizontal
                $0.alignment = .fill
                $0.distribution = .fillEqually
                addSubview($0)
                
                $0.translatesAutoresizingMaskIntoConstraints = false
                var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[stackView]-(0)-|", options: [], metrics: nil, views: ["stackView": $0])
                addConstraints(constraints)
                constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[stackView]-(0)-|", options: [], metrics: nil, views: ["stackView": $0])
                addConstraints(constraints)

                return $0
            }(UIStackView(frame: .zero))
            contentView = stackView
        } else {
            stackView = contentView
            for subView in stackView.arrangedSubviews {
                subView.removeFromSuperview()
            }
        }
        
        for _ in 0..<config.textLimited {
            let label: UILabel = {
                $0.textAlignment = .center
                $0.textColor = config.textColor
                $0.font = config.font
                return $0
            }(UILabel(frame: .zero))
            contentView.addArrangedSubview(label)
        }
    }
    
    private func updateView() {
        guard let contentView = contentView else { return }

        for subView in contentView.arrangedSubviews {
            if let label = subView as? UILabel {
                label.textColor = config.textColor
                label.font = config.font
            }
        }
    }
}

// MARK: - Disable user menu
class JHInnerTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
}

class JHCodeTextField: UIView {
    
    // MARK: - Properties
    var textLimited: Int {
        get { return characterView.config.textLimited }
    }
    
    var textColor: UIColor {
        get { return characterView.config.textColor }
    }
    
    var font: UIFont {
        get { return characterView.config.font }
    }
    
    var underlineColor: UIColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var underlineSpace: Float = 18.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var keyboardType: UIKeyboardType {
        get { return innerTextField.keyboardType }
        set { innerTextField.keyboardType = newValue }
    }
    
    private weak var characterView: JHCodeCharacterView!
    private weak var innerTextField: JHInnerTextField!
    private weak var underlineLayer: CALayer?
    private weak var underlineShapeLayer: CAShapeLayer?

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
    override init(frame: CGRect) {
        underlineColor = .darkGray
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        underlineColor = .darkGray
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUnderline()
    }
    
    // MARK: - Public methods
    func update(textLimited: Int?, textColor: UIColor?, font: UIFont?, underlineColor: UIColor?) {
        var updateText = false
        var config = characterView.config
        if let textLimited = textLimited {
            config.textLimited = textLimited
            updateText = true
        }
        if let textColor = textColor {
            config.textColor = textColor
            updateText = true
        }
        if let font = font {
            config.font = font
            updateText = true
            innerTextField.font = font
        }
        if updateText {
            characterView.config = config
        }
        if let underlineColor = underlineColor {
            self.underlineColor = underlineColor
        }
        
        setNeedsDisplay()
    }
    
    // MARK: - Private methods
    private func setupView() {
        let textField: JHInnerTextField = {
            addSubview($0)
            $0.borderStyle = .none
            $0.textAlignment = .left
            $0.tintColor = .white
            $0.textColor = .clear
            $0.font = UIFont.systemFont(ofSize: 14.0)
            $0.keyboardType = .numberPad
            
            if #available(iOS 12.0, *) {
                $0.textContentType = .oneTimeCode
            }
            
            $0.delegate = self
            $0.addTarget(self, action: #selector(textChanged(textField:)), for: .editingChanged)

            
            $0.translatesAutoresizingMaskIntoConstraints = false
            var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[textField]-(0)-|",
                                                         options: [],
                                                         metrics: nil,
                                                         views: ["textField": $0])
            addConstraints(constraints)
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[textField]-(3)-|",
                                                             options: [],
                                                             metrics: nil,
                                                             views: ["textField": $0])
            addConstraints(constraints)

            return $0
        }(JHInnerTextField(frame: .zero))
        self.innerTextField = textField
        
        let characterView = JHCodeCharacterView(frame: .zero)
        self.characterView = characterView
        addSubview(characterView)
        characterView.translatesAutoresizingMaskIntoConstraints = false
        var constraint = NSLayoutConstraint(item: characterView, attribute: .width, relatedBy: .equal, toItem: textField, attribute: .width, multiplier: 1.0, constant: 0.0)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: characterView, attribute: .height, relatedBy: .equal, toItem: textField, attribute: .height, multiplier: 1.0, constant: 0.0)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: characterView, attribute: .centerX, relatedBy: .equal, toItem: textField, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: characterView, attribute: .centerY, relatedBy: .equal, toItem: textField, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        addConstraint(constraint)
    }
    
    private func updateUnderline() {
        let rect = bounds
        let baseWidth = Float(rect.width) / Float(textLimited)
        if underlineShapeLayer == nil {
            let underlineLayer = CAShapeLayer()
            underlineShapeLayer = underlineLayer
            layer.addSublayer(underlineLayer)
            underlineLayer.strokeColor = underlineColor.cgColor
            underlineLayer.fillColor = UIColor.clear.cgColor
            underlineLayer.lineCap = .round
            underlineLayer.lineWidth = 2.0
        }
        let path = CGMutablePath()
        path.move(to: CGPoint(x: CGFloat(underlineSpace / 2.0), y: rect.origin.y + rect.size.height - 2.0))
        path.addLine(to: CGPoint(x: rect.size.width - CGFloat(underlineSpace / 2.0), y: rect.origin.y + rect.size.height - 2.0))
        underlineShapeLayer?.path = path
        underlineShapeLayer?.lineDashPattern = [NSNumber(value: baseWidth - underlineSpace), NSNumber(value: underlineSpace)]
    }
    
    private func updateText() {
        characterView.text = innerTextField.text ?? ""
    }
    
    @objc private func textChanged(textField: UITextField) {
        updateText()
    }
}

// MARK: - UITextFieldDelegate
extension JHCodeTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        
        let newLength = (textField.text?.count ?? 0) + string.count - range.length
        return newLength <= textLimited
    }
}
