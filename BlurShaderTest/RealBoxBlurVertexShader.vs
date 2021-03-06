////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Real Box blur
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

attribute vec4 position;
attribute vec2 inputTextureCoordinate;

uniform float texelOffset;

varying vec2 centerTextureCoordinate;
varying float offset;

void main()
{
    gl_Position = CC_MVPMatrix * position;
    
    offset = texelOffset;
    centerTextureCoordinate = inputTextureCoordinate;
}