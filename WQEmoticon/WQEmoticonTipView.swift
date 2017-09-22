//
//  WQEmoticonTipView.swift
//  WQEmoticon
//
//  Created by 王伟奇 on 2017/7/31.
//  Copyright © 2017年 王伟奇. All rights reserved.
//

import UIKit
import pop

//／ 表情选择提示视图
class WQEmoticonTipView: UIImageView {
    
    //之前选择的表情
    private var preEmoticon: WQEmotion?
    
    // MARK: - 私有控件
    private lazy var tipButton = UIButton()
    
    // 提示视图的表情模型
    var emoticon: WQEmotion? {
        didSet{
            
            // 判断表情是否发生变化
            if emoticon == preEmoticon {
                return
            }
            
            //记录当前的表情
            preEmoticon = emoticon
            
            // 设置表情数据
            tipButton.setTitle(emoticon?.emoji, for: [])
            tipButton.setImage(emoticon?.image, for: .normal)
            
            // 表情动画
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            
            anim.fromValue = 30
            anim.toValue = 20
            
            anim.springBounciness = 20
            anim.springSpeed = 20
            
            tipButton.layer.pop_add(anim, forKey: nil)
        }
    }
    
    //MARK: - 构造函数
    init() {
        
        let bundle = WQEmoticonManager.shared.bundle
        let image = UIImage(named: "emoticon_keyboard_magnifier", in: bundle, compatibleWith: nil)
        
        // [[UIImageView alloc] initWithImage: image] => 会根据图像大小设置图像视图的大小！
        super.init(image: image)
        
        // 设置锚点
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.2)
        
        //添加按钮
        tipButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        tipButton.frame = CGRect(x: 0, y: 8, width: 36, height: 36)
        tipButton.center.x = bounds.width * 0.5
        
        tipButton.setTitle("😄", for: [])
        tipButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        
        addSubview(tipButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

