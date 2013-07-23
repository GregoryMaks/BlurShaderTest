precision highp float;

uniform sampler2D inputImageTexture;

varying vec2 centerTextureCoordinate;
varying vec2 oneStepLeftTextureCoordinate;
varying vec2 twoStepsLeftTextureCoordinate;
varying vec2 oneStepRightTextureCoordinate;
varying vec2 twoStepsRightTextureCoordinate;

void main()
{
    lowp vec4 fragmentColor = texture2D(inputImageTexture, centerTextureCoordinate) * 0.2;
    fragmentColor += texture2D(inputImageTexture, oneStepLeftTextureCoordinate) * 0.2;
    fragmentColor += texture2D(inputImageTexture, oneStepRightTextureCoordinate) * 0.2;
    fragmentColor += texture2D(inputImageTexture, twoStepsLeftTextureCoordinate) * 0.2;
    fragmentColor += texture2D(inputImageTexture, twoStepsRightTextureCoordinate) * 0.2;
    
    gl_FragColor = fragmentColor;
}