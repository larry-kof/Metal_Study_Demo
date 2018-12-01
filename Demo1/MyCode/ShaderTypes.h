//
//  ShaderTypes.h
//  MyCode
//
//  Created by larry-kof on 2018/11/26.
//  Copyright © 2018 larry-kof. All rights reserved.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

struct Vertex
{
    vector_float4 position;
    vector_float2 texCoord;
};

#endif /* ShaderTypes_h */
