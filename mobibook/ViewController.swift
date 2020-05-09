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
    
    //var pdfDocView: PDFDocView!
    var pdfView : PDFView!
    var pdfDocView : PDFDocView!
    var pdfDocThumbNailView: PDFDocThumbNailView!
    //var navigationBar: UINavigationBar!
    var naviBarItem: UINavigationItem = UINavigationItem(title: "")
    //var pdfRenderer : PDFRenderer!
    var fileName : URL!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillLayoutSubviews() {
        //setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPDFFile()
    }
    
    
    
    private func setup(){
        let width = self.view.frame.width
        let height = self.view.frame.height
//        navigationBar = UINavigationBar(frame: CGRect(x: self.view.safeAreaInsets.left, y: self.view.safeAreaInsets.top + 20, width: width, height: 30))
        

        let loadFileBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.organize, target: nil, action: #selector(loadPDFFile))
        
        let renderBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: nil, action: #selector(saveFile))
        
        let pencilBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: nil, action: #selector(toggleDraw))
        
        //naviBarItem.leftBarButtonItem = pencilBtn
        naviBarItem.leftBarButtonItems = [loadFileBtn, pencilBtn]
        naviBarItem.rightBarButtonItem = renderBtn
        //naviBarItem.leftBarButtonItem = loadFileBtn
        //naviBarItem.hidesBackButton = false
        navigationBar.setItems([naviBarItem], animated: false)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationBar.titleTextAttributes = textAttributes
        //navigationBar.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.4)
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
    
    @objc func loadPDFFile(){
        let picker = LoadFileViewController(
            supportedTypes: ["com.adobe.pdf"],//["public.text"],
            onPick: { url in
                print("url : \(url)")
                //self.pdfRenderer.outputFileURL = url
                self.fileName = url
                
                //var filePath : String = "/name.pdf"
                let filePath = url.absoluteString
                let name = filePath.split(separator: "/")
                let count = name.count
                //print(count)
                //print(name[count-1])
                self.naviBarItem.title = String(name[count - 1])
                
                if let document = PDFDocument(url: url){
                    //document.delegate = self
                    self.pdfView.document = document
                }
                
            },
            onDismiss: {
                print("dismiss")
            }
        )
        
        //picker.modalPresentationStyle = .fullScreen
        picker.modalTransitionStyle = .coverVertical
        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
    }
    
    @objc func saveFile(){
        self.pdfView.document?.write(to: self.fileName)
    }
    
    @objc func toggleDraw(){
        self.pdfDocView.changeDrawMode()
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

