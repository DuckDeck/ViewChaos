//
//  ShakeEnableCell.swift
//  ViewChaosDemo
//
//  Created by Stan Hu on 2019/1/17.
//  Copyright © 2019 Qfq. All rights reserved.
//

import UIKit

class ShakeEnableCell: UITableViewCell {
    let lblHint = UILabel()
    let swEnableShake = UISwitch()
    let btnInvokeMenu = UIButton()
    var blkSHowMenu : (()->Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        lblHint.text = "开启摇一摇"
        lblHint.font = UIFont.systemFont(ofSize: 15)
        lblHint.frame = CGRect(x: 0, y: 10, width: 80, height: 20)
        contentView.addSubview(lblHint)
        
        swEnableShake.frame = CGRect(x: 100, y: 5, width: 60, height: 20)
        swEnableShake.addTarget(self, action: #selector(ShakeEnableCell.switchEnableShake(sender:)), for: .valueChanged)
        swEnableShake.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        contentView.addSubview(swEnableShake)
        
        btnInvokeMenu.frame = CGRect(x: 160, y: 10, width: 80, height: 20)
        btnInvokeMenu.setTitle("打开菜单", for: .normal)
        btnInvokeMenu.setTitleColor(UIColor.black, for: .normal)
        btnInvokeMenu.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btnInvokeMenu.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        contentView.addSubview(btnInvokeMenu)
        
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        swEnableShake.isOn = UserDefaults.standard.bool(forKey: "ShakeEnable")
    }
    
    @objc func switchEnableShake(sender:UISwitch)  {
        let def = UserDefaults.standard
        def.set(sender.isOn, forKey: "ShakeEnable")
        def.synchronize()
        
        
        
    }
    
    @objc func showMenu(){
        blkSHowMenu?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
