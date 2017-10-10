//
//  UserController.swift
//  test
//  用户中心
//  Created by gangpiaowang on 2016/12/16.
//  Copyright © 2016年 mutouwang. All rights reserved.
//

import UIKit

class UserController: GPWBaseViewController,UITableViewDelegate,UITableViewDataSource {
    var maxAplha:CGFloat = 1
    var _scrollviewOffY:CGFloat = 0
    
    var showTableView:UITableView!

    fileprivate var  messageImgView:UIImageView!
    
    //设置
    var setBtn:UIButton!
    
    //展示客服电话
    var flag = false
    
    let imgArray = ["user_jilu","user_liushui","user_jiangli","user_yaoqing","user_fankui"]
    let titleArray = ["出借记录","资金流水","我的奖励","我的邀请","意见反馈"]
    
    override func viewWillAppear(_ animated: Bool) { 
        super.viewWillAppear(animated)
        self.getMessageNum()
       self.navigationController?.navigationBar.barStyle = .black
        self.bgView.viewWithTag(10000)?.removeFromSuperview()
        if GPWUser.sharedInstance().isLogin {
            GPWNetwork.requetWithGet(url: User_informition, parameters: nil, responseJSON:  {
                [weak self] (json, msg) in
                guard let strongSelf = self else { return }
                GPWUser.sharedInstance().analyUser(dic: json)
                strongSelf.showTableView.reloadData()
                }, failure: { error in
            
            })
        }else{
           self.noLogin()
        }
        self.showTableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isBarHidden = true
        self.navigationBar.alpha = 0.0
        self.bgView.y = 0
        self.bgView.height =   self.bgView.height + 64
        
        showTableView = UITableView(frame: self.bgView.bounds, style: .plain)
        showTableView.backgroundColor = UIColor.clear
        showTableView.addTwitterCover(with: UIImage(named: "user_center_topbg"))
        showTableView?.delegate = self
        showTableView.showsVerticalScrollIndicator = false
        showTableView?.dataSource = self
        showTableView.separatorStyle = .none
        self.bgView.addSubview(showTableView)

     self.addMessageBtn()

        if GPWUser.sharedInstance().isLogin == false {
            //未登录
            self.noLogin()
        }
        
        //判断是否需要弹窗提示设置密码
        let tempStr =   UserDefaults().string(forKey: "firstFlag")
       if GPWUser.sharedInstance().isLogin == true && GPWUser.sharedInstance().set_pwd == 0 && tempStr == nil{
            UserDefaults().setValue("firstFlag", forKey: "firstFlag")
            let alertContol = UIAlertController(title: nil, message: "您还没有设置登录密码哦", preferredStyle: .alert)
            let cancalAction = UIAlertAction(title: "稍后再说", style: .cancel, handler: nil)
            alertContol.addAction(cancalAction)
            let okAction = UIAlertAction(title: "去设置", style: .default) { (alert) in
                MobClick.event("mine", label: "设置密码")
                self.navigationController?.pushViewController(GPWUserQSetPWViewController(), animated: true)
            }
            alertContol.addAction(okAction)
            self.navigationController?.present(alertContol, animated: true, completion: nil)
        }
    }

    //添加消息按钮
    func addMessageBtn() {
        let  messageBtn = UIButton(type: .custom)
        messageBtn.tag = 101
        messageBtn.frame = CGRect(x: SCREEN_WIDTH - 28 - 16, y: 27, width: 35, height: 35)
        messageBtn.addTarget(self, action: #selector(self.toMessageControll), for: .touchUpInside)
        self.bgView.addSubview(messageBtn)

        messageImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        messageImgView.image = UIImage(named: "user_message_no")
        messageImgView.centerX = messageBtn.width / 2
        messageImgView.centerY = messageBtn.height / 2
        messageBtn.addSubview(messageImgView)
    }

    func getMessageNum() {
        GPWNetwork.requetWithGet(url: Message_count, parameters: nil, responseJSON:  {
            [weak self] (json, msg) in
            guard let strongSelf = self else { return }
            if json["un_read"].intValue == 0 {
                strongSelf.messageImgView.image = UIImage(named: "user_message_no")
            }else{
                strongSelf.messageImgView.image = UIImage(named: "user_message")
            }
            }, failure: { error in
        })
    }

    func toMessageControll() {
        MobClick.event("index_message", label: nil)
        if GPWUser.sharedInstance().isLogin {
            self.navigationController?.pushViewController(GPWUserMessageController(), animated: true)
        }else{
            self.navigationController?.pushViewController(GPWLoginViewController(), animated: true)
        }
    }
    
    func setClick(_ sender:UIButton) {
        if sender.tag == 100 {
             MobClick.event("mine", label: "信息")
            self.navigationController?.pushViewController(UserSetViewController(), animated: true)
        }else if sender.tag == 102 {
            self.navigationController?.pushViewController(GPWUserMoneyFundViewController(), animated: true)
        }
    }
    
    func noLogin() {
        let noLoginView = UIView(frame: self.bgView.bounds)
        noLoginView.backgroundColor = UIColor.white
        noLoginView.tag = 10000
        self.bgView.addSubview(noLoginView)
        
        //背景图片
        let  imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: pixw(p: 463)))
        imgView.image = UIImage(named: "user_nologin_top")
        noLoginView.addSubview(imgView)
        
        //注册
        let regiterBtn = UIButton(frame: CGRect(x: 16 , y:  imgView.maxY + pixw(p: 8), width:  SCREEN_WIDTH - 16 * 2, height:  pixw(p: 60)))
        regiterBtn.setBackgroundImage(UIImage(named: "btn_bg"), for: .normal)
        regiterBtn.setTitle("注册领取\(GPWGlobal.sharedInstance().app_exper_amount)元体验金", for: .normal)
        regiterBtn.addTarget(self, action: #selector(self.btnClick(sender:)), for: .touchUpInside)
        regiterBtn.tag = 101
        regiterBtn.titleLabel?.font = UIFont.customFont(ofSize:  16)
        noLoginView.addSubview(regiterBtn)
        
        //登录
        let loginBtn = UIButton(frame: CGRect(x: 0, y:  regiterBtn.maxY + 8, width:  SCREEN_WIDTH, height: 20))
        loginBtn.tag = 100
        loginBtn.addTarget(self, action: #selector(self.btnClick(sender:)), for: .touchUpInside)
        noLoginView.addSubview(loginBtn)
        
        let titleLabel = UILabel(frame: loginBtn.bounds)
        titleLabel.attributedText = NSAttributedString.attributedString( "已有帐号?", mainColor: UIColor.hex("666666"), mainFont: 16, second: "立即登录", secondColor: redTitleColor, secondFont: 16)
        titleLabel.textAlignment = .center
        loginBtn.addSubview(titleLabel)
        
        //图标
        let  botomImgView = UIImageView(frame: CGRect(x: pixw(p: 125), y: SCREEN_HEIGHT - 40 - 44, width: 11, height: 13))
        botomImgView.image = UIImage(named: "home_bottom")
        noLoginView.addSubview(botomImgView)
        
        //标题
        let  bottomTitleLabel = UILabel(frame: CGRect(x: botomImgView.maxX + 3, y: 0, width: 200, height: 12))
        bottomTitleLabel.font = UIFont.customFont(ofSize: 12)
        bottomTitleLabel.text = "资金由银行存管"
        bottomTitleLabel.centerY = botomImgView.centerY
        bottomTitleLabel.textColor = UIColor.hex("999999")
        noLoginView.addSubview(bottomTitleLabel)
    }
    
    func btnClick(sender:UIButton)  {
        if sender.tag == 100 {
             MobClick.event("mine_login", label: nil)
            self.navigationController?.pushViewController(GPWLoginViewController(), animated: true)
        }else{
             MobClick.event("mine_register", label: nil)
            self.navigationController?.pushViewController(GPWUserRegisterViewController(), animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return 1
        }else{
            if self.flag == false {
                return 1 + 1
            }else{
                return 1 + 3
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return  pixw(p: 222)
        }else if indexPath.section == 1 {
            return  89 + 10
        }else{
            if indexPath.row == 1 {
                return  32 + 50 + 20
            }else if indexPath.row == 2 {
                return  29 + 30
            }else if indexPath.row == 3 {
                return  49 + 60
            }
            return  189
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "topCell") as? UserTopCell
            if cell == nil {
                cell = UserTopCell(style: .default, reuseIdentifier: "topCell")
            }
            if GPWUser.sharedInstance().isLogin {
                //余额  GPWUser.sharedInstance().money
                var phone = GPWUser.sharedInstance().telephone!
                if GPWUser.sharedInstance().is_idcard == 1 {
                    phone = GPWUser.sharedInstance().name ?? ""
                }
               cell?.updata(GPWUser.sharedInstance().accrual!, acountMoney: GPWUser.sharedInstance().totalMoney!, phone: phone, superC: self)
            }else{
                cell?.updata("****", acountMoney: "****", phone: "***********",superC: self)
            }
            return cell!
        } else if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "secCell") as? UserSecondCell
            if cell == nil {
                cell = UserSecondCell(style: .default, reuseIdentifier: "secCell")
            }
            cell?.updata(GPWUser.sharedInstance().money!)
            cell?.superControl = self
            return cell!
        } else {
            if indexPath.row == 1 {
                var cell = tableView.dequeueReusableCell(withIdentifier: "GPWUserBottom1Cell") as? GPWUserBottom1Cell
                if cell == nil {
                    cell = GPWUserBottom1Cell(style: .default, reuseIdentifier: "GPWUserBottom1Cell")
                }
                cell?.superControl = self
                cell!.lineisHidden(!self.flag)
                return cell!
            }else if indexPath.row == 2 {
                var cell = tableView.dequeueReusableCell(withIdentifier: "GPWUserBottom2Cell") as? GPWUserBottom2Cell
                if cell == nil {
                    cell = GPWUserBottom2Cell(style: .default, reuseIdentifier: "GPWUserBottom2Cell")
                }
                cell?.superControl = self
                return cell!
            }else if indexPath.row == 3 {
                var cell = tableView.dequeueReusableCell(withIdentifier: "GPWUserBottom3Cell") as? GPWUserBottom3Cell
                if cell == nil {
                    cell = GPWUserBottom3Cell(style: .default, reuseIdentifier: "GPWUserBottom3Cell")
                }
                return cell!
            }else{
                var cell = tableView.dequeueReusableCell(withIdentifier: "UserThridCell") as? UserThridCell
                if cell == nil {
                    cell = UserThridCell(style: .default, reuseIdentifier: "UserThridCell")
                }
                var dicArray = [
                [ "img":"user_center_jilu","title":"出借记录","detail":"待收:\(GPWUser.sharedInstance().money_collection)"],
                [ "img":"user_center_jiangli","title":"优惠券","detail":"红包、加息券"],
                [ "img":"user_center_liushui","title":"资金流水","detail":"了解资金进出"]
                ]
                if GPWUser.sharedInstance().show_iden == 0 {
                    dicArray.append( [ "img":"user_center_fengxian","title":"风险测评","detail": (GPWUser.sharedInstance().risk > 0 ? self.checkRiskType() : "检测承受类型")])
                }else{
                    dicArray.append( [ "img":"user_center_yaoqing","title":"我的邀请","detail":"查看邀请收益"])
                }
                cell?.updata(dicArray, superControl: self)
                return cell!
            }
        }
    }
    
    func checkRiskType() -> String {
        var  type = "保守型"
        if GPWUser.sharedInstance().risk <= 30 {
            //保守型
            type = "保守型"
        }else if GPWUser.sharedInstance().risk > 37 && GPWUser.sharedInstance().risk <= 72 {
            //稳健型
            type = "稳健型"
        }else{
            //进取型
            type = "进取型"
        }
        return type
    }
}