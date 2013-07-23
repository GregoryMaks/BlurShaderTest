precision highp float;

uniform sampler2D inputImageTexture;

varying vec2 centerTextureCoordinate;
varying float offset;

uniform int samplesCount;

float i;
int counter;

void main()
{
    lowp vec4 fragmentColor = vec4(0, 0, 0, 0);
    lowp float samplesCoeff = 1.0 / float(samplesCount);
    
    for (i = centerTextureCoordinate.y - offset * float((samplesCount - 1) / 2);
         i <= centerTextureCoordinate.y + offset * float((samplesCount - 1) / 2);
         i += offset)
    {
        vec2 coord = vec2(centerTextureCoordinate.x, i);
        fragmentColor += texture2D(inputImageTexture, coord) * samplesCoeff;
    }
    
    gl_FragColor = fragmentColor;
}