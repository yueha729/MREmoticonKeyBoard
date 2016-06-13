//
//  MREmoticonTextAttachment.swift
//  MREmoticonKeyBoardDemo
//
//  Created by 乐浩 on 16/5/30.
//  Copyright © 2016年 乐浩. All rights reserved.
//

import UIKit

class MREmoticonTextAttachment: NSTextAttachment {

    /// 保存对应的表情文字
    var chs: String?
    
    class func imageText(emoticon: MREmoticon, font: UIFont) -> NSAttributedString {
        
        //2.1 创建附件
        let attachment = MREmoticonTextAttachment()
        attachment.chs = emoticon.chs
        attachment.image = UIImage(contentsOfFile: emoticon.imagePath!)
        
        //2.2 设置附件的大小
        let s = font.lineHeight
        attachment.bounds = CGRectMake(0, -4, s, s)
        
        //2.3 根据附件创建属性字符串
        return NSAttributedString(attachment: attachment)
    }
}
