//
//  OtpFieldView.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 18/03/26.
//

import Combine
import SwiftUI

public struct OTPInput: View {
    @Binding var text: String
    var digitCount: Int

    var numericOnly: Bool = false
    var isSecure: Bool = false
    
    var entrySize: CGSize = .init(width: 48, height: 48)
    var lineWidth: CGFloat = 2
    var spacing: CGFloat = 8
    var backgroundColor: Color = ThemeColor.lightBackground.color

    @FocusState private var focusedInput: Int?
    
    public init(text: Binding<String>, digitCount: Int, numericOnly: Bool = false, entrySize: CGSize = .init(width: 48, height: 48)) {
        self._text = text
        self.digitCount = digitCount
        self.numericOnly = numericOnly
        self.entrySize = entrySize
    }

    public var body: some View {
        HStack(spacing: self.spacing) {
            ForEach(0..<digitCount, id: \.self, content: { index in
                _UITextFieldRepresentable(
                    fullText: $text,
                    numericOnly: self.numericOnly,
                    isSecure: self.isSecure,
                    index: index,
                    digitCount: self.digitCount,
                    setText: { string in
                        self.setTextAtIndex(string, at: index)
                    },
                    enterKeyPressed: {
                        self.enterKeyPressed()
                    },
                    emptyBackspaceKeyPressed: {
                        self.emptyBackspaceKeyPressed()
                    }
                )
                .frame(width: self.entrySize.width, height: self.entrySize.height, alignment: .center)
                .background(
                    backgroundColor
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                )
                .tag(index)
                .focused($focusedInput, equals: index)
            })
        }
        .onChange(of: focusedInput, {
            if focusedInput ?? 0 > text.count {
                focusedInput = text.count
            }
        })
    }
   
    
    private func setTextAtIndex(_ string: String, at index: Int) {
      
        let old = self.text
 
        let strBefore = old._prefix(index)
        let suffixLength = old.count - index - (string.isEmpty ? 1 : string.count)
        
        let strAfter = suffixLength <= 0 ? "" : old._suffix(suffixLength)
        
        var entry = string.removeNewlineWhitespaces
        if numericOnly {
            entry = entry.numericOnly
        }
        let new = (strBefore + entry + strAfter)._prefix(self.digitCount)

        self.text = new

        guard let focusedInput = self.focusedInput else {
            return
        }

        // change of an entered text
        if focusedInput <= old.count - 1 {
            // if delete, move to the previous one
            // else move to the one after inputting the string
            let newFocus = focusedInput + (string.isEmpty ? -1 : string.count)

            // if last entry is entered, remove all the focus
            self.focusedInput = newFocus >= digitCount ? nil : newFocus
            return
        }
        
        
        // entry on empty textfield
        let newFocus = new.count
        if newFocus >= digitCount {
            self.focusedInput = nil
            return
        }
        
        self.focusedInput = newFocus

    }
    
    private func enterKeyPressed() {
        self.focusedInput = nil
    }
    
    private func emptyBackspaceKeyPressed() {
        guard let focusedInput = self.focusedInput, focusedInput > 0 else {
            return
        }
        self.focusedInput = focusedInput - 1
    }

}

private struct _UITextFieldRepresentable: UIViewRepresentable {
    
    @Binding var fullText: String
    var numericOnly: Bool
    var isSecure: Bool

    var index: Int
    var digitCount: Int
    var setText: ((String) -> Void)
    var enterKeyPressed: (() -> Void)
    var emptyBackspaceKeyPressed: (() -> Void)

    func makeUIView(context: Context) -> UITextField {
        let textField = _UITextField()
        textField.emptyBackspaceKeyPressed = emptyBackspaceKeyPressed
        textField.text = self.getText()
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.clearButtonMode = .never
        textField.autocorrectionType = .no

        textField.keyboardType = self.numericOnly ? .numberPad : .default
        textField.isSecureTextEntry = self.isSecure
        
        setSelection(textField)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = self.getText()
        self.setSelection(uiView)
        
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    
    func setSelection(_ textField: UITextField) {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    
    func getText() -> String {
        if self.fullText.count <= self.index {
            return ""
        }
        return self.fullText.strAtIndex(self.index)
    }
}

extension _UITextFieldRepresentable {
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: _UITextFieldRepresentable
        
        private var shouldChangeTriggered = false

        init(_ control: _UITextFieldRepresentable) {
            self.parent = control
            super.init()
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // to disable new line or text clear when there is a selection on return key pressed
            self.parent.enterKeyPressed()
            return false
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.parent.setSelection(textField)
        }

        // to disable deselecting from using keyboard <- and ->
        func textFieldDidChangeSelection(_ textField: UITextField) {
            self.parent.setSelection(textField)
        }
        
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            self.parent.setText(string)
            return false
        }
    }
}


private class _UITextField: UITextField {
    var emptyBackspaceKeyPressed: (() -> Void)?

    override func deleteBackward() {
        if text?.isEmpty == true {
            emptyBackspaceKeyPressed?()
        }
        super.deleteBackward()
    }
}



private extension String {

    func _prefix(_ length: Int) -> String {
        return String(self.prefix(length))
    }
    func _suffix(_ length: Int) -> String {
        return String(self.suffix(length))
    }
    
    var removeNewlineWhitespaces: String {
        return self.filter({!$0.isWhitespace && !$0.isNewline})
    }
    
    var numericOnly: String {
        return self.filter({ $0.isNumber })
    }
    
    func strAtIndex(_ int: Int) -> String {
        if int >= self.count { return "" }
        let stringIndex = self.toStringIndex(int)
        return String(self[stringIndex])
    }

    func toStringIndex(_ int: Int) -> String.Index {
        if int <= 0 {
            return self.startIndex
        }
        if int >= self.count {
            return self.endIndex
        }
        return self.index(self.startIndex, offsetBy: int)
    }
}

#Preview {
    @Previewable @State var test: String = ""
    OTPInput(text: $test, digitCount: 6)
}
