////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFTextureEffectsConverter.h
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Imports

#import "cocos2d.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Predeclarations

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Constants

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interface

@interface GAFTextureEffectsConverter : NSObject

+ (GAFTextureEffectsConverter *)sharedConverter;

- (CCRenderTexture *)gaussianBlurredTextureFromTexture:(CCTexture2D *)aTexture
                                                  rect:(CGRect)rect
                                           blurRadiusX:(CGFloat)aBlurRadiusX
                                           blurRadiusY:(CGFloat)aBlurRadiusY;

- (CCRenderTexture *)boxBlurredTextureFromTexture:(CCTexture2D *)aTexture
                                             rect:(CGRect)rect
                                      blurRadiusX:(CGFloat)aBlurRadiusX
                                      blurRadiusY:(CGFloat)aBlurRadiusY;

- (CCRenderTexture *)box2BlurredTextureFromTexture:(CCTexture2D *)aTexture
                                              rect:(CGRect)rect
                                       blurRadiusX:(CGFloat)aBlurRadiusX
                                       blurRadiusY:(CGFloat)aBlurRadiusY;

@end
