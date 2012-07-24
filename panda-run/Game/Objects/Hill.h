//
//  Hill.h
//  panda-run
//
//  Created by Qi He on 12-7-21.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "cocos2d.h"

@interface Hill : CCNode{
	CCSprite *_sprite;      //texture image for mud
	float _offsetX;         //offset X for display
	float _scale;           //scale for display
	int textureSize;        //texture size
	int screenW;            //screen width
	int screenH;            //screen height
}

@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic) float offsetX;
@property (nonatomic) float scale;

+ (id) hillWithTextureSize:(int)ts;
- (id) initWithTextureSize:(int)ts;

@end
