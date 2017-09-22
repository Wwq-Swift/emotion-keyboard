//
//  WQEmoticonInputView.swift
//  WQEmoticon
//
//  Created by 王伟奇 on 2017/7/31.
//  Copyright © 2017年 王伟奇. All rights reserved.
//

import UIKit

//可重用标识符
private let cellId = "cellId"

class WQEmoticonInputView: UIView {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    //工具栏
    @IBOutlet weak var toolbar: WQEmoticonToolbar!
    //分页控制器
    @IBOutlet weak var pageControll: UIPageControl!
    //选中表情回调闭包属性
    fileprivate var selectedEmoticonCallBack: ((_ emoticon: WQEmotion?) -> Void)?
    
    //加载并且返回输入视图
    class func inputView(selectedEmoticon: @escaping (_ emoticon: WQEmotion?) -> Void) -> WQEmoticonInputView {
        let nib = UINib(nibName: "WQEmoticonInputView", bundle: nil)
        
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WQEmoticonInputView
        
        //记录闭包
        v.selectedEmoticonCallBack = selectedEmoticon
        
        return v
    }
    
    override func awakeFromNib() {
        collectionView.backgroundColor = UIColor.white
        
        //注册可重用cell
        collectionView.register(WQEmoticonCell.self, forCellWithReuseIdentifier: cellId)
        
        //设置工具栏代理
        toolbar.delegate = self
        
        //设置分页控件的图片
        let bundle = WQEmoticonManager.shared.bundle
        
        guard let normolImage = UIImage(named: "compose_keyboard_dot_normal", in: bundle, compatibleWith: nil),
            let selectedImage = UIImage(named: "compose_keyboard_dot_selected", in: bundle, compatibleWith: nil) else{
                return
        }
        
        // 使用填充图片设置颜色
                pageControll.pageIndicatorTintColor = UIColor(patternImage: normolImage)
                pageControll.currentPageIndicatorTintColor = UIColor(patternImage: selectedImage)
        
        //使用 KVC 设置私有成员属性
//        pageControll.setValue(normolImage, forKey: "_pageImage")
//        pageControll.setValue(selectedImage, forKey: "_currentPageImage")
    }
}

extension WQEmoticonInputView: WQEmoticonToolbarDelegate{
    
    func emoticonToolbarDidSelecteddItemIndex(toolbar: WQEmoticonToolbar, index: Int) {
        // 让 collectionView 发生滚动 -> 每一个分组的第0页
        let indexPath = IndexPath(item: 0, section: index)
        
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
        // 设置分组按钮的选中状态
        toolbar.selectedIndex = index
    }
    
}

// MARK: - UICollectionViewDelegate
extension WQEmoticonInputView: UICollectionViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //1. 获取中心点
        var center = scrollView.center
        center.x += scrollView.contentOffset.x
        
        //2. 获取当前显示的 cell 的indexpath
        let paths = collectionView.indexPathsForVisibleItems
        
        //3. 判断中心点在那一个 indexPath 上， 在哪一个页面上
        var targetIndexPath: IndexPath?
        
        for indexPath in paths {
            
            //1> 根据 indexPath 获取 cell
            let cell = collectionView.cellForItem(at: indexPath)
            
            //2> 判断中心点位置
            if cell?.frame.contains(center) == true {
                targetIndexPath = indexPath
                
                break
            }
        }
        
        guard let target = targetIndexPath else {
            return
        }
        
        //4. 判断是否找到 目标的 indexPath
        // indexPath.section -》 对应的就是分组
        toolbar.selectedIndex = target.section
        
        //5. 设置分页控件
        //总页数 不同的分组， 页数不一样
        pageControll.numberOfPages = collectionView.numberOfItems(inSection: target.section)
        pageControll.currentPage = target.item
        
    }
}

//MARK: - UICollectionViewDataSource
extension WQEmoticonInputView: UICollectionViewDataSource {
    
    //分组数量 - 返回表情包的数量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return WQEmoticonManager.shared.packages.count
    }
    
    // 返回每个分组中的表情`页`的数量
    // 每个分组的表情包中 表情页面的数量 emoticons 数组 / 20
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WQEmoticonManager.shared.packages[section].numberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //1. 取 cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! WQEmoticonCell
        
        //2. 设置cell 传递对应页面的表情数组
        cell.emoticons = WQEmoticonManager.shared.packages[indexPath.section].emoticon(page: indexPath.item)
        
        // 设置代理
        cell.delegate = self
        
        //3. 返回cell
        return cell
    }
}

// MARK: - CZEmoticonCellDelegate
extension WQEmoticonInputView: WQEmotionCellDelegate {
    
    /// 选中的表情回调
    ///
    /// - Parameters: 分页cell
    ///   - cell: cell
    ///   - em: 选中的表情 删除键为nil
    func emoticonCellDidSelectedEmoticon(cell: WQEmoticonCell, em: WQEmotion?) {
        
        //执行闭包，回调选中的表情
        selectedEmoticonCallBack?(em)
        
        //添加最近使用的表情
        guard let em = em else {
            return
        }
        
        //如果当前 collectionView 就是最近的分组， 不添加最近使用的表情
        let indexPath = collectionView.indexPathsForVisibleItems[0]
        if indexPath.section == 0 {
            return
        }
        
        //添加最近使用的表情
        WQEmoticonManager.shared.recentEmoticon(em: em)
        
        //刷新数据 第 0 组
        var indexSet = IndexSet()
        indexSet.insert(0)
        
        collectionView.reloadSections(indexSet)
    }
}

