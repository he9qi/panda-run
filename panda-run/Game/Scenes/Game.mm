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
#import "CCAlertView.h"
#import "TerrainImageItem.h"
#import "TTSpriteItem.h"


@interface Game()
- (void) createBox2DWorld;    // create the physics world
- (void) deleteBox2DWorld;    // delete objects and world
- (void) createBox2DDebug;    // draw box2d world for debug
- (void) deleteBox2DDebug;    // remove debug
- (BOOL) touchBeganAt:(CGPoint)location;
- (BOOL) touchEndedAt:(CGPoint)location;
- (void) addCoins:(int[])indices;
- (void) addEnergies:(int[])indices;
- (void) reset;
@end

static int coinIndices [kMaxCoins]        = { 30, 33, 36, 39, 42, 70, 73, 76, 79 }; 
static int energyIndices [kMaxEnergies]   = { 2, 4, 10, 18, 20, 16 }; 
static int bushIndices [kMaxBushes]       = { 15, 50, 70, 85, 95, 110, 135, 150, 165, 180, 199, 220, 240, 255, 280, 290, 301 };
static int treeIndices [kMaxTerrainItems] = { 25, 35, 37, 60, 65, 80, 110, 112, 114, 116, 120, 140, 146, 170, 190, 210, 239, 278 };
static int woodIndices [kMaxWoods]        = { 30, 40, 50, 60, 75, 85, 100, 200, 300 }; 
static int grassIndices [kMaxWoods]        = { 1, 2, 3, 4, 5, 6, 7, 8 }; 

@implementation Game

@synthesize screenW = _screenW;
@synthesize screenH = _screenH;
@synthesize world   = _world;
@synthesize sky     = _sky;
@synthesize terrain = _terrain;
@synthesize panda   = _panda;
@synthesize coins   = _coins;
@synthesize woods   = _woods;
@synthesize mud     = _mud;
@synthesize hill    = _hill;
@synthesize energies= _energies;
@synthesize bushes  = _bushes;
@synthesize trees   = _trees;
@synthesize grasses = _grasses;

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
    self.sky = [Sky skyWithTextureSize:TEXTURE_SIZE_SKY];
		[self addChild:_sky];
    
    _hill = [Hill hillWithTextureSize:1024];
    [self addChild:_hill];
#endif
    
		self.terrain = [Terrain terrainWithWorld:_world];
    
    _bushes = [[NSMutableArray alloc] init];
    [self addBushes:bushIndices];
    
    _trees = [[NSMutableArray alloc] init];
    [self addImageItem:IMAGE_TREE At:treeIndices To:_trees];
    
    _woods = [[NSMutableArray alloc] init];
    [self addImageItem:IMAGE_WOOD At:woodIndices To:_woods];
    
    _grasses = [[NSMutableArray alloc] init];
    [self addGrasses];
    
		[self addChild:_terrain];
    
		self.panda = [Panda heroWithGame:self];
		[_terrain addChild:_panda];
    
    _coins = [[NSMutableArray alloc] init];
    [self addCoins:coinIndices];
    
//    _mud = [Mud mudWithTextureSize:1024];
//    [self addChild:_mud];
    
    ccVertex2F bp = [_terrain getBorderVerticeAt:[_terrain getTemplePostition]];
    CGPoint p = ccp(bp.x* [Box2DHelper pointsPerPixel], bp.y * [Box2DHelper pointsPerPixel]+kTemplePositionYOffset);
    _temple = [Temple templeWithPosition:p];
    [_terrain addChild:_temple];
    
    _energies = [[NSMutableArray alloc] init];
    [self addEnergies:energyIndices];

//
//    BreakableWood *bw = [BreakableWood breakableWoodWithGame:self Position:p];
//    [_woods addObject:bw];
//    [_terrain addChild:bw];
    
//    bp = [_terrain getBorderVerticeAt:43];
//    p = ccp(bp.x, bp.y + 15.0f);
//    Bridge *bridge = [Bridge bridgeWithGame:self Position:p];
//    [_terrain addChild:bridge];
    
//    ccVertex2F bp = [_terrain getBorderVerticeAt:13];
//    CGPoint p = ccp(bp.x, bp.y + 10.0f);
//    Water *water = [Water waterWithGame:self Position:p];
//    [_terrain addChild:water];
    
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

- (void)pause
{
  [self pauseSchedulerAndActions];
  for(CCSprite *sprite in [self children]) {
    [[CCActionManager sharedManager] pauseTarget:sprite];
  }
}

- (void)resume
{
  [self resumeSchedulerAndActions];
  for(CCSprite *sprite in [self children]) {
    [[CCActionManager sharedManager] resumeTarget:sprite];
  }
}

- (void)over
{
  [self pause];
  CCAlertView *alertView = [[CCAlertView alloc] init];
  alertView.isRelativeAnchorPoint = YES;
  alertView.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
//  alertView.Message = @"Nice Job!!!";
  alertView.SubMessage = @"Your panda has reached temple!!!.";
  alertView.Button1 = @"OK";
  alertView.button1Target = self;
  alertView.button1Selector = @selector(onAlertButtonOK:);
  
  [self addChild:alertView z:1001];
}

- (void) onAlertButtonOK:(id) alertView // companion function for YES button
{
	// do something
  [[CCDirector sharedDirector] popScene];	
  [self reset];
}

- (bool) isHD{
  return _screenW > 480;
}

- (void) addImageItem:(NSString *)name At:(int[])indices To:(NSMutableArray *)items
{
  for (int i=0; i<kMaxBushes; i++) {
    if (indices[i]) {
      [items addObject:(TerrainImageItem *)[TerrainImageItem createItemWithImage:name On:_terrain At:indices[i]]];
    }
  }
}

- (void) addGrasses{
  for (int i=0; i<[_terrain getNumBorderVertices]; i++) {
    if (i % 4 == 0) {
      [_grasses addObject:(TerrainImageItem *)[TerrainImageItem createItemWithImage:IMAGE_GRASS On:_terrain At:i]];
    }
  }
}

- (void) addBushes:(int[])indices{
  for (int i=0; i<kMaxBushes; i++) {
    if (indices[i]) {
      [_bushes addObject:(Bush *)[Bush createItemOn:_terrain At:indices[i]]];
    }
  }
}

- (void) addCoins:(int[])indices{
  for (int i=0; i<kMaxCoins; i++) {
    if (indices[i]) {
      [_coins addObject:(Coin *)[Coin createItemTo:self On:_terrain At:indices[i]]];
    }
  }
}

- (void) addEnergies:(int[])indices{
  for (int i=0; i<kMaxEnergies; i++) {
    if (indices[i]) {
      [_energies addObject:(Energy *)[Energy createItemTo:self On:_terrain At:indices[i]]];
    }
  }
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
  self.mud = nil;
  self.hill = nil;
  
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
  
  [self.energies release];
  self.energies = nil;
  
  [self.grasses release];
  self.grasses = nil;
  
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
  
#ifndef DRAW_BOX2D_WORLD
	[_sky setScale:1.0f-(1.0f-scale)*0.75f];
	[_hill setScale:1.0f-(1.0f-scale)*0.95f];
	[_mud setScale:1.0f-(1.0f-scale)];
#endif
  
//  if (![_terrain reachedEnd]) {
    _terrain.offsetX = _panda.position.x;
#ifndef DRAW_BOX2D_WORLD
    [_mud setOffsetX:_terrain.offsetX];
    [_hill setOffsetX:_terrain.offsetX*0.95f];
    [_sky setOffsetX:_terrain.offsetX*0.2f];
#endif
//  }

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
  if ( [self isRunning] ) {
    _panda.diving = YES;
  }
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
  for (Energy *en in _energies) [en reset];
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
//  flags += b2Draw::e_jointBit;
//  flags += b2Draw::e_aabbBit;
  //	flags += b2Draw::e_pairBit;
  //	flags += b2Draw::e_centerOfMassBit;
	_render->SetFlags(flags);
	
#endif
}

@end
