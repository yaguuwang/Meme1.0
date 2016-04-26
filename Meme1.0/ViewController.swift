//
//  ViewController.swift
//  Meme1.0
//
//  Created by 王浩宇 on 16/4/26.
//  Copyright © 2016年 yaguuwang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    struct Meme {
        let topText: String!
        let bottomText: String!
        let originalImage: UIImage!
        let memeImage: UIImage!
    }
    
    // IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    // Custom meme font style
    let memeFontSyleDefault = [NSStrokeColorAttributeName : UIColor.blackColor(), NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!, NSStrokeWidthAttributeName : -3.0]
    
    let memeFontSyleRedOutline = [NSStrokeColorAttributeName : UIColor.redColor(), NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "ChalkboardSE-Bold", size: 40)!, NSStrokeWidthAttributeName : -3.0]
    
    let memeFontSyleBlueOutline = [NSStrokeColorAttributeName : UIColor.blueColor(), NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "Baskerville-Bold", size: 40)!, NSStrokeWidthAttributeName : -3.0]
    
    let defaultAlertStyle = UIAlertActionStyle.Default
    let cancelAlertStyle = UIAlertActionStyle.Cancel
    
    override func viewWillAppear(animated: Bool) {
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        shareButton.enabled = false
        if imageView.image != nil {
            shareButton.enabled = true
        }
        
        topTextField.delegate = self
        topTextField.defaultTextAttributes = memeFontSyleDefault
        topTextField.textAlignment = NSTextAlignment.Center
        topTextField.attributedPlaceholder = NSAttributedString(string: "TOP", attributes: memeFontSyleDefault)
        
        bottomTextField.delegate = self
        bottomTextField.defaultTextAttributes = memeFontSyleDefault
        bottomTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: memeFontSyleDefault)
        
        subscribeToKeyboardWillAppearOrDisappear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeFromKeyboardWillAppearOrDisappear()
    }
    
    // IBActions
    
    // launch image picking view
    @IBAction func albumButton(sender: AnyObject) {
        let nextController = UIImagePickerController()
        nextController.delegate = self
        nextController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(nextController, animated: true, completion: nil)
    }
    
    // launch camera
    @IBAction func cameraButton(sender: AnyObject) {
        let nextController = UIImagePickerController()
        nextController.delegate = self
        nextController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(nextController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.delegate = self
        textField.resignFirstResponder()
        return true
    }
    
    
    // passing chosen image to imageview
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // reset imageview.image to nil
    @IBAction func cancelButton(sender: AnyObject) {
        imageView.image = nil
        shareButton.enabled = false
    }
    
    @IBAction func fontChangeButton(sender: AnyObject) {
        let preferredStyle = UIAlertControllerStyle.ActionSheet
        let nextController = UIAlertController(title: "Choose a font", message: nil, preferredStyle:preferredStyle)
        
        let defaultFont = UIAlertAction(title: "Default font", style: defaultAlertStyle, handler: {
            action in
            self.topTextField.defaultTextAttributes = self.memeFontSyleDefault
            self.topTextField.textAlignment = NSTextAlignment.Center
            self.topTextField.attributedPlaceholder = NSAttributedString(string: "TOP", attributes: self.memeFontSyleDefault)
            self.bottomTextField.defaultTextAttributes = self.memeFontSyleDefault
            self.bottomTextField.textAlignment = NSTextAlignment.Center
            self.bottomTextField.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: self.memeFontSyleDefault)
        })
        
        let redOutlineFont = UIAlertAction(title: "Red Outline", style: defaultAlertStyle, handler: {
            action in
            self.topTextField.defaultTextAttributes = self.memeFontSyleRedOutline
            self.topTextField.textAlignment = NSTextAlignment.Center
            self.topTextField.attributedPlaceholder = NSAttributedString(string: "TOP", attributes: self.memeFontSyleRedOutline)
            self.bottomTextField.defaultTextAttributes = self.memeFontSyleRedOutline
            self.bottomTextField.textAlignment = NSTextAlignment.Center
            self.bottomTextField.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: self.memeFontSyleRedOutline)
        })
        
        let blueOutlineFont = UIAlertAction(title: "Blue Outline", style: defaultAlertStyle, handler: {
            action in
            self.topTextField.defaultTextAttributes = self.memeFontSyleBlueOutline
            self.topTextField.textAlignment = NSTextAlignment.Center
            self.topTextField.attributedPlaceholder = NSAttributedString(string: "TOP", attributes: self.memeFontSyleBlueOutline)
            self.bottomTextField.defaultTextAttributes = self.memeFontSyleBlueOutline
            self.bottomTextField.textAlignment = NSTextAlignment.Center
            self.bottomTextField.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: self.memeFontSyleBlueOutline)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: cancelAlertStyle, handler: nil)
        
        nextController.addAction(defaultFont)
        nextController.addAction(redOutlineFont)
        nextController.addAction(blueOutlineFont)
        nextController.addAction(cancelButton)
        self.presentViewController(nextController, animated: true, completion: nil)
    }
    
    @IBAction func shareButton(sender: AnyObject) {
        let memeImage = generateMemeImage()
        let nextController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        self.presentViewController(nextController, animated: true, completion: {
            action in
            self.save()
        })
    }
    
    
    
    func subscribeToKeyboardWillAppearOrDisappear() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillDisappear), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardWillAppearOrDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillAppear(notification: NSNotification) {
        if topTextField.editing {
            self.view.frame.origin.y = 0
        } else {
            self.view.frame.origin.y -= getHeightOfKeyboard(notification)
        }
    }
    
    func keyboardWillDisappear() {
        self.view.frame.origin.y = 0
    }
    
    func getHeightOfKeyboard(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let size = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return size.CGRectValue().height
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        textField.text = textField.text?.uppercaseStringWithLocale(nil)
        return true
    }
    
    func generateMemeImage() -> UIImage {
        //UIGraphicsBeginImageContext(self.view.frame.size)
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, CGFloat(5.0))
        self.topToolbar.hidden = true
        self.bottomToolbar.hidden = true
        self.view.drawViewHierarchyInRect(self.imageView.frame, afterScreenUpdates: true)
        let memeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.topToolbar.hidden = false
        self.bottomToolbar.hidden = false
        return memeImage
    }
    
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text, originalImage: imageView.image, memeImage: generateMemeImage())
    }
    
}

