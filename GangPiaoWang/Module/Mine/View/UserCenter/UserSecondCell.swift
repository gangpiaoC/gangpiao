//
//  UserSecondCell.swift
//  test
//
//  Created by gangpiaowang on 2016/12/16.
//  Copyright © 2016年 mutouwang. All rights reserved.
//

import UIKit
class UserSecondCell: UITableViewCell {
    var superControl:UserController?
    var partLabel:UILabel!
    fileprivate let  DELEVIEWTAG = 10000
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        let tempLabel = UILabel(frame: CGRect(x: 23,y: 23,width: 102,height: 16))
        tempLabel.text = "可用余额(元)"
        tempLabel.font = UIFont.customFont(ofSize:  16)
        tempLabel.textColor = UIColor.hex("666666")
        self.contentView.addSubview(tempLabel)
        
        partLabel = UILabel(frame:CGRect(x: tempLabel.x,y:tempLabel.maxY + 10,width: SCREEN_WIDTH / 2,height:  19))
        partLabel.text = "0.00"
        partLabel.font = UIFont.systemFont(ofSize:  18)
        partLabel.textColor = redTitleColor
        self.contentView.addSubview(partLabel)
        
        let imgArray = ["user_center_tixian","user_center_chongzhi"]
        
        for i in 0 ..< imgArray.count {
          let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: pixw(p: 210) + CGFloat(76 * i), y: 29, width: 76, height: 44)
            btn.setImage(UIImage(named: imgArray[i]), for: .normal)
            btn.tag = 100 + i
            btn.addTarget(self, action: #selector(self.btnClick(_:)), for: .touchUpInside)
            contentView.addSubview(btn)
        }
        let block = UIView(frame: CGRect(x: 0, y: 89, width: SCREEN_WIDTH, height: 10))
        block.backgroundColor = bgColor
        self.contentView.addSubview(block)
    }
    
    func updata(_ part:String) {
        partLabel.text = part
    }
    
    func btnClick(_ sender:UIButton) {
        if GPWUser.sharedInstance().isLogin == false{
            self.superControl?.navigationController?.pushViewController(GPWLoginViewController(), animated: true)
        }else if GPWUser.sharedInstance().is_idcard == 0 || GPWUser.sharedInstance().is_valid == "0"{
            self.superControl?.navigationController?.pushViewController(UserReadInfoViewController(), animated: true)
        }else{
            if sender.tag == 101 {
                MobClick.event("mine", label: "充值")
                let control = GPWUserRechargeViewController(money: 0.00)
                superControl?.navigationController?.pushViewController(control, animated: true)
            }else{
                MobClick.event("mine_withdraw", label: nil)
                if GPWUser.sharedInstance().real == 0 {
                    let control = GPWUserTixianViewController()
                    superControl?.navigationController?.pushViewController(control, animated: true)
                }else{
                    let control = GPWUserTixianViewController()
                    superControl?.navigationController?.pushViewController(control, animated: true)
                }
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}