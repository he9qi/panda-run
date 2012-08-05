//
//  TTConsumableItem.h
//  panda-run
//
//  Created by Qi He on 12-7-23.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "ContactDelegate.h"

#define kTTConsumableItemTag 1216
#define kTTConsumableItemZDepth 2

@class Game;
@class Terrain;

@interface TTConsumableItem : CCNode <ContactDelegate>{
	CCSprite *_sprite;      //texture image for item
	Game *_game;
	b2Body *_body;
	float _radius;
  NSString *_name;
}

@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) CCSprite *sprite;

+ (id) itemWithGame:(Game*)game Sprite:(CCSprite *)sprite Radius:(float)radius Position:(CGPoint)p;
- (id) initWithGame:(Game*)game Sprite:(CCSprite *)sprite Radius:(float)radius Position:(CGPoint)p;

+ (TTConsumableItem *)createItemTo:(Game *)game On:(Terrain *)terrain At:(int)index;

- (void) createBox2DBody;
- (void) reset;

@end

