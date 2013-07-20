////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFBlurredSprite.h
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "cocos2d.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@class CCRenderTexture;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface BlurredSprite : CCSprite
{
@private
    CGSize _originalTextureSize;
    CGSize _blurredTextureSize;
    
    CCRenderTexture *_originalTexture;
    CCRenderTexture *_dynamicTexture1;
    CCRenderTexture *_dynamicTexture2;
    
    // Shader uniforms
    GLint _vertShader_kernelSizeUniformLocation;
    GLint _vertShader_blurDotSizeUniformLocation;
    GLint _vertShader_kernelValuesUniformLocation;
    
    GLint _horzShader_kernelSizeUniformLocation;
    GLint _horzShader_blurDotSizeUniformLocation;
    GLint _horzShader_kernelValuesUniformLocation;
}

@property (nonatomic, assign) CGSize blurSize;

//- (id)initWithTexture:(CCTexture2D *)texture rect:(CGRect)rect rotated:(BOOL)rotated blurSize:(CGSize)aBlurSize;
- (void)updateDynamicTexture;

@end
