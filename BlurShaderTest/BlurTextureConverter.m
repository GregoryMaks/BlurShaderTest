////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  BlurTextureConverter.m
//  BlurShaderTest
//
//  Created by Gregory Maksyuk on 7/20/13.
//  Copyright 2013 Catalyst Apps. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Imports

#import "BlurTextureConverter.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Constants

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Private interface

@interface BlurTextureConverter ()

@property (nonatomic, retain) CCTexture2D *initialTexture;
@property (nonatomic, assign) CGRect rect;

@property (nonatomic, retain) NSMutableDictionary *vertexShaderUniforms;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Implementation

@implementation BlurTextureConverter

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initialization & Release

+ (BlurTextureConverter *)sharedConverter
{
    static dispatch_once_t once;
    static BlurTextureConverter *instance = nil;
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
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (CCRenderTexture *)convertTexture:(CCTexture2D *)aTexture rect:(CGRect)rect blurRadius:(CGFloat)aBlurRadius;
{
    CCRenderTexture *rTexture1 = [CCRenderTexture renderTextureWithWidth:rect.size.width height:rect.size.height];
    CCRenderTexture *rTexture2 = [CCRenderTexture renderTextureWithWidth:rect.size.width height:rect.size.height];
    
    NSTimeInterval time = 0;
    CAPTURE_TIME(time);
    
    // Loading shader
    CCGLProgram *gaussianShader_vert = [self programForGaussianBlurShader_vertical];
    CCGLProgram *gaussianShader_horz = [self programForGaussianBlurShader_horizontal];
    /*if (gaussianShader_vert == nil || gaussianShader_horz == nil)
    {
        return nil;
    }*/
    GLint texelWidthOffset_vert = [self.vertexShaderUniforms[@"texelWidthOffset_vert"] integerValue];
    GLint texelHeightOffset_vert = [self.vertexShaderUniforms[@"texelHeightOffset_vert"] integerValue];
    
    GLint texelWidthOffset_horz = [self.vertexShaderUniforms[@"texelWidthOffset_horz"] integerValue];
    GLint texelHeightOffset_horz = [self.vertexShaderUniforms[@"texelHeightOffset_horz"] integerValue];
    
    GLfloat texelWidthValue = aBlurRadius / rect.size.width;
    GLfloat texelHeightValue = aBlurRadius / rect.size.height;
    
    CHECK_GL_ERROR_DEBUG();
    
    SHOW_PASSED_TIME(time, @"load shaders");
    CAPTURE_TIME(time);
    
    {
        // Render texture to rTexture1
        CCSprite *sprite = [CCSprite spriteWithTexture:aTexture rect:rect];
        sprite.position = CGPointMake(sprite.contentSize.width / 2,
                                      sprite.contentSize.height / 2);
        
        sprite.shaderProgram = gaussianShader_vert;
        
        [gaussianShader_vert use];
        glUniform1f(texelWidthOffset_vert, texelWidthValue);
        glUniform1f(texelHeightOffset_vert, texelHeightValue);
        
        [sprite setBlendFunc:(ccBlendFunc){ GL_ONE, GL_ZERO }];
        
        [rTexture1 beginWithClear:1.0 g:1.0 b:1.0 a:1.0];
        
        /*glClearColor(1, 0, 0, 1);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glColorMask(TRUE, TRUE, TRUE, FALSE);*/
        [sprite visit];
        
        [rTexture1 end];
    }
    
    CHECK_GL_ERROR_DEBUG();
    
    SHOW_PASSED_TIME(time, @"texture -> rTexture1");
    CAPTURE_TIME(time);
    
    {
        // Render rTexture1 to rTexture2
        rTexture1.sprite.position = CGPointMake(rTexture1.sprite.contentSize.width / 2,
                                                rTexture1.sprite.contentSize.height / 2);
        
        rTexture1.sprite.shaderProgram = gaussianShader_horz;
        
        [gaussianShader_horz use];
        glUniform1f(texelWidthOffset_horz, texelWidthValue);
        glUniform1f(texelHeightOffset_horz, texelHeightValue);
        
        [rTexture1.sprite setBlendFunc:(ccBlendFunc){ GL_ONE, GL_ZERO }];
        
        [rTexture2 begin];
        
        [rTexture1.sprite visit];
        
        [rTexture2 end];
    }
    
    CHECK_GL_ERROR_DEBUG();
    
    SHOW_PASSED_TIME(time, @"rTexture1 -> rTexture2");
    CAPTURE_TIME(time);

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