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
     
    var textview = UITextView()

    var label = UILabel(frame: CGRect(x: 300, y: 16, width: 200, height: 24))
    @Binding var text: String
    //@Binding var textviewHeight: CGFloat
    @Binding var currencyPlaceHolder: String
    var onCommit: () -> ()
    
     func makeUIView(context: Context) -> UITextView {
       
        
        label.text = currencyPlaceHolder
        label.textColor = .systemGray3
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        
        if let labelText = label.text {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(.kern, value: 2.0, range: NSRange(location: 0, length: attributedString.length))
            label.attributedText = attributedString
        }
        
//        let attributedText = textview.textStorage
//        attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 3))
//
        
         textview.addSubview(label)
         textview.textContainerInset = UIEdgeInsets(top: 16, left: 24.0 , bottom: 16, right: 32.0)
        
        textview.textColor = .gray
        textview.isScrollEnabled = false
        textview.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textview.backgroundColor =  UIColor(named: "textfield")
        textview.delegate = context.coordinator
        textview.showsVerticalScrollIndicator = false
        
 
        return textview
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.text = text
        label.text = currencyPlaceHolder
        
    }
    
    func makeCoordinator() -> CurrencyTextFieldCoordinator {
        return CurrencyTextFieldCoordinator(representable: self)
    }
    
    
}

class CurrencyTextFieldCoordinator: NSObject, UITextViewDelegate {
    
    var representable: CurrencyTextField
    
    init(representable: CurrencyTextField) {
        self.representable = representable
    }
    
    func textViewDidChange(_ textView: UITextView) {
       
        if let userText = textView.text {
            
            /*
            let sizeToFitIn = CGSize(width: textView.bounds.size.width, height: CGFloat(MAXFLOAT))
            let newSize = textView.sizeThatFits(sizeToFitIn)
            self.representable.textviewHeight = newSize.height*/
            
           // representable.label.text = nil

            representable.text = userText
            
            
        }
        
        /*
        if let userText = textView.text, userText.isEmpty {
            
             representable.label.text = "Add A task"
         }*/
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            
        // get the current text, or use an empty string if that failed
           let currentText = textView.text ?? ""

           // attempt to read the range they are trying to change, or exit if we can't
           guard let stringRange = Range(range, in: currentText) else { return false }

           // add their new text to the existing text
           let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

           // make sure the result is under 16 characters
           return updatedText.count <= 5
    }
 
}


 

struct CurrencyTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CurrencyTextField(text: .constant("500"), currencyPlaceHolder: .constant("NGN"), onCommit: {})
                .frame(height: 56)
        }
       // .padding(.horizontal, 32)
    }
}

extension UITextView {

    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }

}
