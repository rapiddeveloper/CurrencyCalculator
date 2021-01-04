//
//  CurrencyTextfield.swift
//  CowrywiseCC
//
//  Created by Admin on 12/24/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
//

//
//  PersonalTodoTextField.swift
//  PersonalToDo
//
//  Created by Admin on 11/2/20.
//  Copyright © 2020 rapid interactive. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class CustomTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0);
    var width: CGFloat = 0
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rightBounds = CGRect(x: bounds.maxX - 76 , y: bounds.origin.y, width: bounds.width, height: bounds.height)
        return rightBounds
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}

 

class InsetLabel: UILabel {

    var contentInsets = UIEdgeInsets.zero

    override func drawText(in rect: CGRect) {
        let insetRect = UIEdgeInsetsInsetRect(rect, contentInsets)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        return addInsets(to: super.intrinsicContentSize)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return addInsets(to: super.sizeThatFits(size))
    }

    private func addInsets(to size: CGSize) -> CGSize {
        let width = size.width + contentInsets.left + contentInsets.right
        let height = size.height + contentInsets.top + contentInsets.bottom
        return CGSize(width: width, height: height)
    }

}

struct CurrencyTextField: UIViewRepresentable {
    
 
    var textField = CustomTextField(frame: .zero) //UITextField(frame: .zero)
    @Binding var text: String
  
    var currencyPlaceHolder: String
    //var width: CGFloat
    var onCommit: () -> ()
    
     func makeUIView(context: Context) -> UITextField {
        
        let label = UILabel(frame: .zero)
        label.textColor = .systemGray3
        label.font =  UIFont.boldSystemFont(ofSize: 24)
        label.text = currencyPlaceHolder
        label.tag = 1
        label.sizeToFit()
 
        if let labelText = label.text {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(.kern, value: 2.0, range: NSRange(location: 0, length: attributedString.length))
            label.attributedText = attributedString
        }
        
//        let attributedText = textview.textStorage
//        attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 3))
//
        // prevent textfield from stretching
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.keyboardType = .numberPad
      
        textField.text = text
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
       
        textField.rightViewMode = .always
        textField.rightView = label
        
        textField.textColor = .gray
        textField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textField.backgroundColor = UIColor(named: "textfield")
        textField.delegate = context.coordinator
 
        return textField
    }
    
    func updateUIView(_ textView: UITextField, context: Context) {
         textView.text = text
       

      

    }
    
    func makeCoordinator() -> CurrencyTextFieldCoordinator {
        return CurrencyTextFieldCoordinator(representable: self)
    }
    
    
}

class CurrencyTextFieldCoordinator: NSObject, UITextFieldDelegate {
    
    var representable: CurrencyTextField
    
    init(representable: CurrencyTextField) {
        self.representable = representable
    }
    
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if let userText = textField.text {
            representable.text = userText
            
        }
    }
 
}

extension UITextField {
    
    func setLeftPadding(padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    func setRightPadding(padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

 

 
 


 

struct CurrencyTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
          
           // GeometryReader { proxy in
//            CurrencyTextField(text: .constant("500"), currencyPlaceHolder: "NGN", width: 360, onCommit: {})
            CurrencyTextField(text: .constant("500"), currencyPlaceHolder: "NGN", onCommit: {})
                    .cornerRadius(5)
                    .frame(width: 350, height: 56)
            //}
        }
        .previewDevice("iPhone8")
        // .padding(.horizontal, 16)
       
    }
   
}

 
