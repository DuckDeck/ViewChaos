//
//  LogView.swift
//  ViewChaosDemo
//
//  Created by Stan Hu on 2018/8/8.
//  Copyright © 2018 Qfq. All rights reserved.
//

import UIKit



class LogView: UIView {
    static let  sharedInstance = LogView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 0.6))
    var arrMsg = [String]()
    let tbmsg = UITableView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.7)
        tbmsg.backgroundColor = UIColor.clear
        tbmsg.frame = CGRect(origin: CGPoint(), size: frame.size)
        tbmsg.dataSource = self
        tbmsg.delegate = self
        tbmsg.estimatedRowHeight = 20
        tbmsg.separatorStyle = .singleLine
        tbmsg.separatorColor = UIColor.white
        tbmsg.register(logTableViewCell.self, forCellReuseIdentifier: "LogCell")
        tbmsg.tableFooterView = UIView()
        addSubview(tbmsg)
    }
    
    func addLog(msg:String)  {
        if arrMsg.count >= 80{
            arrMsg.removeSubrange(50..<80)
           
        }
        arrMsg.append(msg)
        tbmsg.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class logTableViewCell: UITableViewCell {
    let lblMsg = UILabel()
    var msg:String?{
        didSet{
            lblMsg.text = msg
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        lblMsg.numberOfLines = 0
        lblMsg.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lblMsg)
        let leftConstraint = NSLayoutConstraint.init(item: lblMsg, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: contentView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 10)
        let rightConstraint = NSLayoutConstraint.init(item: lblMsg, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: contentView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -10)
        let topConstraint = NSLayoutConstraint.init(item: lblMsg, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: contentView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 3)
        let bottomConstraint = NSLayoutConstraint.init(item: lblMsg, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: contentView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -3)
        NSLayoutConstraint.activate([leftConstraint,rightConstraint,topConstraint,bottomConstraint])
        lblMsg.textColor = UIColor.white
        lblMsg.font = UIFont.systemFont(ofSize: 12)
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! logTableViewCell
        cell.msg = arrMsg[indexPath.row]
        return cell
    }
}

func VCLog<T>(message:T,file:String = #file, method:String = #function,line:Int = #line){
    #if DEBUG
    if   let path = NSURL(string: file)
    {
        let log = "\(path.lastPathComponent!)[\(line)],\(method) \(message)"
        LogView.sharedInstance.addLog(msg: log)
        print(log)
    }
    #endif
}

