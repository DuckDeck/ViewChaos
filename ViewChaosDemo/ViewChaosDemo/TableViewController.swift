//
//  TableViewController.swift
//  ViewChaosDemo
//
//  Created by Stan Hu on 2018/11/19.
//  Copyright © 2018 Qfq. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {

    let tb = UITableView()
    var arrSource = [String]()
    let word = "摄影小哥似乎看穿了我的心思，却不知道为什么用着佳能1D的大佬，极力向我推荐索尼，莫非是最近看到了姨夫的微笑？现在看来价格差距不算大的横向型号有大法A6000L，佳能M6和富士XA5。于是我在贴吧论坛开始转悠，基本的论调是大法性能优秀，佳能镜头便宜，富士直出色彩美丽。看完一圈以后，我又看了看小哥拍的照片，告诉自己，专业的人考虑专业的事情，我这样的小白不需要想太多，闭着眼睛买就对了（双11来了时间不多了！），于是赶上双11狗东不送赠品降价（我也用不着赠品，SD卡屯了好几张，相机包淘宝50买个mini的就好），就像快门声一样咔嚓一下，手就没了，不，是草就没了"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tag = 111
        tb.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        tb.dataSource = self
        tb.delegate = self
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        for _ in 0..<20{
            var start = Int(arc4random()) % word.count
            var end = Int(arc4random()) % word.count
            if start > end{
                (start,end) = (end,start)
            }
            else if start == end{
                start = 0
            }
            arrSource.append(word.substring(from: start, to: end))
        }
        tb.tableFooterView = UIView()
        tb.separatorStyle = .singleLine
        view.addSubview(tb)
        // Do any additional setup after loading the view.
    }
    


}
extension TableViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arrSource[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        print(cell!.textLabel!.frame)
        if  let fm = view.window?.convert(cell!.textLabel!.frame, from: cell!){
            print(fm)
        }
        
    }

    
}


extension String{
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return String(self[startIndex ..< endIndex])
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }
}
