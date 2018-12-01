//
//  shader.metal
//  MyCode
//
//  Created by larry-kof on 2018/11/26.
//  Copyright © 2018 larry-kof. All rights reserved.
//

#include <metal_stdlib>
#include "ShaderTypes.h"
using namespace metal;

struct RasterizerData{
    float4 position [[position]];
    float2 texCoord;
};

vertex RasterizerData
texVertexShader(uint vid [[vertex_id]],
             constant Vertex* vertexArray [[ buffer(0) ]])
{
    RasterizerData out;
    out.position = vertexArray[vid].position;
    out.texCoord = vertexArray[vid].texCoord;
    
    return out;
}

fragment float4
texFragmentShader(RasterizerData input [[stage_in]],
                  texture2d<float> inputTexture [[ texture(0) ]])
{
    constexpr sampler textureFilter (mag_filter::linear,
                                      min_filter::linear);
    
    float4 colorSample = inputTexture.sample(textureFilter, input.texCoord);
    
    return colorSample;
}

constant float3 kRec709Luma = float3(0.2126, 0.7152, 0.0722);
fragment float4
fboFragmentShader(RasterizerData input [[stage_in]],
                  texture2d<float> inputTexture [[ texture(0) ]])
{
    constexpr sampler textureFilter (mag_filter::linear,
                                     min_filter::linear);
    
    float4 colorSample = inputTexture.sample(textureFilter, input.texCoord);
    
    float gray = dot(colorSample.rgb, kRec709Luma);
    return float4( gray, gray, gray, 1.0 );
}
