//
//  MREmoticonViewController.swift
//  MREmoticonKeyBoardDemo
//
//  Created by 乐浩 on 16/5/26.
//  Copyright © 2016年 乐浩. All rights reserved.
//

import UIKit

private let MREmoticonCellReuseIdentifier = "MREmoticonCellReuseIdentifier"

class MREmoticonViewController: UIViewController {
    
    var MREmoticonDidSelectedCallBack: (emoticon: MREmoticon)->()
    
    init(callBack: (emoticon: MREmoticon)->()) {
        
        self.MREmoticonDidSelectedCallBack = callBack
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = UIColor.cyanColor()
        
        //初始化UI
        setupUI()
    }
    
    private func setupUI() {
        //1.添加子控件
        view.addSubview(collectionView)
        view.addSubview(toolbar)
        
        //2.布局子控件
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        //定义一个约束数组，存放所有约束
        var cons = [NSLayoutConstraint]()
        
        //定义一个字典，里面放需要约束的控件
        let dict = ["collectionView": collectionView, "toolbar": toolbar]
        
        //VFL约束，H：代表水平约束 V：垂直约束
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[toolbar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-[toolbar(44)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        
        view.addConstraints(cons)
    }
    
    func itemClick(item: UIBarButtonItem) {
        
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: item.tag), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
    }
    
    //MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {
        
        let clv = UICollectionView(frame: CGRectZero, collectionViewLayout: MREmoticonLayout())
        clv.backgroundColor = UIColor.clearColor()
        
        //注册一个cell
        clv.registerClass(MREmoticonCell.self, forCellWithReuseIdentifier: MREmoticonCellReuseIdentifier)
        clv.dataSource = self
        clv.delegate = self
        return clv
    }()
    
    private lazy var toolbar: UIToolbar = {
        let bar = UIToolbar()
        bar.tintColor = UIColor.darkGrayColor()
        var items = [UIBarButtonItem]()
        
        var index = -1
        for title in ["最近", "默认", "emoji", "浪小花"] {
            
            let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MREmoticonViewController.itemClick(_:)))

            index += 1
            item.tag = index
            
            items.append(item)
            
            //给item之间增加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        }
        //去掉最后一个
        items.removeLast()
        
        bar.items = items
        
        return bar
    }()
    
    private lazy var packages: [MREmoticonPackage] = MREmoticonPackage.packageList
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UICollectionViewDataSource
extension MREmoticonViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return packages.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return packages[section].emoticons?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MREmoticonCellReuseIdentifier, forIndexPath: indexPath) as! MREmoticonCell
        
        //取出对应的组
        let package = packages[indexPath.section]
        //取出对应组对应行的模型
        let emoticon = package.emoticons![indexPath.item]
        
        cell.emoticon = emoticon
        return cell
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //1. 处理最近表情, 将当前使用的表情添加到最近表情的书数组中
        let emoticon = packages[indexPath.section].emoticons![indexPath.item]
        
        //if !emoticon.isRemoveButton{
            emoticon.times += 1
            packages[0].appendEmoticons(emoticon)
        //}
        
        //2. 回调通知使用者当前点击了哪个表情
        MREmoticonDidSelectedCallBack(emoticon: emoticon)
        
    }
}

//自定义cell
class MREmoticonCell: UICollectionViewCell {
    
    var emoticon: MREmoticon? {
        
        didSet{
            //1.判断是否是图片表情
            if emoticon?.chs != nil {
                
                iconButton.setImage(UIImage(contentsOfFile: emoticon!.imagePath!), forState: UIControlState.Normal)
            }else { 
                //防止重用
                iconButton.setImage(nil, forState: UIControlState.Normal)
            }
            
            //2.设置emoji表情
            //加上？？ 可以防止重用
            iconButton.setTitle(emoticon!.emojiStr ?? "", forState: UIControlState.Normal)
            
            //3.是否是删除按钮
            if emoticon!.isRemoveButton {
                iconButton.setImage(UIImage(named:"compose_emotion_delete"), forState: UIControlState.Normal)
                iconButton.setImage(UIImage(named:"compose_emotion_delete_highlighted"), forState: UIControlState.Highlighted)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //初始化UI
        setupUI()
    }
    
    /**
     初始化UI
     */
    private func setupUI() {
        
        contentView.addSubview(iconButton)
        //iconButton.frame = contentView.bounds
        
        //设置button之间的空隙 用这个方法会平分
        iconButton.frame = CGRectInset(contentView.bounds, 4, 4)
        
        iconButton.backgroundColor = UIColor.whiteColor()
        iconButton.userInteractionEnabled = false
    }
    
    //MARK: - 懒加载
    private lazy var iconButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFontOfSize(32)
        return btn
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//自定义一个layout
private class MREmoticonLayout: UICollectionViewFlowLayout {
    
    private override func prepareLayout() {
        super.prepareLayout()
        
        //1. 设置cell相关的属性
        let width = collectionView!.bounds.width / 7
        itemSize = CGSize(width: width, height: width)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        
        //2. 设置collectionView相关的属性
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView?.pagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
        
        //0.48 这里最好不要用0.5 CGFloat不准确
        let y = (collectionView!.bounds.height - 3 * width) * 0.48
        collectionView?.contentInset = UIEdgeInsets(top: y, left: 0, bottom: y, right: 0)
    }
}