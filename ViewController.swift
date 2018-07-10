//
//  ViewController.swift
//  GifView
//
//  Created by Steven on 2018/7/8.
//  Copyright © 2018年 Steven. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var gifUrl : String {return "http://img.zcool.cn/community/01497957d37e0d0000018c1ba21817.gif"}

    @IBOutlet weak var gifView: GIFView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load local gif
//        gifView.showGIFImageWithLocalName(name: "image")
        
        
        // load network gif
        gifView.showGIFImageFromNetWork(url: URL(string: gifUrl)!)
    
    }

    @IBAction func reload(_ sender: Any) {
        gifView.showGIFImageFromNetWork(url: URL(string: gifUrl)!)
    }
    
    @IBAction func cleanAndReload(_ sender: Any) {
        
        CacheUtils.deleteFolderCache(folderPath: NSHomeDirectory() + "/Library/Caches/GIFView")
    
        gifView.showGIFImageFromNetWork(url: URL(string: gifUrl)!)
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

