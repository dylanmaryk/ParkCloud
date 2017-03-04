//
//  DismissSegue.swift
//  ParkCloud
//
//  Created by Stefan Maier on 05/03/17.
//  Copyright © 2017 ParkCloud. All rights reserved.
//

import UIKit

@objc(DismissSegue)
class DismissSegue: UIStoryboardSegue {
    override func perform() {
        if let controller = source.presentingViewController {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
