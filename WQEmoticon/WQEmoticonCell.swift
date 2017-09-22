//
//  WQEmoticonCell.swift
//  WQEmoticon
//
//  Created by 王伟奇 on 2017/7/31.
//  Copyright © 2017年 王伟奇. All rights reserved.
//

import UIKit

/// 表情 Cell 的协议
@objc protocol WQEmotionCellDelegate: NSObjectProtocol {
    
    /// 表情cell 选中表情模型
    //
    ///   - cell: cell
    ///   - em: 表情模型 ／ nil为删除按钮
    func emoticonCellDidSelectedEmoticon(cell: WQEmoticonCell, em: WQEmotion?)
    
}

//表情的页面 Cell
// 每一个 cell 就是和 collectionView 的 bouns 一样大
// 每一个 cell 中用九宫格算法， 自行添加 20 个表情
// 最后一个位置放删除按钮
class WQEmoticonCell: UICollectionViewCell {
    
    //代理属性
    weak var delegate: WQEmotionCellDelegate?
    
    /// 当前页面的表情模型数组 ，最多 20 个表情
    var emoticons: [WQEmotion]? {
        didSet{
            
            //1. 隐藏所有按钮
            for v in contentView.subviews {
                v.isHidden = true
            }
            
            //显示删除按钮
            contentView.subviews.last?.isHidden = false
            
            //2. 遍历表情模型数组，设置按钮图像
            for (i, em) in (emoticons ?? []).enumerated() {
                
                //1》取出按钮
                if let btn = contentView.subviews[i] as? UIButton {
                    
                    // 设置图像 - 如果图像为 nil 会清空图像，避免复用
                    btn.setImage(em.image, for: .normal)
                    
                    // 设置 emoji 的字符串 - 如果 emoji 为nil 会清空 title 避免fungi
                    btn.setTitle(em.emoji, for: [])
                    
                    btn.isHidden = false
                }
            }
        }
    }
    
    // 表情选择视图
    private lazy var tipView = WQEmoticonTipView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 当视图从界面上删除，同样会调用此方法，  newWindow == nil
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        guard let w = newWindow else {
            return
        }
        
        //将提示视图添加到窗口上
        w.addSubview(tipView)
        tipView.isHidden = true
    }
    
    // MARK: - 监听方法
    //选中表情按钮
    @objc fileprivate func selectedEmoticonButton(button: UIButton) {
        
        //1. 取 tag 0～20 对应的按钮
        let tag = button.tag
        
        //2. 根据 tag 判断是否为删除按钮， 如果不是删除按钮 ，取得表情
        var em: WQEmotion?
        if tag < (emoticons?.count ?? 0) {
            em = emoticons?[tag]
        }
        
        //3. em 要么是选中的模型， 如果为nil 对应的是删除按钮
        delegate?.emoticonCellDidSelectedEmoticon(cell: self, em: em)
    }
    
    /// 长按手势识别， 是一个非常重要的手势
    /// 可以保证一个对象监听两种点击手势， 而且不需要考虑手势冲突
    @objc fileprivate func longGesture(gusture: UILongPressGestureRecognizer) {
        
        //1> 获取触摸位置
        let location = gusture.location(in: self)
        
        //2> 获取触摸位置对应的按钮
        guard let button = buttonWithLocation(location: location) else {
            
            tipView.isHidden = true
            
            return
        }
        
        //3> 处理手势状态
        // 在处理手势细节的时候， 不要试图一下把所有的状态都处理完毕
        switch gusture.state {
        case .began, .changed:
            
            tipView.isHidden = false
            
            // 坐标系转换 -> 将按钮参照 cell 的坐标系， 转换到windo 的坐标位置
            let center = self.convert(button.center, to: window)
            
            //设置提示视图的位置
            tipView.center = center
            
            //设置提示视图的表情模型
            if button.tag < emoticons?.count ?? 0 {
                tipView.emoticon = emoticons?[button.tag]
            }
            
        case .ended:
            
            tipView.isHidden = true
            
            //执行选中按钮的函数
            selectedEmoticonButton(button: button)
            
        case .cancelled, .failed:
            
            tipView.isHidden = true
            
        default:
            break
        }
    }
    
    private func buttonWithLocation(location: CGPoint) -> UIButton? {
        
        // 遍历 contentView 所有的子视图，如果可见，同时在 location 确认是按钮
        for btn in contentView.subviews as! [UIButton] {
            
            // 删除按钮同样需要处理
            if btn.frame.contains(location) && !btn.isHidden && btn != contentView.subviews.last {
                return btn
            }
        }
        
        return nil
    }
    
}

//MARK: - 设置界面
fileprivate extension WQEmoticonCell {
    
    // 从 xib 加载，bounds 是 xib 中定义的大小，不是 size 的大小
    // 从纯代码创建， bounds 是就是布局属性中设置的 itemSize
    func setupUI() {
        
        let rowCont = 3
        let colCont = 7
        
        //左右间距
        let leftMargin: CGFloat = 8
        
        //底部间距， 为分野控件预留空间
        let bottomMargin: CGFloat = 16
        
        let w = (bounds.width - 2 * leftMargin) / CGFloat(colCont)
        let h = (bounds.height - bottomMargin) / CGFloat(rowCont)
        
        //连续创建 21 个按钮
        for i in 0..<21 {
            
            let row = i / colCont
            let col = i % colCont
            
            let btn = UIButton()
            
            // 设置按钮的大小
            let x = leftMargin + CGFloat(col) * w
            let y = CGFloat(row) * h
            
            btn.frame = CGRect(x: x, y: y, width: w, height: h)
            
            contentView.addSubview(btn)
            
            // 设置按钮的字体大小， lineHeight 基本上和图片的大小差不多大
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
            
            //设置按钮的tag
            btn.tag = i
            
            //添加按钮触发事件
            btn.addTarget(self, action: #selector(selectedEmoticonButton), for: .touchUpInside)
        }
        
        //取出末尾的删除按钮
        let removeButton = contentView.subviews.last as! UIButton
        
        //设置图像
        let image = UIImage(named: "compose_emotion_delete_highlighted", in: WQEmoticonManager.shared.bundle, compatibleWith: nil)
        removeButton.setImage(image, for: .normal)
        
        //添加长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longGesture(gusture:)))
        
        longPress.minimumPressDuration = 0.1
        addGestureRecognizer(longPress)
        
    }
}
