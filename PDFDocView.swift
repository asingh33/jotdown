//
//  PDFDocView.swift
//  mobibook
//
//  Created by ABHISHEK SINGH on 05/05/20.
//  Copyright © 2020 Abhishek Singh. All rights reserved.
//

import Foundation
import PDFKit

class PDFDocView {
    var pdfView : PDFView!
    
    init(width: CGFloat, height: CGFloat) {
        pdfView = PDFView(frame: CGRect(x: 0, y: 60, width: width, height: height))
        //pdfView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        pdfView.autoScales = true
        pdfView.backgroundColor = UIColor.systemGray2
    }
}

class PDFDocThumbNailView {
    var thumbnailView: PDFThumbnailView!
    
    init(){
        
        thumbnailView = PDFThumbnailView()
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        
        thumbnailView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        thumbnailView.thumbnailSize = CGSize(width: 40, height: 40)
        thumbnailView.layoutMode = .horizontal
   
        thumbnailView.backgroundColor = UIColor.systemGray2.withAlphaComponent(1.0)
    }
}
