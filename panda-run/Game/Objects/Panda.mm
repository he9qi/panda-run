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

#import "Terrain.h"
#import "Fire.h"

@interface Panda()
- (void) createBox2DBody;
@end

@implementation Panda

@synthesize game   = _game;
@synthesize sprite = _sprite;
@synthesize awake  = _awake;
@synthesize diving = _diving;
@synthesize energy = _energy;
@synthesize state  = _state;

+ (id) heroWithGame:(Game*)game {
	return [[[self alloc] initWithGame:game] autorelease];
}

- (id) initWithGame:(Game*)game {
	
	if ((self = [super init])) {
    
		self.game = game;
		
#ifndef DRAW_BOX2D_WORLD
    
    // create sprite sheet
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
		[[CCSpriteBatchNode alloc] initWithFile:IMAGE_SPRITE capacity:50];
    
    // create the sprite
		_sprite = [CCSprite spriteWithSpriteFrameName:@"panda_walk_2.png"];
		[self addChild:_sprite];

    // make it walk
    _walkForeverAction   = [[CCRepeatForever actionWithAction:[self initWalkAction]] retain];
    _rotateForeverAction = [[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:0.01 angle:20]] retain];
    
#endif
		_body = NULL;
		_radius = RADIUS_PANDA;
    _energized = false;
    _mode = kPandaModeNormal;
    
		_contactListener = new PandaContactListener(self);
		_game.world->SetContactListener(_contactListener);
    
    _fireSystem = [[Fire alloc] init];
    _fireSystem.position = ccp(0, 0);
    
    [self addChild:_fireSystem z:1 tag:GameSceneNodeTagFire]; //add crazy
    
    
    _shadowSprite = [CCSprite spriteWithSpriteFrameName:@"stone.png"];
    _shadowSprite.position = ccp( 0, -_sprite.contentSize.height/2);
    [self addChild:_shadowSprite z:1001 tag:GameSceneNodeTagShadow];
    
		[self reset];
    
	}
	return self;
}

- (void)setState:(PandaState)s {
	if(_state == s) return;
#ifndef DRAW_BOX2D_WORLD
  if(_state == kPandaStateWalk)  { [_sprite stopAction:_walkForeverAction]; }
  if(_state == kPandaStateSlide) { 
    [_sprite stopAction:_rotateForeverAction];
    [_sprite setRotation:0];
  }
  
	_state = s;

	switch(_state) {
		case kPandaStateIdle:
      [_sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"panda_walk_2.png"]];
      break;
		case kPandaStateWalk:
      [_sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"panda_walk_1.png"]];
      [_sprite runAction:_walkForeverAction];
			break;
		case kPandaStateFly:
      [_sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"panda_fly_1.png"]];
			break;
		case kPandaStateSlide:
      [_sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"panda_slide_1.png"]];
      [_sprite runAction:_rotateForeverAction];
			break;
		default:
      [_sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"panda_walk_2.png"]];
			break;
	}
#endif
}

- (void) dealloc {
  
	self.game = nil;
  
  [_walkForeverAction release];
  [_rotateForeverAction release];
  
  _rotateForeverAction = nil;
  _walkForeverAction = nil;
	
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
  [self hideCrazy];
}

- (void) createBox2DBody {
	
	b2BodyDef bd;
	bd.type = b2_dynamicBody;
	bd.linearDamping = 0.05f;
	bd.fixedRotation = true;
	
	// start position
	CGPoint p = ccp(0, _game.screenH/2+_radius);
	CCLOG(@"panda start position = %f, %f", p.x, p.y);
  
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

- (void) energify {
  _energized = TRUE;
}

- (void) sleep {
	_awake = NO;
	_body->SetActive(false);
  self.state = kPandaStateIdle;
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
      _body->ApplyForce(b2Vec2(0,10),_body->GetPosition());
		} else {
			_body->ApplyForce(b2Vec2(0,-40),_body->GetPosition());
		}
	}
  
  // apply force if panda is energized
  if (_energized) {
    
    b2Vec2 vel = _body->GetLinearVelocity();
    
    float y = abs(vel.y)*kEnergyMagifySize;
    float x = vel.x*kEnergyMagifySize/2;
    
    _body->ApplyForce(b2Vec2(x, y),_body->GetPosition());
    _energized = false;
  }
	
	// limit velocity
	const float minVelocityX = 2;
	const float minVelocityY = -40;
	b2Vec2 vel = _body->GetLinearVelocity();
	if (vel.x < minVelocityX) {
		vel.x = minVelocityX;
	}
	if (vel.y < minVelocityY) {
		vel.y = minVelocityY;
	}
	_body->SetLinearVelocity(vel);
//  CCLOG(@"final vel = %f, %f", vel.x, vel.y);
}

- (bool)hasReachedTemple{
	float x = _body->GetPosition().x * [Box2DHelper pointsPerMeter] * CC_CONTENT_SCALE_FACTOR();
  return ([_game.terrain getTempleBorderVertice].x - x) < kPandaReachTempleOffset;
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
  
  if( [self hasReachedTemple] ) {
    [self sleep];
    [self hideCrazy];
    [_game finish];
  }
  
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
      if([sa isA:@"Terrain"] && [sb isA:@"Panda"]){
        if (_flying) {
          [self landed];
        }
      }
    }
    
  }else { //if there's no collision, panda has to be flying
		if (!_flying) {
			[self tookOff];
		}
	}
  
  [self showShadow];
	
	// TEMP: sleep if below the screen
	if (p.y < -_radius && _awake) {
		[self sleep];
	}
}

// panda has landed
- (void) landed {
  //	CCLOG(@"landed");
	_flying = NO;
  self.state = _diving ? kPandaStateSlide : kPandaStateWalk;
}

// panda has taken off
- (void) tookOff {
  //	CCLOG(@"tookOff");
	_flying = YES;
  self.state = kPandaStateFly;
  
	b2Vec2 vel = _body->GetLinearVelocity();
  //	CCLOG(@"vel.y = %f",vel.y);
	if (vel.y > kPerfectTakeOffVelocityY) {
    //		CCLOG(@"perfect slide");
		_nPerfectSlides++;
		if (_nPerfectSlides > 1) {
			if (_nPerfectSlides == kFrenzyLimit) {
        _mode = kPandaModeFrenzy;
				[_game showFrenzy];
        [self showCrazy];
			} else {
				[_game showPerfectSlide];
			}
		}
	}
}

// panda has hit terrain
- (void) hit {
	_nPerfectSlides = 0;
  _mode = kPandaModeNormal;
  
	[_game showHit];
  [self hideCrazy];
}

- (void) setDiving:(BOOL)diving {
	if (_diving != diving) {
		_diving = diving;
    self.state = _diving ? kPandaStateSlide : kPandaStateWalk;
	}
}


// This callback finds non-terrain hit. non-terrain is filtered.
class RayCastTerrainCallback : public b2RayCastCallback
{
public:
	RayCastTerrainCallback()
	{
		m_hit = false;
	}
  
	float32 ReportFixture(	b2Fixture* fixture, const b2Vec2& point,
                        const b2Vec2& normal, float32 fraction)
	{    
    b2Body* body = fixture->GetBody();
		void* userData = body->GetUserData();
		if (userData)
		{
			UserData *ud = (UserData *) userData;
      if( ![ud.name isEqualToString:@"Terrain"]) return -1.0f; //filter out not terrain stuff
		}
    
		m_hit = true;
		m_point = point;
		m_normal = normal;
		return 0.0f;
	}
  
	bool m_hit;
	b2Vec2 m_point;
	b2Vec2 m_normal;
};


// physics world position:  p
// digital world position:  p * [Box2DHelper pointsPerMeter]
// local position:          p * [Box2DHelper pointsPerMeter] - self.position
- (void) showShadow{
  
  b2Vec2 point1(_body->GetPosition().x, _body->GetPosition().y);
  b2Vec2 point2(_body->GetPosition().x, 1.0f);
  
  RayCastTerrainCallback callback;
  _game.world->RayCast(&callback, point1, point2);
  
  if (callback.m_hit)
  {
    
    b2Vec2 hitPoint = callback.m_point;
    b2Vec2 hitNormal = callback.m_normal;
    hitNormal.Normalize();
    
    b2Vec2 vertical; vertical.x = 0; vertical.y = 1;
    float angle  = b2Cross(hitNormal, vertical);
    float length = (hitPoint - point1).Length();
    
    _shadowSprite.scale = length > 0.6f ? 0.01f : (0.6f-length)*2.5f + 0.45f;    
    _shadowSprite.rotation = angle * ANGLE_TO_DEGREE * 0.1;
    _shadowSprite.position = ccp(hitPoint.x*[Box2DHelper pointsPerMeter] - self.position.x, 
                        hitPoint.y*[Box2DHelper pointsPerMeter] - self.position.y - _shadowSprite.scale*2.0f);

  }
  
}


/************  crazy stuff  ************/

- (void) hideCrazy{
  [_fireSystem stopSystem];
}

- (void) showCrazy{
  [_fireSystem resetSystem];
}

- (bool) isCrazy{
  return _mode == kPandaModeFrenzy;
}


@end
