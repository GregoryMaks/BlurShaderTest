//
//  IntroLayer.m
//  BlurShaderTest
//
//  Created by Gregory Maksyuk on 7/20/13.
//  Copyright Catalyst Apps 2013. All rights reserved.
//

// Import the interfaces
#import "IntroLayer.h"
#import "GAFTextureEffectsConverter.h"

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init
{
	if((self = [super init]))
    {
		// ask director for the window size
		//CGSize size = [[CCDirector sharedDirector] winSize];

        CCLayerColor *colorLayer = [[CCLayerColor alloc] initWithColor:ccc4(128, 128, 128, 255)];
        [self addChild:colorLayer];
        
        //CGImageRef image = [[UIImage imageNamed:@"Test.png"] CGImage];
        CGImageRef image = [[UIImage imageNamed:@"Default.png"] CGImage];
        CCTexture2D *tex = [[CCTexture2D alloc] initWithCGImage:image resolutionType:kCCResolutioniPad];
        
        CCSprite *sprite1 = [CCSprite spriteWithTexture:tex];
        sprite1.position = ccp(160, 768/2);
        [self addChild:sprite1];
        
        GAFTextureEffectsConverter *converter = [GAFTextureEffectsConverter sharedConverter];
        for (int a = 0; a < 10; a ++)
        {
            CCRenderTexture *resultTex = [converter box2BlurredTextureFromTexture:tex
                                                                            rect:CGRectMake(0, 0, tex.contentSize.width, tex.contentSize.height)
                                                                     blurRadiusX:2
                                                                     blurRadiusY:2];
            if (resultTex != nil)
            {
                CCSprite *sprite2 = [CCSprite spriteWithTexture:resultTex.sprite.texture];
                sprite2.position = ccp(560, 768/2);
                [self addChild:sprite2];
            }
        }
	}
	
	return self;
}

@end
