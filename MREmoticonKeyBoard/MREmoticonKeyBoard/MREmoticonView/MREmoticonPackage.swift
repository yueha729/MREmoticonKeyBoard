//
//  MREmoticonPackage.swift
//  MREmoticonKeyBoardDemo
//
//  Created by 乐浩 on 16/5/27.
//  Copyright © 2016年 乐浩. All rights reserved.
//

/*
 结构：
 1. 加载emoticons.plist拿到每组表情的路径
 
 emoticons.plist(字典)  存储了所有组表情的数据
 |----packages(字典数组)
    |----id(存储了对应组表情对应的文件夹)
 
 2. 根据拿到的路径加载对应组表情的info.plist
 info.plist(字典)
 |----id(当前组表情文件夹的名称)
 |----group_name_cn(组的名称)
 |----emoticons(字典数组, 里面存储了所有表情)
    |----chs(表情对应的文字)
    |----png(表情对应的图片)
    |----code(emoji表情对应的十六进制字符串)
 */

import UIKit

class MREmoticonPackage: NSObject {
    
    /// 存储了对应组表情对应的文件夹
    var id: String?
    /// 组的名称
    var group_name_cn: String?
    /// 当前组所有的表情对象
    var emoticons: [MREmoticon]?
    
    static let packageList: [MREmoticonPackage] = MREmoticonPackage.loadPackages()
    /**
     获取所有表情组的表情数组
     MREmoticonPackage: 三组：浪小花(MREmoticon) 默认(MREmoticon) emoji(MREmoticon)
     - returns: 一个数组，里面存储的都是MREmoticonPackage
     */
    private class func loadPackages() -> [MREmoticonPackage] {
        
        var packages = [MREmoticonPackage]()
        
        //1.创建最近组
        let pk = MREmoticonPackage(id: "")
        pk.group_name_cn = "最近"
        pk.emoticons = [MREmoticon]()
        pk.appendEmptyEmoticons()
        packages.append(pk)
        
        let path = NSBundle.mainBundle().pathForResource("emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")
        
        //2.加载emoticons.plist
        let dict = NSDictionary(contentsOfFile: path!)
        
        //从emoticons.plist中获取packages
        let dictArray = dict!["packages"] as! [[String: AnyObject]]
        
        //3.遍历packages数组
        for dic in dictArray {
            
            //4.取出id，创建对应的组
            let package = MREmoticonPackage(id: dic["id"] as! String)
            
            packages.append(package)
            
            package.loadEmoticons()
            
            package.appendEmptyEmoticons()
            
        }
        return packages
    }
    
    /**
     加载每一组所有的表情
     */
    func loadEmoticons(){
        
        let emoticonDict = NSDictionary(contentsOfFile: infoPath("info.plist"))
        group_name_cn = emoticonDict!["group_name_cn"] as? String
        let dictArray = emoticonDict!["emoticons"] as! [[String: String]]
        emoticons = [MREmoticon]()
        var index = 0
        for dict in dictArray {
            
            if index == 20 {
                
                emoticons?.append(MREmoticon(isRemoveButton: true))
                index = 0
            }
            emoticons?.append(MREmoticon(dict: dict, id: id!))
            index += 1
        }
        
    }
    
    /**
     追加空白按钮
     如果一页没有21个，就添加空白按钮补齐
     */
    func appendEmptyEmoticons(){
        let count = emoticons!.count % 21
        for _ in count ..< 20 {
            //追加空白按钮
            emoticons?.append(MREmoticon(isRemoveButton: false))
        }
        //追加删除按钮
        emoticons?.append(MREmoticon(isRemoveButton: true))
        
    }
    
    /**
     用于给最近组添加表情
     */
    func appendEmoticons(emoticon: MREmoticon) {
        
        //1. 判断是否是删除按钮
        if emoticon.isRemoveButton {
            
            return
        }
        
        //2.判断当前点击的按钮是否已经添加到最近组中
        let contains = emoticons!.contains(emoticon)
        if !contains {
            //删除 删除按钮
            emoticons?.removeLast()
            emoticons?.append(emoticon)
        }
        
        //3.对数组进行排序
        //Self.Generator.Element 指的是emoticons中的对象 返回排好序的数组
        var result = emoticons?.sort({ (e1, e2) -> Bool in
            return e1.times > e2.times
        })
        
        //4.删除多余的表情
        if !contains {
            
            result?.removeLast()
            //添加一个删除按钮
            result?.append(MREmoticon(isRemoveButton: true))
        }
        
        emoticons = result
    }
    
    /**
     获取指定文件的全路径
     这里获取的是info.plist文件的全路径
     - returns:全路径
     */
    func infoPath(fileName: String) -> String {
        
        return (MREmoticonPackage.emoticonPath().stringByAppendingPathComponent(id!) as NSString).stringByAppendingPathComponent(fileName)
    }
    
    /**
     获取表情主路径
     - returns:主路径
     */
    class func emoticonPath() -> NSString {
        
        return (NSBundle.mainBundle().bundlePath as NSString) .stringByAppendingPathComponent("Emoticons.bundle")
    }
    
    init(id: String) {
        
        self.id = id
    }
}

class MREmoticon: NSObject {
    
    /// 表情对应的文字
    var chs: String?
    /// 表情对应的图片
    var png: String?{
        
        didSet{
            imagePath = (MREmoticonPackage.emoticonPath().stringByAppendingPathComponent(id!) as NSString).stringByAppendingPathComponent(png!)
        }
    }
    /// emoji表情对应的十六进制字符串
    var code: String?{
        didSet{
            //1.从字符串中取出十六进制的数
            //创建一个扫描器，扫描器可以从字符串中提取我们想要的数据
            let scanner = NSScanner(string: code!)
            
            //2.将十六进制转换为字符串
            //HexInt 十六进制
            //UnsafeMutablePointer<UInt32> 传递一个地址 Pointer
            var result: UInt32 = 0
            
            //这里会从字符串中扫描到了十六进制就会把这个十六进制赋值给result
            scanner.scanHexInt(&result)
            
            //3.将十六进制转换为emoji字符串
            emojiStr = "\(Character(UnicodeScalar(result)))"
        }
    }
    /// emoji字符串
    var emojiStr: String?
    /// 当前表情对应的文件夹
    var id: String?
    /// 获取表情的全历经
    var imagePath: String?
    /// 标记是否是删除按钮
    var isRemoveButton: Bool = false
    /// 记录当前表情被使用的次数
    var times: Int = 0
    
    init(isRemoveButton: Bool) {
        
        super.init()
        self.isRemoveButton = isRemoveButton
    }
    
    init(dict: [String: String], id: String) {
        super.init()
        self.id = id
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
}
