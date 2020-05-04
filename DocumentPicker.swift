//
//  DocumentPicker.swift
//  jotdown
//
//  Created by ABHISHEK SINGH on 04/05/20.
//  Copyright © 2020 Abhishek Singh. All rights reserved.
//

import UIKit

class DocumentPickerViewController: UIDocumentPickerViewController {
    private let onDismiss: () -> Void
    private let onPick: (URL) -> ()

    init(supportedTypes: [String], onPick: @escaping (URL) -> Void, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        self.onPick = onPick
        

        super.init(documentTypes: supportedTypes, in: .open)

        shouldShowFileExtensions = true
        allowsMultipleSelection = false
        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DocumentPickerViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        onPick(urls.first!)
        
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        onDismiss()
    }
}
