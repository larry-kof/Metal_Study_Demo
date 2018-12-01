//
//  FBORender.swift
//  MyCode
//
//  Created by larry-kof on 2018/11/29.
//  Copyright © 2018 larry-kof. All rights reserved.
//

import Foundation

import MetalKit

class FBORender:TextureRender {
    
    private var _fboPipelineState: MTLRenderPipelineState!
    private var _middleTexture: MTLTexture!
    
    override init?(mtkView: MTKView) {
        super.init(mtkView: mtkView)
        
        self.setupFBOPipe()
        self.setupMiddleTexture()
    }
    
    // MARK : private func
    private func setupFBOPipe() {
        let defaultLibrary = self._mtkView.device?.makeDefaultLibrary()
        
        let vextexFunction = defaultLibrary?.makeFunction(name: "texVertexShader")
        let fragFunction = defaultLibrary?.makeFunction(name: "fboFragmentShader")
        
        let pipelineStateDesc = MTLRenderPipelineDescriptor.init()
        pipelineStateDesc.vertexFunction = vextexFunction
        pipelineStateDesc.fragmentFunction = fragFunction
        
        pipelineStateDesc.colorAttachments[0].pixelFormat = self._inputTexture.pixelFormat
        
        do {
            try self._fboPipelineState = self._mtkView.device?.makeRenderPipelineState(descriptor: pipelineStateDesc)
        } catch {
            print(error)
        }
    }
    
    private func setupMiddleTexture() {
        let textureDesc = MTLTextureDescriptor.init()
        textureDesc.width = self._inputTexture.width
        textureDesc.height = self._inputTexture.height
        textureDesc.pixelFormat = self._inputTexture.pixelFormat
        textureDesc.usage = [.renderTarget, .shaderRead]
        textureDesc.textureType = .type2D
        
        self._middleTexture = self._mtkView.device?.makeTexture(descriptor: textureDesc)
    }
    
    private func drawToMiddleTexture(command: MTLCommandBuffer, texture: MTLTexture) {
        let renderPassDesc = MTLRenderPassDescriptor.init()
        renderPassDesc.colorAttachments[0].clearColor =  MTLClearColorMake(0.0, 0.0, 0.0, 0.0)
        renderPassDesc.colorAttachments[0].loadAction = .clear
        renderPassDesc.colorAttachments[0].texture = self._middleTexture
        
        let renderEncoder = command.makeRenderCommandEncoder(descriptor: renderPassDesc)
        
        renderEncoder?.setViewport(MTLViewport.init(originX: 0.0, originY: 0.0, width: Double(self._middleTexture.width), height: Double(self._middleTexture.height), znear: -1.0, zfar: 1.0))
        
        renderEncoder?.setRenderPipelineState(self._fboPipelineState)
        
//        renderEncoder?.setVertexBuffer(self._vertice, offset: 0, index: 0)
        renderEncoder?.setFragmentTexture(texture, index: 0)
        renderEncoder?.setVertexBuffer(self._vertice, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: self._numVertice)
        
        renderEncoder?.endEncoding()
    }
    
    // MARK override method
    override func render() -> Void {
        let commanBuffer = self._commandQueue?.makeCommandBuffer()
        
        self.drawToMiddleTexture(command: commanBuffer!, texture: self._inputTexture)
        
        super.draw(commandBuffer: commanBuffer!, texture: self._middleTexture, desDrawble: self._mtkView.currentDrawable!)
        commanBuffer!.commit()
    }
    
    
}
