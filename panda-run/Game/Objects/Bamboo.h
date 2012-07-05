//
//  Bamboo.h
//  panda-run
//
//  Created by Qi He on 12-7-2.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@class Game;

@interface Bamboo : CCNode{
	CCSprite *_sprite;      //texture image for bamboo
	Game *_game;
	b2Body *_body;
	float _radius;
}

@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) CCSprite *sprite;

+ (id) bambooWithGame:(Game*)game Position:(CGPoint)p;
- (id) initWithGame:(Game*)game Position:(CGPoint)p;
- (void) reset;


@end
