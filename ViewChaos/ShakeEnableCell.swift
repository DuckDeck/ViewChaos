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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        lblHint.text = "开启摇一摇"
        lblHint.font = UIFont.systemFont(ofSize: 15)
        lblHint.frame = CGRect(x: 0, y: 10, width: 100, height: 20)
        contentView.addSubview(lblHint)
        swEnableShake.isOn = UserDefaults.standard.bool(forKey: "ShakeEnable")
        swEnableShake.frame = CGRect(x: 150, y: 5, width: 200, height: 20)
        swEnableShake.addTarget(self, action: #selector(ShakeEnableCell.switchEnableShake(sender:)), for: .valueChanged)
        swEnableShake.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        contentView.addSubview(swEnableShake)
//        UIApplication.shared.applicationSupportsShakeToEdit
    }
    
    @objc func switchEnableShake(sender:UISwitch)  {
        let def = UserDefaults.standard
        def.set(sender.isOn, forKey: "ShakeEnable")
        def.synchronize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
