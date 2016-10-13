//
//  ViewController.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/5/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var btn:UIButton?
    
    var view1 = UIView()
    override func viewDidLoad() {
 
        
        
        super.viewDidLoad()
        self.navigationItem.title = "ViewChaos"
       view.backgroundColor = UIColor.white
        btn = UIButton(frame: CGRect(x: 10, y: 100, width: 100, height: 30))
        btn?.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.2)
        btn?.setTitle("Next", for: UIControlState())
        btn?.chaosName = "btn"
        btn?.addTarget(self, action: #selector(ViewController.click(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(btn!)
        
        view1.frame = CGRect(x: 20, y: 180, width: 200, height: 100)
        view1.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
        view1.alpha = 0.5
        view.addSubview(view1)

    }


    
    func click(_ sender:UIButton)
    {
        let story = UIStoryboard(name: "Main", bundle: Bundle.main)
        let next = story.instantiateViewController(withIdentifier: "next")
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

