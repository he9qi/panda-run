//
//  Water.m
//  panda-run
//
//  Created by Qi He on 12-7-19.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Water.h"

#import "Game.h"
#import "Box2DHelper.h"
#import "UserData.h"
#import "Constants.h"
#import "AWTextureFilter.h"


@interface Water()
- (void)createBox2DBody;
@end

@implementation Water 

@synthesize game = _game;
@synthesize sprite = _sprite;

+ (id) waterWithGame:(Game*)game Position:(CGPoint)p{
	return [[[self alloc] initWithGame:game Position:p] autorelease];
}

- (id) initWithGame:(Game*)game Position:(CGPoint)p{
	
	if ((self = [super init])) {
    
		self.game = game;
    self.position = p;
		
    //#ifndef DRAW_BOX2D_WORLD
//		self.sprite = [CCSprite spriteWithFile:IMAGE_COIN];
//    self.sprite.scale = 0.8f;
//		[self addChild:_sprite];
    //#endif
		_radius = RADIUS_WATER * [Box2DHelper metersPerPoint];
    
		[self reset];
	}
	return self;
}

- (void) dealloc {
  
	self.game = nil;
	
  //#ifndef DRAW_BOX2D_WORLD
	self.sprite = nil;
  //#endif
  
  //loop through bodies and release 
  for (int32 i = 0; i < kMaxWaterDrop; ++i){
    if (_bodies[i]) {
      _bodies[i] = nil;
    }
  }
  
	[super dealloc];
}

- (void) reset {
  for (int32 i = 0; i < kMaxWaterDrop; ++i){
    if (  _bodies[i] ) {
      _game.world->DestroyBody(  _bodies[i] );
      _bodies[i] = nil;
    }
  }
	[self createBox2DBody];
}

- (void)createBox2DBody {
  
  CGPoint p = self.position; 
  
  for (int i=0; i<kMaxWaterDrop; i++) {
    b2BodyDef bd;
    bd.type = b2_dynamicBody;
    
    b2CircleShape shape;
    shape.m_radius = _radius;
    
    bd.position.Set(p.x * [Box2DHelper metersPerPoint] + shape.m_radius * i, p.y * [Box2DHelper metersPerPoint]);
    b2Body* body = _game.world->CreateBody(&bd);
    
    b2FixtureDef fd;
    fd.shape = &shape;
    fd.density = 0.1f;
    fd.restitution = 0.5f; // bounce
    fd.friction = 0.25f;
    
//    b2PolygonShape shape;
//    shape.SetAsBox(0.125f, 0.125f);
    
    UserData *data = [[UserData alloc]initWithName:@"Water" Delegate:self];
    body->SetUserData(data);
    body->CreateFixture(&fd);
    
    _bodies[i] = body;
  }
}

- (void)step
{
  
}

b2Vec2 newP1, newP2, newP3, newP4, newP5, newP6;

- (void)draw
{
  
  for (int i=0; i<kMaxWaterDrop; i++) 
  {
    b2Body* body = _bodies[i];
    b2Vec2 pos = body->GetPosition();
    
    ccDrawFilledCircle(
        ccp(  pos.x * [Box2DHelper pointsPerMeter] * CC_CONTENT_SCALE_FACTOR(), 
              pos.y * [Box2DHelper pointsPerMeter] * CC_CONTENT_SCALE_FACTOR()), 
                       RADIUS_WATER, 0, 2*M_PI, 20);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  }
  

//  glEnable(GL_LINE_SMOOTH);
//  glColor4ub(255, 255, 255, 255);
//  CGPoint vertices2[] = { 
//    ccp(newP1.x* CC_CONTENT_SCALE_FACTOR(),newP1.y* CC_CONTENT_SCALE_FACTOR()), 
//    ccp(newP2.x* CC_CONTENT_SCALE_FACTOR(),newP2.y* CC_CONTENT_SCALE_FACTOR()), 
//    ccp(newP5.x* CC_CONTENT_SCALE_FACTOR(),newP5.y* CC_CONTENT_SCALE_FACTOR()), 
//    ccp(newP6.x* CC_CONTENT_SCALE_FACTOR(),newP6.y* CC_CONTENT_SCALE_FACTOR()), 
//    ccp(newP3.x* CC_CONTENT_SCALE_FACTOR(),newP3.y* CC_CONTENT_SCALE_FACTOR()), 
//    ccp(newP4.x* CC_CONTENT_SCALE_FACTOR(),newP4.y* CC_CONTENT_SCALE_FACTOR()) };
//  ccDrawPoly(vertices2, 6, YES);
  glDisable(GL_LINE_SMOOTH);
  
//  const GLfloat spriteVertices[] = {
//    newP1.x* CC_CONTENT_SCALE_FACTOR(),newP1.y* CC_CONTENT_SCALE_FACTOR(),
//    newP2.x* CC_CONTENT_SCALE_FACTOR(),newP2.y* CC_CONTENT_SCALE_FACTOR(),
//    newP5.x* CC_CONTENT_SCALE_FACTOR(),newP5.y* CC_CONTENT_SCALE_FACTOR(),
//    newP6.x* CC_CONTENT_SCALE_FACTOR(),newP6.y* CC_CONTENT_SCALE_FACTOR(),
//    newP3.x* CC_CONTENT_SCALE_FACTOR(),newP3.y* CC_CONTENT_SCALE_FACTOR(),
//    newP4.x* CC_CONTENT_SCALE_FACTOR(),newP4.y* CC_CONTENT_SCALE_FACTOR(),
//  };
//  
//  glColor4ub(255, 255, 255, 255);
//  glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
//  glEnableClientState(GL_VERTEX_ARRAY);
}

/** Contact Delegate Methods **/
- (void) postSolve:(b2Contact *)contact :(const b2ContactImpulse *)impulse{}
- (void) beginContact:(b2Contact *)contact{}
- (void) endContact:(b2Contact *)contact{}

- (void) preSolve:(b2Contact*)contact:(const b2Manifold*)manifold
{
  b2Fixture *a = contact->GetFixtureA();
  b2Body* bodyA = a->GetBody();
  
  b2Fixture *b = contact->GetFixtureB();
  b2Body* bodyB = b->GetBody();  
  
  b2Vec2 aPos = bodyA->GetWorldCenter();
  b2Vec2 bPos = bodyB->GetWorldCenter();
  
  aPos.x = aPos.x * [Box2DHelper pointsPerMeter];
  aPos.y = aPos.y * [Box2DHelper pointsPerMeter];
  bPos.x = bPos.x * [Box2DHelper pointsPerMeter];
  bPos.y = bPos.y * [Box2DHelper pointsPerMeter];
//  
//  CCLOG(@"aPos = %f, %f", aPos.x, aPos.y);
//  CCLOG(@"bPos = %f, %f", bPos.x, bPos.y);
  
  float dx = bPos.x - aPos.x;
  float dy = bPos.y - aPos.y;
  
  b2Vec2 abMid = b2Vec2((aPos.x + bPos.x)/2, (aPos.y + bPos.y)/2);
  b2Vec2 abVec = b2Vec2(dx, dy);
  b2Vec2 abNor = b2Vec2(-dy, dx);
  b2Vec2 abNor2= b2Vec2(dy, -dx);
  
  abNor.Normalize();
  abNor2.Normalize();
  
  float scal = 200.0f / abVec.LengthSquared();
  
//  CCLOG(@"length squared = %f", abVec.LengthSquared());
  
  b2Vec2 pos = b2Vec2(self.position.x, self.position.y);
  newP1 = RADIUS_WATER * abNor + aPos - pos;
  newP2 = RADIUS_WATER*scal * abNor + abMid - pos;
  newP3 = RADIUS_WATER*scal * abNor2 + abMid - pos;
  newP4 = RADIUS_WATER * abNor2 + aPos - pos;
  newP5 = RADIUS_WATER * abNor + bPos - pos;
  newP6 = RADIUS_WATER * abNor2 + bPos - pos;
  
//  newP1.x = newP1.x * [Box2DHelper pointsPerMeter];
//  newP1.y = newP1.y * [Box2DHelper pointsPerMeter];
//  newP2.x = newP2.x * [Box2DHelper pointsPerMeter];
//  newP2.y = newP2.y * [Box2DHelper pointsPerMeter];
//  newP3.x = newP3.x * [Box2DHelper pointsPerMeter];
//  newP3.y = newP3.y * [Box2DHelper pointsPerMeter];
//  newP4.x = newP4.x * [Box2DHelper pointsPerMeter];
//  newP4.y = newP4.y * [Box2DHelper pointsPerMeter];
  
//  CCLOG(@"newP1 = %f, %f", newP1.x, newP1.y);
//  CCLOG(@"newP2 = %f, %f", newP2.x, newP2.y);
//  CCLOG(@"newP3 = %f, %f", newP3.x, newP3.y);
//  CCLOG(@"newP4 = %f, %f", newP4.x, newP4.y);
//  
//  CCLOG(@" =========================== ");
  
}

@end
