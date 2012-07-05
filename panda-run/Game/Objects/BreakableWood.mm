//
//  BreakableWood.m
//  panda-run
//
//  Created by Qi He on 12-7-4.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "BreakableWood.h"
#import "Game.h"
#import "Box2D.h"
#import "Constants.h"
#import "Box2DHelper.h"
#import "UserData.h"

@interface BreakableWood()
- (void)createBox2DBody;
@end

@implementation BreakableWood

@synthesize game = _game;
@synthesize sprite = _sprite;

+ (id) breakableWoodWithGame:(Game*)game Position:(CGPoint)p{
	return [[[self alloc] initWithGame:game Position:p] autorelease];
}

- (id)initWithGame:(Game *)game Position:(CGPoint)p{
  if ((self = [super init])) {
    
		self.game = game;
    self.position = p;
    
    _width  = 0.5f;
    _height = 0.15f;
    _density = 1.0f;
		
#ifndef DRAW_BOX2D_WORLD
		self.sprite = [CCSprite spriteWithFile:IMAGE_COIN];
		[self addChild:_sprite];
#endif
		_body1 = NULL;
    
		[self reset];
	}
	return self;
}

- (void) dealloc {
  
	self.game = nil;
	
#ifndef DRAW_BOX2D_WORLD
	self.sprite = nil;
#endif
  
	[super dealloc];
}

- (void) reset {
	if (_body1) {
		_game.world->DestroyBody(_body1);
	}
  
  if (_body2) {
		_game.world->DestroyBody(_body2);
	}
  
	[self createBox2DBody];
  
  _break = false;
  _broke = false;
}

- (void)createBox2DBody{
  b2BodyDef bd;
  bd.type = b2_dynamicBody;
  
  // start position
	CGPoint p = self.position;
  
  bd.position.Set(p.x * [Box2DHelper metersPerPoint], p.y * [Box2DHelper metersPerPoint]);
  bd.angle = 0.225f * b2_pi;
  _body1 = _game.world->CreateBody(&bd);
  
  _shape1.SetAsBox(_width, _height, b2Vec2(-_width, 0.0f), 0.0f);
  _piece1 = _body1->CreateFixture(&_shape1, _density);
  
  _shape2.SetAsBox(_width, _height, b2Vec2(_width, 0.0f), 0.0f);
  _piece2 = _body1->CreateFixture(&_shape2, _density);
  
  UserData *data = [[UserData alloc]initWithName:@"BreakableWood" Delegate:self];
  _body1->SetUserData(data);
}

- (void)breakMe{
  // Create two bodies from one.
  b2Body* body1 = _piece1->GetBody();
  b2Vec2 center = body1->GetWorldCenter();
  
  body1->DestroyFixture(_piece2);
  _piece2 = NULL;
  
  b2BodyDef bd;
  bd.type = b2_dynamicBody;
  bd.position = body1->GetPosition();
  bd.angle = body1->GetAngle();
  
  _body2 = _game.world->CreateBody(&bd);
  b2Body* body2 = _body2;
  
  _piece2 = body2->CreateFixture(&_shape2, 1.0f);
  
  // Compute consistent velocities for new bodies based on
  // cached velocity.
  b2Vec2 center1 = body1->GetWorldCenter();
  b2Vec2 center2 = body2->GetWorldCenter();
  
  b2Vec2 velocity1 = _velocity + b2Cross(_angularVelocity, center1 - center);
  b2Vec2 velocity2 = _velocity + b2Cross(_angularVelocity, center2 - center);
  
  body1->SetAngularVelocity(_angularVelocity);
  body1->SetLinearVelocity(velocity1);
  
  body2->SetAngularVelocity(_angularVelocity);
  body2->SetLinearVelocity(velocity2);
}

- (void) postSolve:(b2Contact*)contact:(const b2ContactImpulse*)impulse
{
  if (_broke)
  {
    // The body already broke.
    return;
  }
  
  // Should the body break?
  int32 count = contact->GetManifold()->pointCount;
  
  float32 maxImpulse = 0.0f;
  for (int32 i = 0; i < count; ++i)
  {
    maxImpulse = b2Max(maxImpulse, impulse->normalImpulses[i]);
  }
  
  if (maxImpulse > kMaxBreakImpulseAllow)
  {
    // Flag the body for breaking.
    _break = true;
  }
}

- (void)step
{
  if (_break)
  {
    [self breakMe];
    _broke = true;
    _break = false;
  }
  
  // Cache velocities to improve movement on breakage.
  if (_broke == false)
  {
    _velocity = _body1->GetLinearVelocity();
    _angularVelocity = _body1->GetAngularVelocity();
  }
}

@end
