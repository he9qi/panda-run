//
//  Panda.m
//  panda-run
//
//  Created by Qi He on 12-6-28.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Panda.h"
#import "Game.h"
#import "PandaContactListener.h"
#import "Box2D.h"
#import "Constants.h"
#import "Box2DHelper.h"
#import "UserData.h"

@interface Panda()
- (void) createBox2DBody;
@end

@implementation Panda

@synthesize game = _game;
@synthesize sprite = _sprite;
@synthesize awake = _awake;
@synthesize diving = _diving;
@synthesize energy = _energy;

+ (id) heroWithGame:(Game*)game {
	return [[[self alloc] initWithGame:game] autorelease];
}

- (id) initWithGame:(Game*)game {
	
	if ((self = [super init])) {
    
		self.game = game;
		
#ifndef DRAW_BOX2D_WORLD
    
    // create sprite sheet
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
		CCSpriteBatchNode *batch = [[CCSpriteBatchNode alloc] initWithFile:@"sprites.png" capacity:50];
		[self addChild:batch];
    
    // create the sprite
		_sprite = [CCSprite spriteWithSpriteFrameName:@"panda_walk_1.png"];
		[self addChild:_sprite];
  
    // make it walk
    _walkAction = [self initWalkAction];
		[_sprite runAction: [CCRepeatForever actionWithAction:_walkAction] ];
    
#endif
		_body = NULL;
		_radius = RADIUS_PANDA;
    
		_contactListener = new PandaContactListener(self);
		_game.world->SetContactListener(_contactListener);
    
		[self reset];
	}
	return self;
}

- (void) dealloc {
  
	self.game = nil;
	
#ifndef DRAW_BOX2D_WORLD
	self.sprite = nil;
#endif
  
	delete _contactListener;
	[super dealloc];
}

- (void) reset {
	_flying = NO;
	_diving = NO;
	_nPerfectSlides = 0;
	if (_body) {
		_game.world->DestroyBody(_body);
	}
	[self createBox2DBody];
	[self updateNode];
	[self sleep];
}

- (void) createBox2DBody {
	
	b2BodyDef bd;
	bd.type = b2_dynamicBody;
	bd.linearDamping = 0.05f;
	bd.fixedRotation = true;
	
	// start position
	CGPoint p = ccp(0, _game.screenH/2+_radius);
	CCLOG(@"start position = %f, %f", p.x, p.y);
  
	bd.position.Set(p.x * [Box2DHelper metersPerPoint], p.y * [Box2DHelper metersPerPoint]);
	_body = _game.world->CreateBody(&bd);
	
	b2CircleShape shape;
	shape.m_radius = _radius * [Box2DHelper metersPerPoint];
	
	b2FixtureDef fd;
	fd.shape = &shape;
	fd.density = 1.0f;
	fd.restitution = 0; // bounce
	fd.friction = 0;
	
  UserData *data = [[UserData alloc]initWithName:@"Panda"];
  _body->SetUserData(data);
	_body->CreateFixture(&fd);
}

- (void) sleep {
	_awake = NO;
	_body->SetActive(false);
}

- (void) wake {
	_awake = YES;
	_body->SetActive(true);
	_body->ApplyLinearImpulse(b2Vec2(1,2), _body->GetPosition());
}

// build walk action
- (CCAnimate *) initWalkAction {
  // create the animation
  NSMutableArray *animFrames = [NSMutableArray array];
  CCSpriteFrame *frame1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"panda_walk_1.png"];
  CCSpriteFrame *frame2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"panda_walk_2.png"];
  CCSpriteFrame *frame3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"panda_walk_3.png"];
  [animFrames addObject:frame1];
  [animFrames addObject:frame2];
  [animFrames addObject:frame3];
  [animFrames addObject:frame2];
  
  CCAnimation *animation = [CCAnimation animationWithFrames:animFrames delay:0.2f];
  
  // create the action
  return [CCAnimate actionWithAnimation:animation];
}

// check the state and apply force accordingly. This is called
// before _world->Step, so that our solver knows this force.
- (void) updatePhysics {
  
	// apply force if diving
	if (_diving) {
		if (!_awake) {
			[self wake];
			_diving = NO;
		} else {
			_body->ApplyForce(b2Vec2(0,-40),_body->GetPosition());
		}
	}
	
	// limit velocity
	const float minVelocityX = 3;
	const float minVelocityY = -40;
	b2Vec2 vel = _body->GetLinearVelocity();
	if (vel.x < minVelocityX) {
		vel.x = minVelocityX;
	}
	if (vel.y < minVelocityY) {
		vel.y = minVelocityY;
	}
	_body->SetLinearVelocity(vel);
}

// update panda's position and rotation and check if there's collision
// and act accordingly.
- (void) updateNode {
	
	CGPoint p;
	p.x = _body->GetPosition().x * [Box2DHelper pointsPerMeter];
	p.y = _body->GetPosition().y * [Box2DHelper pointsPerMeter];
	
	// CCNode position and rotation
	self.position = p;
	b2Vec2 vel = _body->GetLinearVelocity();
	float angle = atan2f(vel.y, vel.x);
  
#ifdef DRAW_BOX2D_WORLD
	_body->SetTransform(_body->GetPosition(), angle);
#else
	self.rotation = -1 * CC_RADIANS_TO_DEGREES(angle);
#endif
  
  // there might be more than 1 contact, so need to 
  // traverse through to contact list
//  for (b2Contact* c = _game.world->GetContactList(); c; c = c->GetNext())
//  {
//    // process c
//    b2Fixture *a = c->GetFixtureA();
//    b2Body* bodyA = a->GetBody();
//    UserData *sa = (UserData*) bodyA->GetUserData();
//    
//    
//    b2Fixture *b = c->GetFixtureB();
//    b2Body* bodyB = b->GetBody();
//    UserData *sb = (UserData*) bodyB->GetUserData();  
//    
//    if (![sa.name isEqualToString:@"Terrain"] && sa.name != NULL) {
//      CCLOG(@"sa => %@ | sb => %@", sa.name, sb.name);
//    }
//  }
  
  // collision detection
	b2Contact *c = _game.world->GetContactList();
  
  if(c){
    b2Fixture *a = c->GetFixtureA();
    b2Body* bodyA = a->GetBody();
    UserData *sa = (UserData*) bodyA->GetUserData();
    
    
    b2Fixture *b = c->GetFixtureB();
    b2Body* bodyB = b->GetBody();
    UserData *sb = (UserData*) bodyB->GetUserData();    
    
    if (sa != nil && sb != nil) {
      if([sa.name isEqualToString:@"Coin"] && [sb.name isEqualToString:@"Panda"]) {
        _game.world->DestroyBody(bodyA);
        id<ContactDelegate> cd = (id<ContactDelegate>)sa.ccObj;
        [cd hideSprite];
      }
      else{
        if (![sa.name isEqualToString:@"Terrain"]) {
//          CCLOG(@"sa => %@ | sb => %@", sa.name, sb.name);
        }
      }
      
      if([sa.name isEqualToString:@"Panda"] || [sb.name isEqualToString:@"Panda"]){
        if (_flying) {
          [self landed];
        }
      }
    }
    
  }else {
		if (!_flying) {
			[self tookOff];
		}
	}
	
	// TEMP: sleep if below the screen
	if (p.y < -_radius && _awake) {
		[self sleep];
	}
}

- (void) landed {
  //	CCLOG(@"landed");
	_flying = NO;
}

- (void) tookOff {
  //	CCLOG(@"tookOff");
	_flying = YES;
  
  // TODO: change sprite image
  
	b2Vec2 vel = _body->GetLinearVelocity();
  //	CCLOG(@"vel.y = %f",vel.y);
	if (vel.y > kPerfectTakeOffVelocityY) {
    //		CCLOG(@"perfect slide");
		_nPerfectSlides++;
		if (_nPerfectSlides > 1) {
			if (_nPerfectSlides == 4) {
//				[_game showFrenzy];
			} else {
//				[_game showPerfectSlide];
			}
		}
	}
}

- (void) hit {
  //	CCLOG(@"hit");
	_nPerfectSlides = 0;
//	[_game showHit];
}

- (void) setDiving:(BOOL)diving {
	if (_diving != diving) {
		_diving = diving;
		// TODO: change sprite image here
	}
}



@end
