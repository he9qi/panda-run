//
//  TTImageItem.h
//  panda-run
//
//  Created by Qi He on 12-7-22.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "cocos2d.h"

@interface TTImageItem : CCNode{
	CCSprite *_sprite;      //texture image for item
}

@property (nonatomic, retain) CCSprite *sprite;

+ (id) itemWithSprite:(CCSprite *)sprite Position:(CGPoint)p;
- (id) initWithSprite:(CCSprite *)sprite Position:(CGPoint)p;

@end