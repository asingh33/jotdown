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
        pdfView = PDFView(frame: CGRect(x: 0, y: 60, width: width, height: height - 60))
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
        
        thumbnailView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        thumbnailView.thumbnailSize = CGSize(width: 15, height: 15)
        thumbnailView.layoutMode = .horizontal
   
        thumbnailView.backgroundColor = UIColor.systemGray2.withAlphaComponent(1.0)
    }
}

class PDFRenderer {
    let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
    var pdfRenderer: UIGraphicsPDFRenderer!
    var outputFileURL: URL!
    
    init() {
        pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)
    }
    
}

class Watermark: PDFPage {
    

//    override func draw(with box: PDFDisplayBox, to context: CGContext) {
//        // Draw a custom purple line.
//        UIGraphicsPushContext(context)
//        context.saveGState()
//
//
//        let path = UIBezierPath()
//        path.lineWidth = 10
//        path.move(to: CGPoint(x: bounds.minX + startPoint.x, y: bounds.minY + startPoint.y))
//        path.addLine(to: CGPoint(x: bounds.minX + endPoint.x, y: bounds.minY + endPoint.y))
//        UIColor.systemPurple.setStroke()
//        path.stroke()
//
//        context.restoreGState()
//        UIGraphicsPopContext()
//    }

    // 3. Override PDFPage custom draw
    /// - Tag: OverrideDraw
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        print("Watermark draw called")

        // Draw original content
        super.draw(with: box, to: context)

        // Draw rotated overlay string
        UIGraphicsPushContext(context)
        context.saveGState()

        let pageBounds = self.bounds(for: box)
        context.translateBy(x: 0.0, y: pageBounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: CGFloat.pi / 4.0)

        let string: NSString = "U s e r   3 1 4 1 5 9"
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 0.5),
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 64)
        ]

        string.draw(at: CGPoint(x: 250, y: 40), withAttributes: attributes)

        context.restoreGState()
        UIGraphicsPopContext()

    }
    
    
}

