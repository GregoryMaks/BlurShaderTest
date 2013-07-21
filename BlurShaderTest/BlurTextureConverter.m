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

- (BlurTextureConverter *)sharedConverter
{
    static dispatch_once_t once;
    static BlurTextureConverter *instance = nil;
    _dispatch_once(&once, ^{
        instance = [[BlurTextureConverter alloc] init];
    });
    return instance;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.vertexShaderUniforms = [NSMutableDictionary dictionary];
    }
    return nil;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (CCRenderTexture *)convertTexture:(CCTexture2D *)aTexture rect:(CGRect)rect blurRadius:(CGFloat)aBlurRadius;
{
    CCRenderTexture *rTexture1 = [CCRenderTexture renderTextureWithWidth:self.rect.size.width height:self.rect.size.height];
    CCRenderTexture *rTexture2 = [CCRenderTexture renderTextureWithWidth:self.rect.size.width height:self.rect.size.height];
    
    // Load and cache shaders§
    
    return nil;
}

#pragma mark -
#pragma mark Private methods

- (CCGLProgram *)programForGaussianBlurShader
{
    static NSString * const kGausianBlurShaderCacheKey = @"GaussianBlurShader";
    
    CCGLProgram *program = [[CCShaderCache sharedShaderCache] programForKey:kGausianBlurShaderCacheKey];
    if (program == nil)
    {
        program = [[CCGLProgram alloc] initWithVertexShaderFilename:@"GaussianBlurVertexShader.vs"
                                             fragmentShaderFilename:@"GaussianBlurFragmentShader.fs"];
        
        if (program != nil)
        {
            [program addAttribute:@"position" index:kCCVertexAttrib_Position];
            [program addAttribute:@"inputTextureCoordinate" index:kCCVertexAttrib_TexCoords];
            
            [program link];
            [program updateUniforms];
            
            CHECK_GL_ERROR_DEBUG();
            
            [[CCShaderCache sharedShaderCache] addProgram:program forKey:kGausianBlurShaderCacheKey];
            [program release];
        }
        else
        {
            CCLOGWARN(@"Cannot load program for %@.", kGausianBlurShaderCacheKey);
            return nil;
        }
    }
    
    [program use];
    
    GLint texelWidthOffset = (GLint)glGetUniformLocation(program->_program, "texelWidthOffset");
    GLint texelHeightOffset = (GLint)glGetUniformLocation(program->_program, "texelHeightOffset");
    
    if (texelWidthOffset > 0 && texelHeightOffset > 0)
    {
        self.vertexShaderUniforms[@"texelWidthOffset"] = @(texelWidthOffset);
        self.vertexShaderUniforms[@"texelHeightOffset"] = @(texelHeightOffset);
    }
    else
    {
        CCLOGWARN(@"Cannot get uniforms for %@", kGausianBlurShaderCacheKey);
    }
    
    return program;
}

@end