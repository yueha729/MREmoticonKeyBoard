//
//  ViewController.swift
//  MREmoticonKeyBoard
//
//  Created by 乐浩 on 16/6/13.
//  Copyright © 2016年 乐浩. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var customTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(MREmoticonVC)
        customTextView.alwaysBounceVertical = true
        customTextView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        customTextView.inputView = MREmoticonVC.view
        
    }
    
    //MARK: - 懒加载
    private lazy var MREmoticonVC: MREmoticonViewController = MREmoticonViewController { [unowned self] (emoticon) in
        
        self.customTextView.insertEmoticon(emoticon)
    }
    
    deinit {
        
        print("I MISS MR")
    }
}

