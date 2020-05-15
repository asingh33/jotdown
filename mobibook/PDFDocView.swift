//
//  PDFDocView.swift
//  mobibook
//
//  Created by ABHISHEK SINGH on 05/05/20.
//  Copyright © 2020 Abhishek Singh. All rights reserved.
//

import Foundation
import PDFKit

class mobiPDFView: PDFView {
// Disable selection
//  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//    return false
//  }
//  override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
//    if gestureRecognizer is UILongPressGestureRecognizer {
//      gestureRecognizer.isEnabled = false
//    }
//    super.addGestureRecognizer(gestureRecognizer)
//  }
}

class PDFDocView {
    var pdfView : mobiPDFView!
    private let pdfDrawer = PageDrawer()
    private let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
    
    //init(width: CGFloat, height: CGFloat)
    init(){
        
        self.pdfView = mobiPDFView()
        self.pdfView.backgroundColor = UIColor.systemGray2
        self.pdfView.translatesAutoresizingMaskIntoConstraints = false
        self.pdfView.autoScales = false
        self.pdfView.usePageViewController(true)
        self.pdfView.maxScaleFactor = 3
        
        self.pdfView.addGestureRecognizer(pdfDrawingGestureRecognizer)
        pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
        pdfDrawingGestureRecognizer.isEnabled = true
        pdfDrawingGestureRecognizer.cancelsTouchesInView = false
        self.pdfView.isUserInteractionEnabled = true
        pdfDrawer.pdfView = self.pdfView
        
    }
    
    func changeDrawMode(){
        pdfDrawingGestureRecognizer.toggleDraw = !pdfDrawingGestureRecognizer.toggleDraw
    }
    
    func setColor(color: UIColor){
        //self.color = color
        pdfDrawer.setColor(color: color)
    }
    func setWidth(width : CGFloat){
        pdfDrawer.setWidth(width: width)
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
    
    var pdfRenderer: UIGraphicsPDFRenderer!
    var outputFileURL: URL!
    
    init(width: CGFloat, height: CGFloat) {
        //let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let pageRect = CGRect(x: 0, y: 0, width: width, height: height)
        pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)
    }
}


class PageDrawer:  DrawingGestureRecognizerDelegate{
    weak var pdfView: PDFView!
    
    private var path: UIBezierPath?
    private var allpath: UIBezierPath?
    private var inkAnnotation : Ink?
    private var color : UIColor = UIColor.black
    private var width : CGFloat = 2
    private var currentpage: PDFPage?
    var pathMap : [ String: UIBezierPath] = [:]
    var inkMap: [String : Ink] = [:]
    
    func setColor(color: UIColor){
        self.color = color
    }
    func setWidth(width : CGFloat){
        self.width = width
    }
    
    func gestureRecognizerBegan(_ location: CGPoint) {
        
        currentpage = pdfView.currentPage
        let inPagePoint = pdfView.convert(location, to: currentpage!)
        
        // More realistic color effect but memory consuming
//        path = UIBezierPath()
//        inkAnnotation = Ink(bounds: (currentpage?.bounds(for: pdfView.displayBox))!, forType: PDFAnnotationSubtype.ink, withProperties: nil)
//        pathMap[(currentpage?.label)!] = path!
//        inkMap[(currentpage?.label)!] = inkAnnotation!
        
        if(inkMap[(currentpage?.label)!] == nil){
            path = UIBezierPath()
            inkAnnotation = Ink(bounds: (currentpage?.bounds(for: pdfView.displayBox))!, forType: PDFAnnotationSubtype.ink, withProperties: nil)
            pathMap[(currentpage?.label)!] = path!
            inkMap[(currentpage?.label)!] = inkAnnotation!
            //print("in page - \(currentpage.label!)")
        }
        else{
            //For a changed StencilWidth OR StencilColor, create new annotation and path
            if(inkAnnotation?.getStencilColor() != color || inkAnnotation?.getStencilWidth() != width){
                //print("in page - \(currentpage.label!), created new Annotation")
                path = UIBezierPath()
                inkAnnotation = Ink(bounds: (currentpage?.bounds(for: pdfView.displayBox))!, forType: PDFAnnotationSubtype.ink, withProperties: nil)
                pathMap[(currentpage?.label)!] = path!
                inkMap[(currentpage?.label)!] = inkAnnotation!
            }
            inkAnnotation = inkMap[(currentpage?.label)!]
            path = pathMap[(currentpage?.label)!]
        }
        
        path?.move(to: inPagePoint)
    
        inkAnnotation?.setStencilColor(color: color)
        inkAnnotation?.setStencilWidth(width: width)
        inkAnnotation?.path = path
        currentpage?.addAnnotation(inkAnnotation!)
    }
    
    func gestureRecognizerMoved(_ location: CGPoint) {
    
        let inPagePoint = pdfView.convert(location, to: currentpage!)
        
        path?.addLine(to: inPagePoint)
        inkAnnotation?.path = path
        
        currentpage?.addAnnotation(inkAnnotation!)
    }
    
    func gestureRecognizerEnded(_ location: CGPoint) {
    
        let inPagePoint = pdfView.convert(location, to: currentpage!)
        path?.addLine(to: inPagePoint)
       
        inkAnnotation?.path = path
       
        currentpage?.addAnnotation(inkAnnotation!)
        pathMap[(currentpage?.label)!] = path
        inkMap[(currentpage?.label)!] = inkAnnotation
        //path = nil
    }
}

class Ink: PDFAnnotation{
    var path: UIBezierPath!
    var stencilColor: UIColor = UIColor.black
    var stencilWidth: CGFloat = 2
    
    func setStencilColor(color: UIColor){
        stencilColor = color
    }
    func setStencilWidth(width: CGFloat){
        stencilWidth = width
    }
    func getStencilColor() -> UIColor {
        return stencilColor
    }
    func getStencilWidth() -> CGFloat{
        return stencilWidth
    }
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        if( path == nil){
            return
        }
            
        let localPath = path.copy() as! UIBezierPath
       
        super.draw(with: box, in: context)
        
        // Draw a custom purple line.
        UIGraphicsPushContext(context)
        context.saveGState()
        
        localPath.lineWidth = stencilWidth
        localPath.lineJoinStyle = .round
        localPath.lineCapStyle = .round
        stencilColor.setStroke()
        localPath.stroke(with: CGBlendMode.sourceOut, alpha: 0.4)
        
        //localPath.usesEvenOddFillRule = true
        context.restoreGState()
        UIGraphicsPopContext()
    }
}

//
//class Watermark: PDFPage {
////    var x: CGFloat = 0
////    var y: CGFloat = 0
//
//
//
////    override func draw(with box: PDFDisplayBox, to context: CGContext) {
////         super.draw(with: box, to: context)
////
////
////        // Draw a custom purple line.
////        UIGraphicsPushContext(context)
////        context.saveGState()
////
////        let startPoint = CGPoint(x: 0, y: 0)
////        let endPoint = CGPoint(x: 100, y: 100)
////
////        let path = UIBezierPath()
////        path.lineWidth = 10
////        path.move(to: startPoint)
////        path.addLine(to: endPoint)
////        UIColor.systemPurple.setStroke()
////        path.stroke()
////
////        context.restoreGState()
////        UIGraphicsPopContext()
////    }
//
//
//
//    // 3. Override PDFPage custom draw
//    /// - Tag: OverrideDraw
//    override func draw(with box: PDFDisplayBox, to context: CGContext) {
//        //print("Watermark draw called")
//
//
//
//        // Draw rotated overlay string
//        UIGraphicsPushContext(context)
//        context.saveGState()
//
//        //let pageBounds = self.bounds(for: box)
//
//        //let bkgrnd = UIImage(named: "page1.png")
//
//        //bkgrnd?.draw(in: pageBounds)
//
////        let pageBounds = self.bounds(for: box)
////        context.translateBy(x: 0.0, y: pageBounds.size.height)
////        context.scaleBy(x: 1.0, y: -1.0)
////        context.rotate(by: CGFloat.pi / 4.0)
////
////        let string: NSString = "U s e r   3 1 4 1 5 9"
////        let attributes: [NSAttributedString.Key: Any] = [
////            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 0.5),
////            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 64)
////        ]
////
////        string.draw(at: CGPoint(x: 250, y: 40), withAttributes: attributes)
//
//        context.restoreGState()
//        UIGraphicsPopContext()
//
//        // Draw original content
//        super.draw(with: box, to: context)
//
//    }
//
//
//}












