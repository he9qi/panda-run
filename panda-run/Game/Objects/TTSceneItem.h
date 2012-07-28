//
//  TTSceneItem.h
//  panda-run
//
//  Created by Qi He on 12-7-22.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "cocos2d.h"

@interface TTSceneItem : CCNode{
	CCSprite *_sprite;      //texture image for scene item
  CCSprite *_innerSprite;
	float _offsetX;         //offset X for display
	float _scale;           //scale for display
	int textureSize;        //texture size
	int screenW;            //screen width
	int screenH;            //screen height
  
  ccColor3B _color;
}

@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic) float offsetX;
@property (nonatomic) float scale;

+ (id) itemWithTexture:(CCSprite *)sprite Size:(int)ts Color:(ccColor3B)color;
- (id) initWithTexture:(CCSprite *)sprite Size:(int)ts Color:(ccColor3B)color;

@end
