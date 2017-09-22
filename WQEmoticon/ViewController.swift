//
//  ViewController.swift
//  WQEmoticon
//
//  Created by 王伟奇 on 2017/7/31.
//  Copyright © 2017年 王伟奇. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var emoticonView: WQEmoticonInputView = WQEmoticonInputView.inputView { (emoticon) in
        self.textView.insertEmoticon(em: emoticon)
    }
    @IBOutlet weak var textView: WQComposeTextView!
    @IBAction func tap(_ sender: UIButton) {
        

        // 2> 设置键盘视图
        textView.inputView = emoticonView
        
        // 3> !!!刷新键盘视图
        textView.reloadInputViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.becomeFirstResponder()
    }


}

