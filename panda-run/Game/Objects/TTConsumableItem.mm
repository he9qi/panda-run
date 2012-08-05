//
//  TTConsumableItem.m
//  panda-run
//
//  Created by Qi He on 12-7-23.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "TTConsumableItem.h"
#import "Game.h"
#import "Box2D.h"
#import "Constants.h"
#import "Box2DHelper.h"
#import "UserData.h"

@implementation TTConsumableItem

@synthesize game = _game;
@synthesize sprite = _sprite;

+ (id) itemWithGame:(Game*)game Sprite:(CCSprite *)sprite Radius:(float)radius Position:(CGPoint)p{
	return [[[self alloc] initWithGame:game Sprite:sprite Radius:radius Position:p] autorelease];
}

- (id) initWithGame:(Game*)game Sprite:(CCSprite *)sprite Radius:(float)radius Position:(CGPoint)p{
	
	if ((self = [super init])) {
    
		self.game = game;
    self.position = p;
		
    //#ifndef DRAW_BOX2D_WORLD
		self.sprite = sprite;
    [self showSprite];
    //#endif
    
		_radius = radius;
		_body = NULL;
    
		[self reset];
	}
	return self;
}

- (void) dealloc {
  
	self.game = nil;
  self.sprite = nil;
  
  if ( _name ) { [_name release]; }

  //#ifndef DRAW_BOX2D_WORLD
	self.sprite = nil;
  //#endif
  
	[super dealloc];
}

- (void) hideSprite {
#ifndef DRAW_BOX2D_WORLD
  [self.sprite removeFromParentAndCleanup: YES];
#endif
}

- (void) showSprite {
#ifndef DRAW_BOX2D_WORLD
  if( ![self getChildByTag:kTTConsumableItemTag] ) 
    [self addChild:_sprite z:kTTConsumableItemZDepth tag:kTTConsumableItemTag];
#endif
}

- (void)preSolve:(b2Contact *)contact :(const b2Manifold *)manifold{}
- (void)postSolve:(b2Contact*)contact:(const b2ContactImpulse*)impulse{}
- (void)endContact:(b2Contact *)contact{} 

- (void)beginContact:(b2Contact *)contact{
  [self hideSprite];
}


- (void) reset {
	if (_body) {
		_game.world->DestroyBody(_body);
	}
	[self createBox2DBody];
  [self showSprite];
}

- (void)createBox2DBody {
  b2BodyDef bd;
	bd.type = b2_staticBody;
	
	// start position
	CGPoint p = self.position;
  
	bd.position.Set(p.x * [Box2DHelper metersPerPoint], p.y * [Box2DHelper metersPerPoint]);
	_body = _game.world->CreateBody(&bd);
  
	b2CircleShape shape;
	shape.m_radius = _radius * [Box2DHelper metersPerPoint];
	
	b2FixtureDef fd;
	fd.shape = &shape;
  fd.isSensor = true;
	_body->CreateFixture(&fd);
  
  _name = [NSStringFromClass([self class]) retain];
  UserData *data = [[UserData alloc]initWithName:_name Group:@"TTConsumableItem" Delegate:self];
  _body->SetUserData(data);
}

+ (TTConsumableItem *)createItemTo:(Game *)game On:(Terrain *)terrain At:(int)index{
  return nil;
}

@end

