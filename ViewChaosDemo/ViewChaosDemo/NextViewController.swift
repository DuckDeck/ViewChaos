//
//  NextViewController.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/5/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit

class NextViewController: UIViewController {

    @IBOutlet weak var vMove: UIView!

    @IBAction func Click(sender: UIButton) {
         vMove.frame = CGRect(x: vMove.frame.origin.x, y: vMove.frame.origin.y + 5, width: vMove.frame.size.width, height: vMove.frame.size.height)
    }

}
