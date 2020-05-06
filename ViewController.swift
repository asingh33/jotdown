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
    
    var pdfDocView: PDFDocView!
    var pdfDocThumbNailView: PDFDocThumbNailView!
    var navigationBar: UINavigationBar!
    var naviBarItem: UINavigationItem = UINavigationItem(title: "")
    var pdfRenderer : PDFRenderer!
    var fileName : URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillLayoutSubviews() {
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPDFFile()
    }
    
    private func setup(){
        let width = self.view.frame.width
        let height = self.view.frame.height
        navigationBar = UINavigationBar(frame: CGRect(x: self.view.safeAreaInsets.left, y: self.view.safeAreaInsets.top, width: width, height: 54))
        view.addSubview(navigationBar);

        let loadFileBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.organize, target: nil, action: #selector(loadPDFFile))
        
        pdfRenderer = PDFRenderer()
        
        let renderBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: nil, action: #selector(saveFile))
    
        naviBarItem.rightBarButtonItem = renderBtn
        naviBarItem.leftBarButtonItem = loadFileBtn
        navigationBar.setItems([naviBarItem], animated: false)
        //navigationBar.backgroundColor = UIColor.clear
        navigationBar.barStyle = UIBarStyle.black
        
        //Add PDFView and PDFThumbNailView
        pdfDocView = PDFDocView(width: width, height : height)
        view.addSubview(pdfDocView.pdfView)
        
        pdfDocThumbNailView = PDFDocThumbNailView()
        view.addSubview(pdfDocThumbNailView.thumbnailView)
        
        pdfDocThumbNailView.thumbnailView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfDocThumbNailView.thumbnailView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfDocThumbNailView.thumbnailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pdfDocThumbNailView.thumbnailView.pdfView = pdfDocView.pdfView
        
        // For MenuItem setup
        let menuController: UIMenuController = UIMenuController.shared
        //menuController.setMenuVisible(true, animated: true)
        let highLightItem = UIMenuItem(title:"Highlight", action: #selector(highlightFromMenuItem))
        let underlineItem = UIMenuItem(title:"UnderLine", action: #selector(underlineFromMenuItem))
        let strikeoutItem = UIMenuItem(title:"StrikeOut", action: #selector(strikeoutFromMenuItem))
        menuController.menuItems = [highLightItem,underlineItem,strikeoutItem]
    }
    
    
    @objc func highlightFromMenuItem() {
        if let document = self.pdfDocView.pdfView.document  {
           let pdfSelection : PDFSelection = PDFSelection(document: document)
           pdfSelection.add((self.pdfDocView.pdfView?.currentSelection)!)
           let arrayByLines = self.pdfDocView.pdfView?.currentSelection?.selectionsByLine()
               arrayByLines?.forEach({ (selection) in
                let annotation = PDFAnnotation(bounds: selection.bounds(for: (self.pdfDocView.pdfView?.currentPage)!), forType: .highlight, withProperties: nil)
                   annotation.color = .yellow
                   self.pdfDocView.pdfView?.currentPage?.addAnnotation(annotation)
               })
            }
    }
    @objc func underlineFromMenuItem() {
        if let document = self.pdfDocView.pdfView.document  {
           let pdfSelection : PDFSelection = PDFSelection(document: document)
           pdfSelection.add((self.pdfDocView.pdfView?.currentSelection)!)
           let arrayByLines = self.pdfDocView.pdfView?.currentSelection?.selectionsByLine()
               arrayByLines?.forEach({ (selection) in
                let annotation = PDFAnnotation(bounds: selection.bounds(for: (self.pdfDocView.pdfView?.currentPage)!), forType: .underline, withProperties: nil)
                   annotation.color = .green
                   self.pdfDocView.pdfView?.currentPage?.addAnnotation(annotation)
               })
            }
    }
    @objc func strikeoutFromMenuItem() {
        if let document = self.pdfDocView.pdfView.document  {
           let pdfSelection : PDFSelection = PDFSelection(document: document)
           pdfSelection.add((self.pdfDocView.pdfView?.currentSelection)!)
           let arrayByLines = self.pdfDocView.pdfView?.currentSelection?.selectionsByLine()
               arrayByLines?.forEach({ (selection) in
                let annotation = PDFAnnotation(bounds: selection.bounds(for: (self.pdfDocView.pdfView?.currentPage)!), forType: .strikeOut, withProperties: nil)
                   annotation.color = .blue
                   self.pdfDocView.pdfView?.currentPage?.addAnnotation(annotation)
               })
            }
    }
    
    @objc func loadPDFFile(){
        let picker = DocumentPickerViewController(
            supportedTypes: ["com.adobe.pdf"],//["public.text"],
            onPick: { url in
                print("url : \(url)")
                self.pdfRenderer.outputFileURL = url
                self.fileName = url
                
                //var filePath : String = "/name.pdf"
                let filePath = url.absoluteString
                let name = filePath.split(separator: "/")
                let count = name.count
                //print(count)
                //print(name[count-1])
                self.navigationItem.title = String(name[count - 1])
                if let document = PDFDocument(url: url){
                    //document.delegate = self
                    self.pdfDocView.pdfView.document = document
                    //self.pdfDocView.pdfView.documentView?.backgroundColor = UIColor.red
                    
                }
                
            },
            onDismiss: {
                print("dismiss")
            }
        )
        
        //picker.modalPresentationStyle = .
        picker.modalTransitionStyle = .coverVertical
        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
    }
    
    @objc func saveFile(){
        self.pdfDocView.pdfView.document?.write(to: self.fileName)
    }
    
    func classForPage() -> AnyClass {
        
        return Watermark.self
        
    }

}

