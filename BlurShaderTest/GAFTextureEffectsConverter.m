////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFTextureEffectsConverter.m
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Imports

#import "GAFTextureEffectsConverter.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Constants

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Private interface

@interface GAFTextureEffectsConverter ()

@property (nonatomic, retain) NSMutableDictionary *vertexShaderUniforms;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Implementation

@implementation GAFTextureEffectsConverter

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initialization & Release

+ (GAFTextureEffectsConverter *)sharedConverter
{
    static dispatch_once_t once;
    static id instance = nil;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.vertexShaderUniforms = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    [_vertexShaderUniforms release];
    [super dealloc];
}

#pragma mark -
#pragma mark Public methodsя

- (CCRenderTexture *)gaussianBlurredTextureFromTexture:(CCTexture2D *)aTexture
                                                  rect:(CGRect)rect
                                           blurRadiusX:(CGFloat)aBlurRadiusX
                                           blurRadiusY:(CGFloat)aBlurRadiusY
{
    const int kGaussianKernelSize = 9;
    
    CGSize rTextureSize = CGSizeMake(rect.size.width + 2 * (kGaussianKernelSize / 2) * aBlurRadiusX,
                                     rect.size.height + 2 * (kGaussianKernelSize / 2) * aBlurRadiusY);
    
    CCRenderTexture *rTexture1 = [CCRenderTexture renderTextureWithWidth:rTextureSize.width height:rTextureSize.height];
    CCRenderTexture *rTexture2 = [CCRenderTexture renderTextureWithWidth:rTextureSize.width height:rTextureSize.height];
    
    //NSTimeInterval time = 0;
    //CAPTURE_TIME(time);
    
    // Loading shader
    CCGLProgram *gaussianShader_vert = [self programForGaussianBlurShader_vertical];
    CCGLProgram *gaussianShader_horz = [self programForGaussianBlurShader_horizontal];
    if (gaussianShader_vert == nil || gaussianShader_horz == nil)
    {
        return nil;
    }
    
    GLint texelWidthOffset_vert = [self.vertexShaderUniforms[@"texelWidthOffset_vert"] integerValue];
    GLint texelHeightOffset_vert = [self.vertexShaderUniforms[@"texelHeightOffset_vert"] integerValue];
    
    GLint texelWidthOffset_horz = [self.vertexShaderUniforms[@"texelWidthOffset_horz"] integerValue];
    GLint texelHeightOffset_horz = [self.vertexShaderUniforms[@"texelHeightOffset_horz"] integerValue];
    
    CHECK_GL_ERROR_DEBUG();
    
    //SHOW_PASSED_TIME(time, @"load shaders");
    //CAPTURE_TIME(time);
    
    {
        // Render texture to rTexture2 without shaders
        CCSprite *sprite = [CCSprite spriteWithTexture:aTexture rect:rect];
        sprite.position = CGPointMake(rTextureSize.width / 2,
                                      rTextureSize.height / 2);
        
        [sprite setBlendFunc:(ccBlendFunc){ GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA }];
        
        [rTexture2 beginWithClear:1.0 g:1.0 b:1.0 a:0.0];
        [sprite visit];
        [rTexture2 end];
    }
    
    CHECK_GL_ERROR_DEBUG();
    
    //SHOW_PASSED_TIME(time, @"texture -> rTexture2");
    //CAPTURE_TIME(time);
    
    {
        // Render rTexture2 to rTexture1
        GLfloat texelWidthValue = aBlurRadiusX / (GLfloat)aTexture.pixelsWide;
        GLfloat texelHeightValue = aBlurRadiusY / (GLfloat)aTexture.pixelsHigh;
        
        rTexture2.sprite.position = CGPointMake(rTextureSize.width / 2,
                                      rTextureSize.height / 2);
        
        rTexture2.sprite.shaderProgram = gaussianShader_vert;
        
        [gaussianShader_vert use];
        glUniform1f(texelWidthOffset_vert, texelWidthValue);
        glUniform1f(texelHeightOffset_vert, texelHeightValue);
        
        [rTexture2.sprite setBlendFunc:(ccBlendFunc){ GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA }];
        
        [rTexture1 beginWithClear:1.0 g:1.0 b:1.0 a:0.0];
        [rTexture2.sprite visit];
        [rTexture1 end];
    }
    
    CHECK_GL_ERROR_DEBUG();
    
    //SHOW_PASSED_TIME(time, @"rTexture2 -> rTexture1");
    //CAPTURE_TIME(time);
    
    {
        // Render rTexture1 to rTexture2
        GLfloat texelWidthValue = aBlurRadiusX / (GLfloat)rTexture1.sprite.texture.pixelsWide;
        GLfloat texelHeightValue = aBlurRadiusY / (GLfloat)rTexture1.sprite.texture.pixelsHigh;
        
        rTexture1.sprite.position = CGPointMake(rTextureSize.width / 2,
                                                rTextureSize.height / 2);
        
        rTexture1.sprite.shaderProgram = gaussianShader_horz;
        
        [gaussianShader_horz use];
        glUniform1f(texelWidthOffset_horz, texelWidthValue);
        glUniform1f(texelHeightOffset_horz, texelHeightValue);
        
        [rTexture1.sprite setBlendFunc:(ccBlendFunc){ GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA }];
        
        [rTexture2 beginWithClear:1.0 g:1.0 b:1.0 a:0.0];
        [rTexture1.sprite visit];
        [rTexture2 end];
    }
    
    CHECK_GL_ERROR_DEBUG();
    
    //SHOW_PASSED_TIME(time, @"rTexture1 -> rTexture2");
    //CAPTURE_TIME(time);
    
    return rTexture2;
}

#pragma mark -
#pragma mark Private methods

- (CCGLProgram *)programForGaussianBlurShader_vertical
{
    static NSString * const kGausianBlurShaderCacheKey = @"GaussianBlurShader_vert";
    
    CCGLProgram *program = [[CCShaderCache sharedShaderCache] programForKey:kGausianBlurShaderCacheKey];
    if (program == nil)
    {
        program = [[[CCGLProgram alloc] initWithVertexShaderFilename:@"GaussianBlurVerticalVertexShader.vs"
                                              fragmentShaderFilename:@"GaussianBlurFragmentShader.fs"] autorelease];
        
        if (program != nil)
        {
            [program addAttribute:@"position" index:kCCVertexAttrib_Position];
            [program addAttribute:@"inputTextureCoordinate" index:kCCVertexAttrib_TexCoords];
            
            [program link];
            [program updateUniforms];
            
            CHECK_GL_ERROR_DEBUG();
            
            [[CCShaderCache sharedShaderCache] addProgram:program forKey:kGausianBlurShaderCacheKey];
        }
        else
        {
            CCLOGWARN(@"Cannot load program for %@.", kGausianBlurShaderCacheKey);
            return nil;
        }
    }
    
    GLint texelWidthOffset = (GLint)glGetUniformLocation(program->_program, "texelWidthOffset");
    GLint texelHeightOffset = (GLint)glGetUniformLocation(program->_program, "texelHeightOffset");
    
    if (texelWidthOffset != -1 && texelHeightOffset != -1)
    {
        self.vertexShaderUniforms[@"texelWidthOffset_vert"] = @(texelWidthOffset);
        self.vertexShaderUniforms[@"texelHeightOffset_vert"] = @(texelHeightOffset);
    }
    else
    {
        CCLOGWARN(@"Cannot get uniforms for %@", kGausianBlurShaderCacheKey);
        return nil;
    }
    
    return program;
}

- (CCGLProgram *)programForGaussianBlurShader_horizontal
{
    static NSString * const kGausianBlurShaderCacheKey = @"GaussianBlurShader_horz";
    
    CCGLProgram *program = [[CCShaderCache sharedShaderCache] programForKey:kGausianBlurShaderCacheKey];
    if (program == nil)
    {
        program = [[[CCGLProgram alloc] initWithVertexShaderFilename:@"GaussianBlurHorizontalVertexShader.vs"
                                              fragmentShaderFilename:@"GaussianBlurFragmentShader.fs"] autorelease];
        
        if (program != nil)
        {
            [program addAttribute:@"position" index:kCCVertexAttrib_Position];
            [program addAttribute:@"inputTextureCoordinate" index:kCCVertexAttrib_TexCoords];
            
            [program link];
            [program updateUniforms];
            
            CHECK_GL_ERROR_DEBUG();
            
            [[CCShaderCache sharedShaderCache] addProgram:program forKey:kGausianBlurShaderCacheKey];
        }
        else
        {
            CCLOGWARN(@"Cannot load program for %@.", kGausianBlurShaderCacheKey);
            return nil;
        }
    }
    
    GLint texelWidthOffset = (GLint)glGetUniformLocation(program->_program, "texelWidthOffset");
    GLint texelHeightOffset = (GLint)glGetUniformLocation(program->_program, "texelHeightOffset");
    
    if (texelWidthOffset != -1 && texelHeightOffset != -1)
    {
        self.vertexShaderUniforms[@"texelWidthOffset_horz"] = @(texelWidthOffset);
        self.vertexShaderUniforms[@"texelHeightOffset_horz"] = @(texelHeightOffset);
    }
    else
    {
        CCLOGWARN(@"Cannot get uniforms for %@", kGausianBlurShaderCacheKey);
        return nil;
    }
    
    return program;
}

@end