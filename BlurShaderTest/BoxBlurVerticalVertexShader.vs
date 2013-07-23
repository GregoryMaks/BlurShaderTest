////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Box blur
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

attribute vec4 position;
attribute vec2 inputTextureCoordinate;

uniform float texelWidthOffset;
uniform float texelHeightOffset;

varying vec2 centerTextureCoordinate;
varying vec2 oneStepLeftTextureCoordinate;
varying vec2 twoStepsLeftTextureCoordinate;
varying vec2 oneStepRightTextureCoordinate;
varying vec2 twoStepsRightTextureCoordinate;

void main()
{
    gl_Position = CC_MVPMatrix * position;
    
    vec2 firstOffset = vec2(0, 1.5 * texelHeightOffset);
    vec2 secondOffset = vec2(0, 3.5 * texelHeightOffset);
    
    centerTextureCoordinate = inputTextureCoordinate;
    oneStepLeftTextureCoordinate = inputTextureCoordinate - firstOffset;
    twoStepsLeftTextureCoordinate = inputTextureCoordinate - secondOffset;
    oneStepRightTextureCoordinate = inputTextureCoordinate + firstOffset;
    twoStepsRightTextureCoordinate = inputTextureCoordinate + secondOffset;
}