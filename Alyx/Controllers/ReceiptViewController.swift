//
//  ReceiptViewController.swift
//  Alyx-dev
//
//  Created by CDI on 5/4/22.
//

import UIKit
import WebKit

class ReceiptViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    let receipt: String
    let orderID: String
    
    init(receipt: String, orderID: String) {
        self.receipt = receipt
        self.orderID = orderID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let receiptWebView: WKWebView = {
        let prefs = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            prefs.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
            prefs.preferredContentMode = .recommended
        }
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero,
                                configuration: config)
        
        return webView
    }()
    
    private let receiptImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.app_logo)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
//        imageView.addTopBorder(with: Constants.systemRedColor, andWidth: 3)
//        imageView.addLeftBorder(with: Constants.systemRedColor, andWidth: 3)
//        imageView.addRightBorder(with: Constants.systemRedColor, andWidth: 3)
//        imageView.addBottomBorder(with: Constants.systemRedColor, andWidth: 3)
        return imageView
    }()
    
    private var shareBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.drawerBackgroundColor
        configureBarButtons()
        
//        view.addSubview(receiptImage)
//        let yPosition = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 44.0)
//        let croppedImage = receipt.sd_croppedImage(with: CGRect(
//            x: 0,
//            y: yPosition,
//            width: view.width,
//            height: view.height - yPosition - view.safeAreaInsets.bottom - 40))
//        receiptImage.image = croppedImage
        
        
        
        receiptWebView.navigationDelegate = self
        view.addSubview(receiptWebView)
        navigationController?.navigationBar.tintColor = .label
//        receiptWebView.loadHTMLString("<html><body>\(receipt)</body></html>", baseURL: nil)
//        receiptWebView.loadHTMLString(receipt, baseURL: nil)
        
        createPDF()
        loadPDF(filename: "\(orderID)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        receiptImage.frame = CGRect(
//            x: 20,
//            y: 0,
//            width: view.width-40,
//            height: view.height)
        
        receiptWebView.frame = view.bounds
    }
    
    func createPDF() {
//        let html = "<b>Hello <i>World!</i></b> <p>Generate PDF file from HTML in Swift</p>"
        let html = """
                    <html>
                    <body>
                    \(receipt)
                    </body>
                    </html>
                    """
//        let aString = "This is my string"
        var newHtml = html.replacingOccurrences(of: "\n", with: "<br>", options: .literal, range: nil)
        newHtml = newHtml.replacingOccurrences(of: "\t", with: "&nbsp;&nbsp;&nbsp;&nbsp;", options: .literal, range: nil) // &nbsp;
        
        let fmt = UIMarkupTextPrintFormatter(markupText: newHtml)

        // 2. Assign print formatter to UIPrintPageRenderer

        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)

        // 3. Assign paperRect and printableRect

        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)

        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")

        // 4. Create PDF context and draw

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)

        for i in 1...render.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }

        UIGraphicsEndPDFContext();

        // 5. Save PDF file

        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

        pdfData.write(toFile: "\(documentsPath)/\(orderID).pdf", atomically: true)
    }
    
    func loadPDF(filename: String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent(filename).appendingPathExtension("pdf")
        let urlRequest = URLRequest(url: url)
        receiptWebView.load(urlRequest)
    }
    
    private func configureBarButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShareButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapCloseButton))
    }
    
    @objc func didTapShareButton() {
        print("Sharing: \(receipt)")
        let vc = UIActivityViewController(activityItems: [receipt],
                                          applicationActivities: [])
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)
    }
    
    @objc func didTapCloseButton() {
        self.dismiss(animated: true)
    }

}
