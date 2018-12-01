//
//  ViewController.swift
//  MyCode
//
//  Created by larry-kof on 2018/11/26.
//  Copyright © 2018 larry-kof. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController, MTKViewDelegate {
    
    var _render:TextureRender!
    override func viewDidLoad() {
        super.viewDidLoad()

        let mtkView = MTKView.init(frame: self.view.bounds)
        mtkView.delegate = self
        self.view = mtkView
        
//        self._render = TextureRender(mtkView: mtkView)
        self._render = FBORender.init(mtkView: mtkView)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    // MARK: delegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
    
    func draw(in view: MTKView) {
        self._render.render()
    }

}
