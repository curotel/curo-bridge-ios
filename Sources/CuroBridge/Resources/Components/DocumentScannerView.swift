//
//  DocumentScannerView.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 19/03/26.
//

import SwiftUI
import VisionKit

public struct DocumentScannerView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    
    public init() { }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    public class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerView
        
        public init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            
            var images: [UIImage] = []
            
            for i in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: i))
            }
            
            // 👉 handle scanned images here
            print("Scanned pages: \(images.count)")
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: Error) {
            print("Scan failed: \(error)")
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
