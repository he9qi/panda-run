//
//  Water.h
//  panda-run
//
//  Created by Qi He on 12-7-19.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "ContactDelegate.h"

#define kMaxWaterDrop 2

@class Game;

@interface Water : CCNode <ContactDelegate> {
  CCSprite *_sprite;      //texture image for coin
	Game *_game;
  
	float _radius;
  b2Body *_bodies[kMaxWaterDrop];
}

@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) CCSprite *sprite;

+ (id) waterWithGame:(Game*)game Position:(CGPoint)p;
- (id) initWithGame:(Game*)game Position:(CGPoint)p;

- (void) reset;
- (void) step;

@end
