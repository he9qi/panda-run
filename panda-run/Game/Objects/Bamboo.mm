//
//  Bamboo.m
//  panda-run
//
//  Created by Qi He on 12-7-2.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Bamboo.h"
#import "Game.h"
#import "Box2D.h"
#import "Constants.h"
#import "Box2DHelper.h"
#import "UserData.h"

@interface Bamboo()
- (void)createBox2DBody;
@end

@implementation Bamboo

@synthesize game = _game;
@synthesize sprite = _sprite;

+ (id) bambooWithGame:(Game*)game Position:(CGPoint)p{
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
		_radius = RADIUS_COIN;
		_body = NULL;
    
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
	if (_body) {
		_game.world->DestroyBody(_body);
	}
	[self createBox2DBody];
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
  
  UserData *data = [[UserData alloc]initWithName:@"Bamboo"];
  _body->SetUserData(data);
	_body->CreateFixture(&fd);
}

@end
