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
    
    @IBOutlet weak var naviBarItem: UINavigationItem!
    var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        pdfView = PDFView(frame: self.view.frame)
        //pdfView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        self.view.addSubview(pdfView)
        pdfView.backgroundColor = UIColor.systemGray2
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPDFFile()
    }

    @IBAction func loadFile(_ sender: Any) {
        loadPDFFile()
    }
    
    func loadPDFFile(){
        
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
                self.naviBarItem.title = String(name[count - 1])
                if let document = PDFDocument(url: url){
                    self.pdfView.document = document
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

