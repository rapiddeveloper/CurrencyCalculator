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

struct CurrencyTextField: UIViewRepresentable {
    
 
    var textview = UITextField(frame: .zero)
    
  //  var label = UILabel(frame: CGRect(x: width * 0.7, y: 14, width: 72, height: 24))
    @Binding var text: String
  
    var currencyPlaceHolder: String
    //var width: CGFloat
    var onCommit: () -> ()
    
     func makeUIView(context: Context) -> UITextField {
        
       // let label = UILabel(frame: CGRect(x: width - 72, y: 14, width: 72, height: 24))
        
        let label = UILabel(frame: CGRect(x: textview.frame.size.width, y: 14, width: 72, height: 24))
         
        label.textColor = .systemGray3
        label.font = UIFont(name: "MontserratAlternates-SemiBold", size: 24)
        label.text = currencyPlaceHolder

        label.tag = 1
 
        if let labelText = label.text {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(.kern, value: 2.0, range: NSRange(location: 0, length: attributedString.length))
            label.attributedText = attributedString
        }
        
//        let attributedText = textview.textStorage
//        attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 3))
//
        textview.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textview.keyboardType = .numberPad
      
        textview.text = text
        textview.clearButtonMode = .whileEditing
        textview.returnKeyType = .done
       // textview.setRightPadding(padding: 72)
        //textview.setRightPadding(padding: 16)

        textview.setLeftPadding(padding: 16)
        textview.addSubview(label)
        
        textview.textColor = .gray
         textview.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textview.backgroundColor = UIColor(named: "textfield")
        textview.delegate = context.coordinator

 
        return textview
    }
    
    func updateUIView(_ textView: UITextField, context: Context) {
         textView.text = text
       

        for subview in textView.subviews {
            if subview.tag == 1 {
                let label = subview as! UILabel
                label.text = currencyPlaceHolder
                print(textview.frame.size.width)
                label.frame = CGRect(x: textview.frame.size.width, y: 14, width: 72, height: 24)
            }
        }

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
        print(textField.text!)
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

 
