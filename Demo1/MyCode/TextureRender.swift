//
//  TextureRender.swift
//  MyCode
//
//  Created by larry-kof on 2018/11/29.
//  Copyright © 2018 larry-kof. All rights reserved.
//

import Foundation
import MetalKit

class TextureRender {
    //MARK: Properties
    var _mtkView: MTKView!
    var _portViewSize: CGSize!
    var _pipelineState: MTLRenderPipelineState!
    var _vertice: MTLBuffer?
    var _numVertice: NSInteger = 0
    var _commandQueue: MTLCommandQueue?
    
    var _inputTexture:MTLTexture!
    
    //MARK: Initialization
    init?( mtkView:MTKView ) {
        self._mtkView = mtkView
        
        self._mtkView.device = MTLCreateSystemDefaultDevice()
        self._portViewSize = self._mtkView.drawableSize

        self.customInit()
    }
    
    // MARK: private function
    private func customInit() {
        self.setupPipe()
        self.setupVertex()
        self.setupTexture()
        self._commandQueue = self._mtkView.device?.makeCommandQueue()
    }
    
    private func setupPipe() {
        let defaultLibrary = self._mtkView.device?.makeDefaultLibrary()
        
        let vextexFunction = defaultLibrary?.makeFunction(name: "texVertexShader")
        let fragFunction = defaultLibrary?.makeFunction(name: "texFragmentShader")
        
        let pipelineStateDesc = MTLRenderPipelineDescriptor.init()
        pipelineStateDesc.vertexFunction = vextexFunction
        pipelineStateDesc.fragmentFunction = fragFunction
        
        pipelineStateDesc.colorAttachments[0].pixelFormat = self._mtkView.colorPixelFormat
        
        do {
            try self._pipelineState = self._mtkView.device?.makeRenderPipelineState(descriptor: pipelineStateDesc)
        } catch {
            print(error)
        }
    }
    
    private func setupTexture() {
        let url = Bundle.main.url(forResource: "miami_beach", withExtension: "tga")
        let image = AAPLImage.init(tgaFileAtLocation: url!)
        
        let textureDesc = MTLTextureDescriptor.init()
        textureDesc.width = (image?.width)!
        textureDesc.height = (image?.height)!
        textureDesc.pixelFormat = .bgra8Unorm
        textureDesc.usage = .shaderRead
        textureDesc.textureType = .type2D
        
        self._inputTexture = self._mtkView.device?.makeTexture(descriptor: textureDesc)
        
        let region = MTLRegionMake2D(0, 0, textureDesc.width, textureDesc.height)
        image?.data.withUnsafeBytes {
            ( bytes:UnsafePointer<UInt8> ) in
            let rawPtr = UnsafeRawPointer(bytes)
            self._inputTexture.replace(region: region, mipmapLevel: 0, withBytes: rawPtr, bytesPerRow: 4 * textureDesc.width)
        }
    }
    
    private func setupVertex() {
        
        let qVertices = [Vertex(position: vector_float4([-1.0, -1.0, 0.0, 1.0]), texCoord: vector_float2([0.0, 0.0])),
                         Vertex(position: vector_float4([ -1.0, 1.0, 0.0, 1.0]), texCoord: vector_float2([0.0, 1.0])),
                         Vertex(position: vector_float4([1.0,  -1.0, 0.0, 1.0]), texCoord: vector_float2([1.0, 0.0])),
                         Vertex(position: vector_float4([1.0, 1.0, 0.0, 1.0]), texCoord: vector_float2([1.0, 1.0])),
                         ]
        self._vertice = self._mtkView.device?.makeBuffer(bytes: qVertices, length: qVertices.count * MemoryLayout<Vertex>.size , options: .storageModeShared)
        
        self._numVertice = qVertices.count
    }
    
    func draw(commandBuffer:MTLCommandBuffer, texture: MTLTexture, desDrawble:CAMetalDrawable) {
        let renderPassDesc = self._mtkView.currentRenderPassDescriptor
        if renderPassDesc != nil {
            renderPassDesc?.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0)
            renderPassDesc?.colorAttachments[0].loadAction = .clear
            
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc!)
            renderEncoder?.setViewport(MTLViewport.init(originX: 0.0, originY: 0.0, width: Double(self._portViewSize!.width), height: Double(self._portViewSize!.height), znear: -1.0, zfar: 1.0))
            renderEncoder?.setRenderPipelineState(self._pipelineState)
            
            renderEncoder?.setFragmentTexture(texture, index: 0)
            renderEncoder?.setVertexBuffer(self._vertice, offset: 0, index: 0)
            renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: self._numVertice)
            
            renderEncoder?.endEncoding()
            
            commandBuffer.present(desDrawble)
        }
    }
    
    // MARK : render method
    func render() -> Void {
        let commandBuffer = self._commandQueue?.makeCommandBuffer()
        draw(commandBuffer: commandBuffer!, texture: self._inputTexture, desDrawble: self._mtkView.currentDrawable!)
        commandBuffer!.commit()
    }
}
