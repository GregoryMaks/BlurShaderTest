//
//  IntroLayer.m
//  BlurShaderTest
//
//  Created by Gregory Maksyuk on 7/20/13.
//  Copyright Catalyst Apps 2013. All rights reserved.
//

// Import the interfaces
#import "IntroLayer.h"
#import "BlurTextureConverter.h"

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

        CGImageRef image = [[UIImage imageNamed:@"Default.png"] CGImage];
        CCTexture2D *tex = [[CCTexture2D alloc] initWithCGImage:image resolutionType:kCCResolutioniPad];
        
        CCSprite *sprite1 = [CCSprite spriteWithTexture:tex];
        sprite1.position = ccp(160, 768/2);
        [self addChild:sprite1];
        
        BlurTextureConverter *converter = [BlurTextureConverter sharedConverter];
        for (int a = 0; a < 1; a ++)
        {
            CCRenderTexture *resultTex = [converter convertTexture:tex
                                                              rect:CGRectMake(0, 0, tex.contentSize.width, tex.contentSize.height)
                                                        blurRadius:1];
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
