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

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Implementation

@implementation BlurTextureConverter

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initialization & Release

- (id)init
{
    if ((self = [super init]))
    {
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
    
    
    
    return nil;
}

#pragma mark -
#pragma mark Private methods

- (CCGLProgram *)programForVerticalBlur
{
    CCGLProgram *program = [[CCShaderCache sharedShaderCache] programForKey:kGAFBlurredSpriteVerticalBlurShaderProgramCacheKey];
    if (program == nil)
    {
        program = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureColor_vert
                                              fragmentShaderFilename:kBlurredSpriteVerticalBlurShaderFilename];
        
        if (program != nil)
        {
            [program addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
            [program addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
            [program addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
            
            [program link];
            [program updateUniforms];
            
            CHECK_GL_ERROR_DEBUG();
            
            [[CCShaderCache sharedShaderCache] addProgram:program forKey:kGAFBlurredSpriteVerticalBlurShaderProgramCacheKey];
            [program release];
        }
        else
        {
            CCLOGWARN(@"Cannot load program for kGAFBlurredSpriteVerticalBlurShaderProgramCacheKey.");
            [self release];
            return nil;
        }
    }
    
    [program use];
    
    _vertShader_kernelSizeUniformLocation = (GLint)glGetUniformLocation(program->_program, "u_matrixRowSize");
    _vertShader_blurDotSizeUniformLocation = (GLint)glGetUniformLocation(program->_program, "dotSize");
    _vertShader_kernelValuesUniformLocation = (GLint)glGetUniformLocation(program->_program, "u_matrixRowValues");
    
    if (_vertShader_kernelSizeUniformLocation <= 0 ||
        _vertShader_blurDotSizeUniformLocation <= 0 ||
        _vertShader_kernelValuesUniformLocation <= 0)
    {
        CCLOGWARN(@"Cannot get uniforms for kGAFBlurredSpriteVerticalBlurShaderProgramCacheKey");
    }
    
    return program;
}

- (CCGLProgram *)programForHorizontalBlur
{
    CCGLProgram *program = [[CCShaderCache sharedShaderCache] programForKey:kGAFBlurredSpriteHorizontalBlurShaderProgramCacheKey];
    if (program == nil)
    {
        program = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureColor_vert
                                              fragmentShaderFilename:kBlurredSpriteHorizontalBlurShaderFilename];
        
        if (program != nil)
        {
            [program addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
            [program addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
            [program addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
            
            [program link];
            [program updateUniforms];
            
            CHECK_GL_ERROR_DEBUG();
            
            [[CCShaderCache sharedShaderCache] addProgram:program forKey:kGAFBlurredSpriteHorizontalBlurShaderProgramCacheKey];
            [program release];
        }
        else
        {
			CCLOGWARN(@"Cannot load program for kGAFBlurredSpriteHorizontalBlurShaderProgramCacheKey.");
            [self release];
            return nil;
        }
    }
    
    [program use];
    
    _horzShader_kernelSizeUniformLocation = (GLint)glGetUniformLocation(program->_program, "u_matrixRowSize");
    _horzShader_blurDotSizeUniformLocation = (GLint)glGetUniformLocation(program->_program, "dotSize");
    _horzShader_kernelValuesUniformLocation = (GLint)glGetUniformLocation(program->_program, "u_matrixRowValues");
    
    if (_horzShader_kernelSizeUniformLocation <= 0 ||
        _horzShader_blurDotSizeUniformLocation <= 0 ||
        _horzShader_kernelValuesUniformLocation <= 0)
    {
        CCLOGWARN(@"Cannot get uniforms for kGAFBlurredSpriteHorizontalBlurShaderProgramCacheKey");
    }
    
    return program;
}

@end