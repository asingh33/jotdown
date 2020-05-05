//
//  ViewController.swift
//  mobibook
//
//  Created by ABHISHEK SINGH on 04/05/20.
//  Copyright © 2020 Abhishek Singh. All rights reserved.
//

import UIKit
import PDFKit

class ViewController: UIViewController {
    
    var pdfDocView: PDFDocView!
    var pdfDocThumbNailView: PDFDocThumbNailView!
    var navigationBar: UINavigationBar!
    var naviBarItem: UINavigationItem = UINavigationItem(title: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillLayoutSubviews() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        navigationBar = UINavigationBar(frame: CGRect(x: self.view.safeAreaInsets.left, y: self.view.safeAreaInsets.top, width: width, height: 54))
        view.addSubview(navigationBar);

        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.organize, target: nil, action: #selector(loadPDFFile))
    
        naviBarItem.leftBarButtonItem = doneBtn
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPDFFile()
    }
    
    @objc func loadPDFFile(){
        
        let picker = DocumentPickerViewController(
            supportedTypes: ["com.adobe.pdf"],//["public.text"],
            onPick: { url in
                print("url : \(url)")
                //var filePath : String = "/name.pdf"
                let filePath = url.absoluteString
                let name = filePath.split(separator: "/")
                let count = name.count
                //print(count)
                //print(name[count-1])
                self.navigationItem.title = String(name[count - 1])
                if let document = PDFDocument(url: url){
                    self.pdfDocView.pdfView.document = document
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

}

