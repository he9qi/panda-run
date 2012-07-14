//
//  BreakableWood.h
//  panda-run
//
//  Created by Qi He on 12-7-4.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "ContactDelegate.h"

#define kMaxBreakImpulseAllow 1.0f

@class Game;

@interface BreakableWood : CCNode <ContactDelegate> {
  CCSprite *_sprite;      //texture image for wood
	Game *_game;
  
  b2Body* _body1;
  b2Body* _body2;
	b2Vec2 _velocity;
	float32 _angularVelocity;
	b2PolygonShape _shape1;
	b2PolygonShape _shape2;
	b2Fixture* _piece1;
	b2Fixture* _piece2;
  
  float32 _width;
  float32 _height;
  float32 _density;
  
	bool _broke;
	bool _break;
  
  CCSprite *_sprite1;      //texture image for broken wood
  CCSprite *_sprite2;      //texture image for broken wood
}

@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) CCSprite *sprite;

+ (id) breakableWoodWithGame:(Game*)game Position:(CGPoint)p;
- (id) initWithGame:(Game*)game Position:(CGPoint)p;
- (void) reset;
- (void) breakMe;
- (void) step;

@end
