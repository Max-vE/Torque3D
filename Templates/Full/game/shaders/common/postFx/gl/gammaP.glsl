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

#include "../../gl/hlslCompat.glsl"
#include "../../gl/torque.glsl"
#include "shadergen:/autogenConditioners.h"

uniform sampler2D backBuffer;
uniform sampler2D colorCorrectionTex; // ToDo sampler1D not supported

uniform float OneOverGamma;

varying vec2 uv0;

void main()
{
    vec4 color = texture2D(backBuffer, uv0.xy);

   // Apply the color correction.
   color.r = texture2D( colorCorrectionTex, vec2(color.r, 1.0) ).r;
   color.g = texture2D( colorCorrectionTex, vec2(color.g, 1.0) ).g;
   color.b = texture2D( colorCorrectionTex, vec2(color.b, 1.0) ).b;

   // Apply gamma correction
   color.rgb = pow( abs(color.rgb), vec3(OneOverGamma) );

   gl_FragColor = color;
}