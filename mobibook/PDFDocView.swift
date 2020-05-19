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
        self.pdfView.autoScales = true
        self.pdfView.usePageViewController(true)
        self.pdfView.maxScaleFactor = 3
        /////////////////////////
//        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        pdfView.autoScales = true
//        self.pdfView.displayMode = .singlePageContinuous
//        pdfView.displaysPageBreaks = true
//        pdfView.document = PDFDocument(data:data)
//        pdfView.maxScaleFactor = 4.0
//        pdfView.minScaleFactor = 1.15
//        pdfView.scaleFactor = 1.15
//        self.view.addSubview(pdfView)
        /////////////////////////
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
    
    func undo(){
        pdfDrawer.undo()
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

//class PDFRenderer {
//
//    var pdfRenderer: UIGraphicsPDFRenderer!
//    var outputFileURL: URL!
//
//    init(width: CGFloat, height: CGFloat) {
//        //let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
//        let pageRect = CGRect(x: 0, y: 0, width: width, height: height)
//        pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)
//    }
//}


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
    var historyMap = [ String: [Ink : UIBezierPath]]()
    var annHistory = [String : AnnotationStack]()
    
    func setColor(color: UIColor){
        self.color = color
    }
    func setWidth(width : CGFloat){
        self.width = width
    }
    
//    func undo(){
//        print("Undo on page: \(currentpage?.label) and history length : \(historyMap[(currentpage?.label)!]?.count)")
//        var getPath = historyMap[(currentpage?.label)!]?.popLast()
//        //let getPath = pathMap[(currentpage?.label)!]
//        //getPath?.removeAllPoints()
//
//        for paths in historyMap[(currentpage?.label)!]! {
//            getPath?.append(paths)
//        }
//        //inkAnnotation?.remove(getPath!)
//
//
//
//        // Now update
//        //let annotation = inkMap[(currentpage?.label)!]
//        currentpage?.addAnnotation(inkAnnotation!)
//    }
    func undo(){
        
        guard let inkPair = annHistory[(currentpage?.label)!]?.pop() else {
            print("No more Undo Available")
            return
        }
        
        let topPair = annHistory[(currentpage?.label)!]?.peek()
        
        //print("lastpair.path - \(inkPair.path)")
        //print("lastpair.path - \(topPair?.path)")
        
        if topPair == nil {
            print("top pair empty")
            currentpage?.removeAnnotation(inkPair.ink!)
            return
        }else{
            print("Removing last annotated path")
            
            inkPair.path?.removeAllPoints()
            
            currentpage?.removeAnnotation(inkPair.ink!)
            inkAnnotation = topPair?.ink
            inkAnnotation?.path = topPair?.path
            currentpage?.addAnnotation(inkAnnotation!)
        }
        
        
    }
    
    func gestureRecognizerBegan(_ location: CGPoint) {
        //let nearestpage = pdfView.page(for: location, nearest: true)
        guard let currpage  = pdfView.currentPage else {return}
        currentpage = currpage
        //print("current page - \(currentpage) Vs nearest page - \(nearestpage)")
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
        
        guard currentpage != nil else{return}
        let inPagePoint = pdfView.convert(location, to: currentpage!)
        
        path?.addLine(to: inPagePoint)
        path?.move(to: inPagePoint)
        inkAnnotation?.path = path
        
        currentpage?.addAnnotation(inkAnnotation!)
    }
    
    func gestureRecognizerEnded(_ location: CGPoint) {
    
        guard currentpage != nil else{return}
        let inPagePoint = pdfView.convert(location, to: currentpage!)
        path?.addLine(to: inPagePoint)
        path?.move(to: inPagePoint)
        
        
        let newPath = path?.copy() as! UIBezierPath
        
        
        inkAnnotation?.path = newPath
       
        currentpage?.addAnnotation(inkAnnotation!)
        pathMap[(currentpage?.label)!] = newPath
        inkMap[(currentpage?.label)!] = inkAnnotation
        //path = nil
        
        //Add it to the history
        
        
        //if historyMap[(currentpage?.label)!] == nil
        if annHistory[(currentpage?.label)!] == nil
        {
            //let pathArray:[UIBezierPath] = [pathMap[(currentpage?.label)!]!]
            //var page = historyMap[(currentpage?.label)!]
            //page![inkAnnotation!] = path!
            //historyMap[(currentpage?.label)!] = [page]
            var inkPair = InkPair()
            inkPair.ink = inkAnnotation
            inkPair.path = path
            let stack = AnnotationStack(pair: inkPair)
            annHistory[(currentpage?.label)!] = stack

        }else{
            var inkPair = InkPair()
            inkPair.ink = inkAnnotation
            inkPair.path = path
            var stack = annHistory[(currentpage?.label)!]
            stack?.push(pair: inkPair)
            annHistory[(currentpage?.label)!] = stack
            //historyMap[(currentpage?.label)!]!.append(pathMap[(currentpage?.label)!]!)
            //annHistory[(currentpage?.label)!]?.append(ann!)
        }
        //print("Added path to historyMap, count: \(historyMap[(currentpage?.label)!]?.count)")
        //print("Added path to historyMap, count: \(annHistory[(currentpage?.label)!]?.count)")
        print("Annotation path count : \(annHistory[(currentpage?.label)!]?.totalElements())")
        
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












