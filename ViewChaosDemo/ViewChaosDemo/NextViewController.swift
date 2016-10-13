//
//  NextViewController.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/5/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit

class NextViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "一个页面"
    }
    
    @IBOutlet weak var vMove: UIView!

    @IBAction func Click(_ sender: UIButton) {
         vMove.frame = CGRect(x: vMove.frame.origin.x, y: vMove.frame.origin.y + 5, width: vMove.frame.size.width, height: vMove.frame.size.height)
    }

}
