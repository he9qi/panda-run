//
//  Bridge.m
//  panda-run
//
//  Created by Qi He on 12-7-5.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Bridge.h"
#import "Game.h"
#import "Box2D.h"
#import "Constants.h"
#import "Box2DHelper.h"
#import "UserData.h"

@interface Bridge()
- (void)createBox2DBody;
@end

@implementation Bridge

@synthesize game = _game;
@synthesize sprite = _sprite;

+ (id) bridgeWithGame:(Game*)game Position:(CGPoint)p{
	return [[[self alloc] initWithGame:game Position:p] autorelease];
}

- (id) initWithGame:(Game*)game Position:(CGPoint)p{
	
	if ((self = [super init])) {
    
		self.game = game;
    self.position = p;
		
#ifndef DRAW_BOX2D_WORLD
		self.sprite = [CCSprite spriteWithFile:IMAGE_COIN];
		[self addChild:_sprite];
#endif
    
		[self reset];
	}
	return self;
}

- (void) dealloc {
  
	self.game = nil;
  
  //loop through bodies and release 
  for (int32 i = 0; i < kMaxBridgeStep; ++i){
    if (_bodies[i]) {
      _bodies[i] = nil;
    }
    if (_joints[i]) {
      _joints[i] = nil;
    }
  }
  _joints[kMaxBridgeStep] = nil;
	
#ifndef DRAW_BOX2D_WORLD
	self.sprite = nil;
#endif
  
	[super dealloc];
}

- (void) reset {
  
  for (int32 i = 0; i < kMaxBridgeStep; ++i){
    if (  _bodies[i] ) {
      _game.world->DestroyBody(  _bodies[i] );
      _bodies[i] = nil;
    }
    if ( _joints[i] ) {
      _game.world->DestroyJoint( _joints[i] );
      _joints[i] = nil;
    }
  }
  
  if ( _joints[kMaxBridgeStep] ) {
    _game.world->DestroyJoint( _joints[kMaxBridgeStep] );
    _joints[kMaxBridgeStep] = nil;
  }
	
	[self createBox2DBody];
}

- (void)createBox2DBody {
  
  b2Body* ground = NULL;
  
  b2BodyDef bd;
  ground = _game.world->CreateBody(&bd);
  
  b2EdgeShape shape1;
  shape1.Set(b2Vec2(-40.0f, 0.0f), b2Vec2(40.0f, 0.0f));
  ground->CreateFixture(&shape1, 0.0f);
  
  //bridge steps
  
  b2PolygonShape shape;
  shape.SetAsBox(0.5f, 0.125f);
  
  b2FixtureDef fd;
  fd.shape = &shape;
  fd.density = 20.0f;
  fd.friction = 0.2f;
  
  b2RevoluteJointDef jd;
  
  // start position
	CGPoint p = self.position;  
  b2Body* prevBody = ground;
  for (int32 i = 0; i < kMaxBridgeStep; ++i)
  {
    b2BodyDef bd;
    bd.type = b2_dynamicBody;
    bd.position.Set(p.x * [Box2DHelper metersPerPoint] + 1.0f * i, p.y * [Box2DHelper metersPerPoint]);
    b2Body* body = _game.world->CreateBody(&bd);
    
    UserData *data = [[UserData alloc]initWithName:@"Bridge"];
    body->SetUserData(data);
    body->CreateFixture(&fd);
    
    b2Vec2 anchor(p.x * [Box2DHelper metersPerPoint] - 0.5f + 1.0f * i, p.y * [Box2DHelper metersPerPoint]);
    jd.Initialize(prevBody, body, anchor);
    _joints[i] = _game.world->CreateJoint(&jd);
    
    if (i == (kMaxBridgeStep >> 1))
    {
      _middle = body;
    }
    prevBody = body;
    
    _bodies[i] = body;
  }
  
  b2Vec2 anchor(-15.0f + 1.0f * kMaxBridgeStep, 5.0f);
  jd.Initialize(prevBody, ground, anchor);
  _joints[kMaxBridgeStep] = _game.world->CreateJoint(&jd);
  
}


@end
