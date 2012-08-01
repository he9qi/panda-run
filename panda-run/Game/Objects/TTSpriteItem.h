//
//  TTSpriteItem.h
//  panda-run
//
//  Created by Qi He on 12-7-30.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "cocos2d.h"

@interface TTSpriteItem : CCSprite
{
	CGPoint _velocity;
  float   _rotationChange;
  float   _rotationRandomFactor;
  int     _timeCount;
  float   _screenWidth;
  float   _screenHeight;
}

@property (readwrite, nonatomic) CGPoint velocity;

+ (TTSpriteItem *) createSpriteItemWithName:(NSString *)name;

- (void) start;
- (bool) isOutsideScreen;

@end
