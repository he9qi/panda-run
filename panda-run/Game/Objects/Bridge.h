//
//  Bridge.h
//  panda-run
//
//  Created by Qi He on 12-7-5.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

#define kMaxBridgeStep 10

@class Game;

@interface Bridge : CCNode{
	CCSprite *_sprite;      //texture image for bamboo
	Game *_game;
  
  b2Body *_middle;
  b2Body *_bodies[kMaxBridgeStep];
  b2Joint *_joints[kMaxBridgeStep+1];
}

@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) CCSprite *sprite;

+ (id) bridgeWithGame:(Game*)game Position:(CGPoint)p;
- (id) initWithGame:(Game*)game Position:(CGPoint)p;
- (void) reset;


@end
