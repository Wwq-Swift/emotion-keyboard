//
//  WQEmoticonManager.swift
//  WQEmoticon
//
//  Created by 王伟奇 on 2017/7/31.
//  Copyright © 2017年 王伟奇. All rights reserved.
//

import UIKit

//表情管理器
class WQEmoticonManager {
    
    // 为了便于表情的复用，建立一个单例，只加载一次表情数据
    /// 表情管理器的单例
    static let shared = WQEmoticonManager()
    
    //表情包的懒加载数组 - 第一个数组是最近表情， 加载之后，表情数组为空
    lazy var packages = [WQEmotionPackage]()
    
    //表情素材的bundle
    lazy var bundle: Bundle? = {
        guard let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil) else {
            return nil
        }
        return Bundle(path: path)
    }()
    
    //构造函数， 如果在init 之前增加private 修饰符，可以要求调用者必须通过 shared 访问对象
    //oc 要重写 allocWithZone 方法
    private init() {
        loadPackages()
    }
    
    //最近使用的表情
    /// - Parameter em: 选中的表情
    func recentEmoticon(em: WQEmotion)  {
        
        //1. 增加表情的使用次数
        em.emotionUseTimes += 1
        
        //2. 判断是否已经记录了该表情， 使用次数高的排序靠前
        if !packages[0].emoticons.contains(em){
            packages[0].emoticons.append(em)
        }
    
        // 3. 根据使用次数排序，使用次数高的排序靠前
        // 对当前数组排序
        //        packages[0].emoticons.sort { (em1, em2) -> Bool in
        //            return em1.times > em2.times
        //        }
        // 在 Swift 中，如果闭包只有一个 return，参数可以省略，参数名 用 $0... 替代
        packages[0].emoticons.sort { $0.emotionUseTimes > $1.emotionUseTimes }
        
        //4. 判断表情数组是否超出 20 ，如果超出，删除末尾的表情
        if packages[0].emoticons.count > 20 {
            packages[0].emoticons.removeSubrange(20..<packages[0].emoticons.count)    //移除数组指定range 的部分
        }
        
    }
}

// MARK: - 表情字符串的处理
extension WQEmoticonManager {
    
    ///将给定的字符串转换成属性文本
    ///
    /// 关键点： 按照匹配结果倒序替换属性文本
    /// - Parameters:
    ///   - string: 完整字符串
    ///   - font: 字体
    /// - Returns: 返回的属性文本
    func emoticonString(string: String, font: UIFont) -> NSAttributedString {
        
        //NSAttributedString 是不可变的
        let attrString = NSMutableAttributedString(string: string)
        
        //1. 建立正则表达式，过滤所有的表情文字
        //【】 （） 都是正则表达式的关键字，如果要参与匹配，需要转义
        let pattern = "\\[.*?\\]"
        
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else{
            return attrString
        }
        
        //2. 匹配所有项
        let mathes = regx.matches(in: string, options: [], range: NSRange(location: 0, length: attrString.length))
        
        //3. 遍历所有的匹配结果
        for m in mathes.reversed() {   // reversed() 倒序遍历
            
            let r = m.rangeAt(0)
            
            let subStr = (attrString.string as NSString).substring(with: r)
            
            //1> 使用 subStr 查找对应的表情符号
            if let em = WQEmoticonManager.shared.findEmoticon(string: subStr) {
                
                //2> 使用表情符号的属性文本，替换原有的属性文本内容
                attrString.replaceCharacters(in: r, with: em.imageText(font: font))
            }
        }
        
        //4. 统一设置一遍字符串的属性，除了需要设置字体，还需要设置颜色
        attrString.addAttributes([NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.darkGray], range: NSRange(location: 0, length: attrString.length))
        
        return attrString
    }
    
    /// 根据 string `[爱你]` 在所有的表情符号中查找对应的表情模型对象
    ///
    /// - 如果找到，返回表情模型
    /// - 否则，返回 nil
    func findEmoticon(string: String) -> WQEmotion? {
        
        // 1. 遍历表情包
        // OC 中过滤数组使用 [谓词]
        // Swift 中更简单
        for p in packages {
            
            // 2. 在表情数组中过滤 string
            // 方法1
            //            let result = p.emoticons.filter({ (em) -> Bool in
            //                return em.chs == string
            //            })
            // 方法2 - 尾随闭包
            //            let result = p.emoticons.filter() { (em) -> Bool in
            //                return em.chs == string
            //            }
            // 方法3 - 如果闭包中只有一句，并且是返回
            // 1> 闭包格式定义可以省略
            // 2> 参数省略之后，使用 $0, $1... 依次替代原有的参数
            //            let result = p.emoticons.filter() {
            //                return $0.chs == string
            //            }
            // 方法4 - 如果闭包中只有一句，并且是返回
            // 1> 闭包格式定义可以省略
            // 2> 参数省略之后，使用 $0, $1... 依次替代原有的参数
            // 3> return 也可以省略
            let result = p.emoticons.filter() { $0.chs == string }
            
            // 3. 判断结果数组的数量
            if result.count == 1 {
                return result[0]
            }
        }
        
        return nil
    }
    
}

//MARK: - 表情包数据处理
fileprivate extension WQEmoticonManager {
    
    func loadPackages() {
        
        // 读取 emoticons.plist
        // 只要按照 bundle 默认的目录结构设定，就可以直接读取 resources 目录下的文件
        guard let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
            let bundle = Bundle(path: path),
            let plistPath = bundle.path(forResource: "emoticons.plist", ofType: nil),
            let array = NSArray(contentsOfFile: plistPath) as? [[String: String]],
            let models = NSArray.yy_modelArray(with: WQEmotionPackage.self, json: array) as? [WQEmotionPackage]
            
            else {
                
                return
        }
        
        // 设置表情包数据
        // 使用 += 不需要再次给 packages 分配空间，直接追加数据
        packages += models
        
    }
}

