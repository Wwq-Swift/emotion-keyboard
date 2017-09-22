//
//  WQEmotionPackage.swift
//  WQEmotion
//
//  Created by 王伟奇 on 2017/7/30.
//  Copyright © 2017年 王伟奇. All rights reserved.
//

import UIKit
import YYModel

//表情包模型
class WQEmotionPackage: NSObject {
    
    // 表情包的分组名字
    var groupName: String?
    
    //背景图片名称
    var bgImageName: String?
    
    //懒加载的表情的空数组
    //使用懒加载可以避免后续的解包
    lazy var emoticons = [WQEmotion]()
    
    /// 表情包目录，从目录下加载 info.plist 可以创建表情模型数组
    var directory: String? {
        didSet{
            
            //当设置目录时候，从目录下载info.plist
            guard let directory = directory,
                  let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
                  let bundle = Bundle(path: path),
                  let infoPath = bundle.path(forResource: "info.plist", ofType: nil, inDirectory: directory),
                  let array = NSArray(contentsOfFile: infoPath) as? [[String: String]],
                  let models = NSArray.yy_modelArray(with: WQEmotion.self, json: array) as? [WQEmotion] else {
                return
            }
            
            //遍历 models 数组，设置每一个表情的目录
            for model in models {
                model.emotionDirectory = directory
            }
            
            //设置表情数组
            emoticons += models
            
        }
    }
    
    //表情页面数量
    var numberOfPages: Int {
        return (emoticons.count - 1) / 20 + 1
    }
    
    //从懒加载的表情包中，按照 page 截取最多 20 个表情模型的数组
    //例如 26个表情 page = 0 返回 0～19 个表情， page = 1 返回 20～25的表情
    func emoticon(page: Int) -> [WQEmotion] {
        
        //每页的数量
        let cont = 20
        let location = page * cont
        var length = cont
        
        //判断数组是否越界
        if location + length > emoticons.count {
            length = emoticons.count - location
        }
        
        let range = NSRange(location: location, length: length)
        
        //截取数组的子数组
        let subArray = (emoticons as NSArray).subarray(with: range)
        
        return subArray as! [WQEmotion]
    }
    
    override var description: String {
        return yy_modelDescription()
    }
}
