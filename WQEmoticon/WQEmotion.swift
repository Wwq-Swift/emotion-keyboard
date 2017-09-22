//
//  WQEmotion.swift
//  WQEmotion
//
//  Created by 王伟奇 on 2017/7/30.
//  Copyright © 2017年 王伟奇. All rights reserved.
//

import UIKit
import YYModel

//表情模型
class WQEmotion: NSObject {
    
    //表情类型  图片类型和emoji类型 true 为emoji类型
    var type = false
    
    //表情字符串 发送给服务器节省流量
    var chs: String?
    
    //表情图片名称， 用于本地图文混排
    var png: String?
    
    //emoji 的十六进制的编码
    var code: String? {
        didSet{
            
            guard let code = code else {
                return
            }
            
            let scanner = Scanner(string: code) //扫描所有字符，忽略空格 换行等
            
            var result: UInt32 = 0
            scanner.scanHexInt32(&result)
            
            emoji = String(Character(UnicodeScalar(result)!))
        }
    }
    
    //表情的使用次数
    var emotionUseTimes: Int = 0
    //emoji的字符串
    var emoji:  String?
    
    //表情模型所在的目录
    var emotionDirectory: String?
    
    //"图片"表情对应的图像
    var image: UIImage? {
        
        //判断表情的类型
        if type {
            return nil
        }
        
        guard let emotionDirectory = emotionDirectory,
              let png = png,
              let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
              let bundle = Bundle(path: path) else{
            return nil
        }
        
        return UIImage(named: "\(emotionDirectory)/\(png)", in: bundle, compatibleWith: nil)
    }
    
    //将当前的图像转成生成图片的属性文本
    func imageText(font: UIFont) -> NSAttributedString {
        
        //1. 判断图片是否存在
        guard let image = image else {
            return NSAttributedString(string: "")
        }
        
        //2. 创建文本附件
        let attachment = WQEmoticonAttachment()
        
        //记录属性文本文字
        attachment.chs = chs
        
        attachment.image = image
        let height = font.lineHeight
        
        attachment.bounds = CGRect(x: 0, y: -4, width: height, height: height)
        
        //3. 返回图片的属性文本
        let attributeString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        
        attributeString.addAttributes([NSFontAttributeName: font], range: NSRange(location: 0, length: 1))
        
        //4. 返回属性文本
        return attributeString
        
    }
    
    override var description: String {
        return yy_modelDescription()
    }
}
