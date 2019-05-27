# SMSTextField

Subclass of `UITextField` with underline for sms verification code inputing

`UITextField`子类，用于短信验证码输入。支持定义字体、验证码长度、下划线颜色。

![Demo](./onetimecode.gif)

## Usage

Put `JHCodeTextField.swift` into your project, setup via sample codes below

```Swift
class ViewController: UIViewController {

    @IBOutlet weak var codeTextField: JHCodeTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeTextField.update(textLimited: 6, textColor: .blue, font: UIFont.systemFont(ofSize: 30), underlineColor: .darkGray)
    }
}
```

