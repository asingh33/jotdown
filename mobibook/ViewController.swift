//
//  ViewController.swift
//  mobibook
//
//  Created by ABHISHEK SINGH on 04/05/20.
//  Copyright © 2020 Abhishek Singh. All rights reserved.
//

import UIKit
import PDFKit

class ViewController: UIViewController, PDFDocumentDelegate {
    @IBOutlet weak var navigationBar: UINavigationBar!
    //@IBOutlet weak var layoutView: UIView!
    @IBOutlet weak var floatingBarView: UIView!
    @IBOutlet weak var pencilBtn: UIButton!
    @IBOutlet weak var markerBtn: UIButton!
    var stencilBtn : UIBarButtonItem!
    
    let radius: CGFloat = 20
    let borderWidth: CGFloat = 2
    var bToggle = false  // default pencil
    var cToggle = false
    
    //var pdfDocView: PDFDocView!
    var document : UIDocument!
    var pdfView : PDFView!
    var pdfDocView : PDFDocView!
    var pdfDocThumbNailView: PDFDocThumbNailView!
    var naviBarItem: UINavigationItem = UINavigationItem(title: "")
    //var pdfRenderer : PDFRenderer!
    var fileName : URL!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        loadPDFFile()
    }
    
    override func viewWillLayoutSubviews() {
        //setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //loadPDFFile()
    }
    
    
    
    private func setup(){
        //let width = self.view.frame.width
        //let height = self.view.frame.height

        let loadFileBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.organize, target: nil, action: #selector(Close))
        
        let renderBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: nil, action: #selector(saveFile))
        
        stencilBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: nil, action: #selector(toggleDraw))
        
        naviBarItem.leftBarButtonItems = [loadFileBtn, stencilBtn]
        naviBarItem.rightBarButtonItem = renderBtn
        
        navigationBar.setItems([naviBarItem], animated: false)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationBar.titleTextAttributes = textAttributes
        navigationBar.barStyle = UIBarStyle.black
        view.addSubview(navigationBar);
        
        //Add PDFView and PDFThumbNailView
        pdfDocView = PDFDocView()
        pdfView = pdfDocView.pdfView
        view.addSubview(pdfView)
        
        pdfView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        //self.floatingBarView.layer.zPosition = 1
        floatingBarView.isHidden = true
        self.view.bringSubviewToFront(floatingBarView)
        self.floatingBarView.layer.cornerRadius = 30
        self.floatingBarView.layer.borderWidth = 5
        floatingBarView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        //self.floatingBarView.layer.borderColor = CGColor(
        //view.addSubview(FloatingBarView)
        
        pdfDocThumbNailView = PDFDocThumbNailView()
        view.addSubview(pdfDocThumbNailView.thumbnailView)
        
        pdfDocThumbNailView.thumbnailView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfDocThumbNailView.thumbnailView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfDocThumbNailView.thumbnailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pdfDocThumbNailView.thumbnailView.pdfView = pdfView
        
        // For MenuItem setup
        let menuController: UIMenuController = UIMenuController.shared
        //menuController.setMenuVisible(true, animated: true)
        let highLightItem = UIMenuItem(title:"Highlight", action: #selector(highlightFromMenuItem))
        let underlineItem = UIMenuItem(title:"UnderLine", action: #selector(underlineFromMenuItem))
        let strikeoutItem = UIMenuItem(title:"StrikeOut", action: #selector(strikeoutFromMenuItem))
        menuController.menuItems = [highLightItem,underlineItem,strikeoutItem]
    }
    
    
    @objc func highlightFromMenuItem() {
        if let document = self.pdfView.document  {
           let pdfSelection : PDFSelection = PDFSelection(document: document)
            pdfSelection.add((self.pdfView?.currentSelection)!)
           let arrayByLines = self.pdfView?.currentSelection?.selectionsByLine()
               arrayByLines?.forEach({ (selection) in
                let annotation = PDFAnnotation(bounds: selection.bounds(for: (self.pdfView?.currentPage)!), forType: .highlight, withProperties: nil)
                   annotation.color = .yellow
                   self.pdfView?.currentPage?.addAnnotation(annotation)
               })
            }
    }
    
    @objc func underlineFromMenuItem() {
        if let document = self.pdfView.document  {
           let pdfSelection : PDFSelection = PDFSelection(document: document)
           pdfSelection.add((self.pdfView?.currentSelection)!)
           let arrayByLines = self.pdfView?.currentSelection?.selectionsByLine()
               arrayByLines?.forEach({ (selection) in
                let annotation = PDFAnnotation(bounds: selection.bounds(for: (self.pdfView?.currentPage)!), forType: .underline, withProperties: nil)
                   annotation.color = .green
                self.pdfView?.currentPage?.addAnnotation(annotation)
               })
            }
    }
    
    @objc func strikeoutFromMenuItem() {
        if let document = self.pdfView.document  {
           let pdfSelection : PDFSelection = PDFSelection(document: document)
           pdfSelection.add((self.pdfView?.currentSelection)!)
           let arrayByLines = self.pdfView?.currentSelection?.selectionsByLine()
               arrayByLines?.forEach({ (selection) in
                let annotation = PDFAnnotation(bounds: selection.bounds(for: (self.pdfView?.currentPage)!), forType: .strikeOut, withProperties: nil)
                   annotation.color = .blue
                   self.pdfView?.currentPage?.addAnnotation(annotation)
               })
            }
    }
    
    func loadPDFFile(){
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
                //self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
                if let doc = PDFDocument(url: (self.document?.fileURL.absoluteURL)!){
                    print("Loading document")
                    //document.delegate = self
                    self.pdfView.document = doc
                }
                else{
                    print("Unable to load")
                }
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    
    @objc func Close(){
        dismiss(animated: true) {
                   self.document?.close(completionHandler: nil)
               }
        
//        let picker = LoadFileViewController(
//            supportedTypes: ["com.adobe.pdf"],//["public.text"],
//            onPick: { url in
//                print("url : \(url)")
//                //self.pdfRenderer.outputFileURL = url
//                self.fileName = url
//
//                //var filePath : String = "/name.pdf"
//                let filePath = url.absoluteString
//                let name = filePath.split(separator: "/")
//                let count = name.count
//                //print(count)
//                //print(name[count-1])
//                self.naviBarItem.title = String(name[count - 1])
//
//                if let document = PDFDocument(url: url){
//                    //document.delegate = self
//                    self.pdfView.document = document
//                }
//
//            },
//            onDismiss: {
//                print("dismiss")
//            }
//        )
//
//        //picker.modalPresentationStyle = .fullScreen
//        picker.modalTransitionStyle = .coverVertical
//        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
    }
    
    private func toggleStencilState(){
        
        //set pencil
        pencilBtn.tintColor = bToggle ? UIColor.systemYellow : UIColor.systemGray
        //set marker
        markerBtn.tintColor = bToggle ? UIColor.systemGray : UIColor.systemYellow
        
        if(bToggle == true){
            pdfDocView.setWidth(width: 2)
        }else{
            pdfDocView.setWidth(width: 10)
        }
        
    }
    
    private func toggleColorState(sender: UIButton, color: UIColor){
        
        pdfDocView.setColor(color: color)
        
        if(cToggle){
            sender.layer.cornerRadius = radius
            sender.layer.borderWidth = borderWidth
            sender.layer.borderColor = UIColor.yellow.cgColor
        }else{
            sender.layer.cornerRadius = radius
            sender.layer.borderWidth = borderWidth
            sender.layer.borderColor = UIColor.yellow.withAlphaComponent(0).cgColor
        }
    }
    
    
    @objc func saveFile(){
        self.pdfView.document?.write(to: self.fileName)
    }
    
    @objc func toggleDraw(){
        if(stencilBtn.tintColor != UIColor.systemYellow){
            stencilBtn.tintColor = UIColor.systemYellow
            floatingBarView.isHidden = false
        }else{
            stencilBtn.tintColor = UIColor.systemBlue
            floatingBarView.isHidden = true
        }
        self.pdfDocView.changeDrawMode()
    }
    
    @IBAction func setPencil(_ sender: UIButton) {
        bToggle = true
        toggleStencilState()
    }
    
    @IBAction func setMarker(_ sender: UIButton) {
        bToggle = false
        toggleStencilState()
    }
    
    @IBAction func setWhiteColor(_ sender: UIButton) {
        cToggle = !cToggle
        toggleColorState(sender: sender, color: UIColor.white)
    }
    
    @IBAction func setBlueColor(_ sender: UIButton) {
        cToggle = !cToggle
        toggleColorState(sender: sender, color: UIColor.blue)
    }
    
    @IBAction func setBlackColor(_ sender: UIButton) {
        cToggle = !cToggle
        toggleColorState(sender: sender, color: UIColor.black)
    }
    @IBAction func setOrangeColor(_ sender: UIButton) {
        cToggle = !cToggle
        toggleColorState(sender: sender, color: UIColor.orange)
    }
    @IBAction func setRedColor(_ sender: UIButton) {
        cToggle = !cToggle
        toggleColorState(sender: sender, color: UIColor.red)
    }
    @IBAction func setPurpleColor(_ sender: UIButton) {
        cToggle = !cToggle
        toggleColorState(sender: sender, color: UIColor.purple)
    }
    @IBAction func setGreenColor(_ sender: UIButton) {
        cToggle = !cToggle
        toggleColorState(sender: sender, color: UIColor.green)
    }
    
    
    
    
    
    //    func classForPage() -> AnyClass {
//
//        //return Watermark.self
//
//        return Ink.self
//
//    }
//    func `class`(forAnnotationType annotationType: String) -> AnyClass {
//        //print(annotationType)
//        if annotationType == "Ink" {
//            return Ink.self
//        } else {
//            return PDFAnnotation.self
//        }
//    }

}

