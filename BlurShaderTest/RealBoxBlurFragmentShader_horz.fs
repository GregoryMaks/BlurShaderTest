////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Real Box blur
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

precision highp float;

uniform sampler2D inputImageTexture;

varying vec2 centerTextureCoordinate;
varying float offset;

//uniform int samplesCount;

float i;
int counter;

void main()
{
    /*vec4 fragmentColor = vec4(0, 0, 0, 0);
    float samplesCoeff = 1.0 / float(samplesCount);
    
    for (i = centerTextureCoordinate.x - offset * float((samplesCount - 1) / 2);
         i <= centerTextureCoordinate.x + offset * float((samplesCount - 1) / 2);
         i += offset)
    {
        vec2 coord = vec2(i, centerTextureCoordinate.y);
        fragmentColor += texture2D(inputImageTexture, coord) * samplesCoeff;
    }*/
    
    vec4fragmentColor += texture2D(inputImageTexture, coord) * 0.111;
    fragmentColor += texture2D(inputImageTexture, coord) * 0.111;
    fragmentColor += texture2D(inputImageTexture, coord) * 0.111;
    fragmentColor += texture2D(inputImageTexture, coord) * 0.111;
    fragmentColor += texture2D(inputImageTexture, coord) * 0.111;
    fragmentColor += texture2D(inputImageTexture, coord) * 0.111;
    fragmentColor += texture2D(inputImageTexture, coord) * 0.111;
    fragmentColor += texture2D(inputImageTexture, coord) * 0.111;
    fragmentColor += texture2D(inputImageTexture, coord) * 0.111;
    
    gl_FragColor = fragmentColor;
}