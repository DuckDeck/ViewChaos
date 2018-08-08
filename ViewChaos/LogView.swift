//
//  LogView.swift
//  ViewChaosDemo
//
//  Created by Stan Hu on 2018/8/8.
//  Copyright © 2018 Qfq. All rights reserved.
//

import UIKit



class LogView: UIWindow {
    var arrMsg = [String]()
    let tbmsg = UITableView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        tbmsg.frame = CGRect(origin: CGPoint(), size: frame.size)
        tbmsg.dataSource = self
        tbmsg.delegate = self
        tbmsg.register(UITableViewCell.self, forCellReuseIdentifier: "LogCell")
        tbmsg.tableFooterView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LogView:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMsg.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
        cell.textLabel?.text = arrMsg[indexPath.row]
        return cell
    }
}

func VCLog<T>(message:T,file:String = #file, method:String = #function,line:Int = #line){
    #if DEBUG
    if   let path = NSURL(string: file)
    {
        let log = "\(path.lastPathComponent!)[\(line)],\(method) \(message)"
        print(log)
    }
    #endif
}

