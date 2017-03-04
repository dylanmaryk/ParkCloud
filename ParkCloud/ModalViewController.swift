//
//  ModalViewController.swift
//  ParkCloud
//
//  Created by Stefan Maier on 04/03/17.
//  Copyright © 2017 ParkCloud. All rights reserved.
//
import UIKit

class ModalViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL (string: "http://www.rigma.io/projects/here-maps")
        let requestObj = NSURLRequest(url: url! as URL);
        webView.loadRequest(requestObj as URLRequest)
        // Do any additional setup after loading the view.
    }
}
