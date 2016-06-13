//
//  MRTextView+Category.swift
//  MREmoticonKeyBoardDemo
//
//  Created by 乐浩 on 16/5/30.
//  Copyright © 2016年 乐浩. All rights reserved.
//

import UIKit

extension UITextView {
    
    func insertEmoticon(emoticon: MREmoticon) {
        
        //判断是否是删除按钮
        if emoticon.isRemoveButton {
            
            deleteBackward()
        }
        
        //1.判断当前点击的是否是emoji表情
        if emoticon.emojiStr != nil {
            
            // self.customTextView.selectedTextRange! 当前光标选中的range
            // 这个方法就是 把光标选中的区域替换成想要的
            self.replaceRange(self.selectedTextRange!, withText: emoticon.emojiStr!)
        }
        
        //2.判断当前点击的是否是表情图片
        if emoticon.png != nil {
            
            //2.3 根据附件创建属性字符串
            let imageText = MREmoticonTextAttachment.imageText(emoticon, font: font!)
            
            //2.4 拿到当前所有的内容
            let strM = NSMutableAttributedString(attributedString: self.attributedText)
            
            //2.5 插入表情到当前光标的位置
            let range = self.selectedRange
            strM.replaceCharactersInRange(range, withAttributedString: imageText)
            
            //属性字符串有自己默认的尺寸，所以这里要重新添加一个属性，设置图片大小和字体大小一样
            strM.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(range.location, 1))
            
            //2.6 将替换后的字符串赋值给TextView
            self.attributedText = strM
            
            //2.7 恢复光标所在的位置
            // NSMakeRange(range.location + 1, 0) 这里的两个参数：第一个是指光标所在的位置，第二个是指选中文本的个数
            self.selectedRange = NSMakeRange(range.location + 1, 0)
        }

    }
    
    func emoticonAttributedText() -> String {
        var strM = String()
        //  获取需要发送给服务器的文字
        self.attributedText.enumerateAttributesInRange(NSMakeRange(0, self.attributedText.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (objc, range, _) in
            
            /*
             //遍历的时候传递给我们的objc是一个字典,如果字典中的NSAttachment这个key对应的Value有值
             //那么就证明当前是一个图片
             print("I MISS MR objc ----- \(objc["NSAttachment"])")
             
             //range 是纯字符串的范围
             // 如果纯字符串中间有图片表情，那么range就会传递多次
             print("I MISS MR objc ----- \(range)")
             let res = (self.customTextView.text as NSString).substringWithRange(range)
             print("I MISS MR objc ----- \(res)")
             */
            
            if objc["NSAttachment"] != nil {
                
                let attachment = objc["NSAttachment"] as! MREmoticonTextAttachment
                
                strM += attachment.chs!
                
            }else {
                
                strM += (self.text as NSString).substringWithRange(range)
            }
        }
        return strM
    }
}
