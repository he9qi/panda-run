//
//  Sky.h
//  panda-run
//
//  Created by Qi He on 12-6-26.
//  Copyright (c) 2012年 heyook. All rights reserved.
//

#import "cocos2d.h"

@interface Sky : CCNode{
	CCSprite *_sprite;      //texture image for sky
	float _offsetX;         //offset X for display
	float _scale;           //scale for display
	int textureSize;        //texture size
	int screenW;            //screen width
	int screenH;            //screen height
}

@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic) float offsetX;
@property (nonatomic) float scale;

+ (id) skyWithTextureSize:(int)ts;
- (id) initWithTextureSize:(int)ts;


@end
