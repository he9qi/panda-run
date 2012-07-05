//
//  Coin.h
//  panda-run
//
//  Created by Qi He on 12-6-29.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@class Game;

@interface Coin : CCNode{
	CCSprite *_sprite;      //texture image for coin
	Game *_game;
	b2Body *_body;
	float _radius;
}

@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) CCSprite *sprite;

+ (id) coinWithGame:(Game*)game Position:(CGPoint)p;
- (id) initWithGame:(Game*)game Position:(CGPoint)p;
- (void) reset;

@end
