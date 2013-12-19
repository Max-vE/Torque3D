//-----------------------------------------------------------------------------
// Copyright (c) 2012 GarageGames, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//-----------------------------------------------------------------------------

#include "../../../gl/hlslCompat.glsl"
#include "shadergen:/autogenConditioners.h"

uniform float3    eyePosWorld;
uniform float4    rtParams0;
uniform float4    waterFogPlane;
uniform float     accumTime;

varying vec2 uv0;
varying vec2 uv1;
varying vec2 uv2;
varying vec2 uv3;
varying vec3 wsEyeRay;

#define IN_uv0 uv0
#define IN_uv1 uv1
#define IN_uv2 uv2
#define IN_uv3 uv3
#define IN_wsEyeRay wsEyeRay

uniform sampler2D prepassTex;
uniform sampler2D causticsTex0;
uniform sampler2D causticsTex1;
uniform float2 targetSize;

void main()             
{   
   //Sample the pre-pass
   float2 prepassCoord = ( IN_uv0.xy * rtParams0.zw ) + rtParams0.xy;  
   float4 prePass = prepassUncondition( prepassTex, prepassCoord );
   
   //Get depth
   float depth = prePass.w;   
   clip( 0.9999 - depth );
   
   //Get world position
   float3 pos = eyePosWorld + IN_wsEyeRay * depth;
   
   //Use world position X and Y to calculate caustics UV 
   float2 causticsUV0 = mod(abs(pos.xy * 0.25) , float2(1, 1));
   float2 causticsUV1 = mod(abs(pos.xy * 0.2) , float2(1, 1));
   
   //Animate uvs
   float timeSin = sin(accumTime);
   causticsUV0.xy += float2(accumTime*0.1, timeSin*0.2);
   causticsUV1.xy -= float2(accumTime*0.15, timeSin*0.15);   
   
   //Sample caustics texture   
   float4 caustics = tex2D(causticsTex0, causticsUV0);   
   caustics *= tex2D(causticsTex1, causticsUV1);
   
   //Use normal Z to modulate caustics  
   float waterDepth = 1 - saturate(pos.z + waterFogPlane.w + 1);
   caustics *= saturate(prePass.z) * pow(1-depth, 64) * waterDepth; 
      
   gl_FragColor = caustics;   
}