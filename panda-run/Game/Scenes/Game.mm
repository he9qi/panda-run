//
//  Game.m
//  panda-run
//
//  Created by Qi He on 12-6-26.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Game.h"
#import "Constants.h"
#import "Box2DHelper.h"


@interface Game()
- (void) createBox2DWorld;    // create the physics world
- (void) deleteBox2DWorld;    // delete objects and world
- (void) createBox2DDebug;    // draw box2d world for debug
- (void) deleteBox2DDebug;    // remove debug
- (BOOL) touchBeganAt:(CGPoint)location;
- (BOOL) touchEndedAt:(CGPoint)location;
- (void) addCoin:(int)index;
- (void) addCoins:(int[])indices;
- (void) reset;
@end

static int coinIndices [kMaxCoins] = { 30, 32, 34, 36, 39 }; 

@implementation Game

@synthesize screenW = _screenW;
@synthesize screenH = _screenH;
@synthesize world   = _world;
@synthesize sky     = _sky;
@synthesize terrain = _terrain;
@synthesize panda   = _panda;
@synthesize coins   = _coins;
@synthesize woods   = _woods;

+ (CCScene*) scene {
	CCScene *scene = [CCScene node];
	[scene addChild:[Game node]];
	return scene;
}

- (id) init {
	
	if ((self = [super init])) {
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		_screenW = screenSize.width;
		_screenH = screenSize.height;
    
		[self createBox2DWorld];
    [self createBox2DDebug];
    
#ifndef DRAW_BOX2D_WORLD    
    self.sky = [Sky skyWithTextureSize:1024];
		[self addChild:_sky];
#endif
    
		self.terrain = [Terrain terrainWithWorld:_world];
		[self addChild:_terrain];
    
		self.panda = [Panda heroWithGame:self];
		[_terrain addChild:_panda];
    
    _coins = [[NSMutableArray alloc] init];
    [self addCoins:coinIndices];
    
//    _woods = [[NSMutableArray alloc] init];
//    ccVertex2F bp = [_terrain getBorderVerticeAt:20];
//    CGPoint p = ccp(bp.x, bp.y + RADIUS_COIN + 30.0f);
//
//    BreakableWood *bw = [BreakableWood breakableWoodWithGame:self Position:p];
//    [_woods addObject:bw];
//    [_terrain addChild:bw];
    
//    bp = [_terrain getBorderVerticeAt:43];
//    p = ccp(bp.x, bp.y + 15.0f);
//    Bridge *bridge = [Bridge bridgeWithGame:self Position:p];
//    [_terrain addChild:bridge];
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#else
		self.isMouseEnabled = YES;
#endif
    
    // When this is called, the update method will be called every frame 
    // with the “delta time” as argument.
		[self scheduleUpdate];
	}
	return self;
}

- (void) addCoins:(int[])indices{
  for (int i=0; i<kMaxCoins; i++) {
    if (indices[i]) {
      [self addCoin:indices[i]];
    }
  }
}

- (void) addCoin:(int)index{
  ccVertex2F bp = [_terrain getBorderVerticeAt:index];
  CGPoint p = ccp(bp.x, bp.y + RADIUS_COIN + 5.0f);
  Coin *coin = [Coin coinWithGame:self Position:p];
  [_coins addObject:coin];
  [_terrain addChild:coin];
}

- (void) createBox2DWorld {
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -9.8f);
	
	_world = new b2World(gravity, false);
  
}

- (void) deleteBox2DWorld {
  
	self.sky = nil;
  self.terrain = nil;
  self.panda = nil;
  
  /**
   When you add an object to an array, it calls retain on that object. 
   If you don't release your pointer to that object, it will be a leak. 
   When you release the array, it will call release on all of the objects 
   that it holds, since it called retain previously.
   **/
  [self.coins release];
  self.coins = nil;
  
  [self.woods release];
  self.woods = nil;
  
	delete _world;
	_world = NULL;
}

- (void) update:(ccTime)dt {
  
  [_panda updatePhysics];
  
  _world->Step(dt, kVelocityIterations, kPositionIterations);
  //	_world->ClearForces();
	
	[_panda updateNode];
  
//  for (BreakableWood *bw in _woods) {
//    [bw step];
//  }
  
	// terrain scale and offset
	float height = _panda.position.y;
	const float minHeight = _screenH*4/5;
	if (height < minHeight) {
		height = minHeight;
	}
	float scale = minHeight / height;
	_terrain.scale = scale;
	_terrain.offsetX = _panda.position.x;
  
#ifndef DRAW_BOX2D_WORLD
	[_sky setOffsetX:_terrain.offsetX*0.2f];
	[_sky setScale:1.0f-(1.0f-scale)*0.75f];
#endif

}

#pragma mark touches

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (void) registerWithTouchDispatcher {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	return [self touchBeganAt:location];;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	[self touchEndedAt:location];;
}

#else

- (void) registerWithTouchDispatcher {
	[[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority:0];
}

- (BOOL)ccMouseDown:(NSEvent *)event {
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
	return [self touchBeganAt:location];
}

- (BOOL)ccMouseUp:(NSEvent *)event {
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
	return [self touchEndedAt:location];
}

#endif

- (BOOL) touchBeganAt:(CGPoint)location {
//	CGPoint pos = _resetButton.position;
//	CGSize size = _resetButton.contentSize;
//	float padding = 8;
//	float w = size.width+padding*2;
//	float h = size.height+padding*2;
//	CGRect rect = CGRectMake(pos.x-w/2, pos.y-h/2, w, h);
//	if (CGRectContainsPoint(rect, location)) {
//		[self reset];
//	} else {
		_panda.diving = YES;
//	}
	return YES;
}

- (BOOL) touchEndedAt:(CGPoint)location {
	_panda.diving = NO;
	return YES;
}

- (void) dealloc {
  
  [self deleteBox2DDebug];
	[self deleteBox2DWorld];
	
	[super dealloc];
}

#pragma mark methods

- (void) reset {
  [_terrain reset];
  [_panda reset];
  
  for (Coin *coin in _coins) [coin reset];
  for (BreakableWood *bw in _woods) [bw reset];
}


/**********  Box2D World Debug  ********/

- (void) deleteBox2DDebug {
#ifdef DRAW_BOX2D_WORLD
  
	delete _render;
	_render = NULL;
	
#endif
}

- (void) createBox2DDebug {
#ifdef DRAW_BOX2D_WORLD
	
	_render = new GLESDebugDraw([Box2DHelper pointsPerMeter]);
	_world->SetDebugDraw(_render);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
  flags += b2Draw::e_jointBit;
  flags += b2Draw::e_aabbBit;
  //	flags += b2Draw::e_pairBit;
  //	flags += b2Draw::e_centerOfMassBit;
	_render->SetFlags(flags);
	
#endif
}

@end
