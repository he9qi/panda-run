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
#import "PauseView.h"
#import "TerrainImageItem.h"
#import "TTSpriteItem.h"
#import "Cloud.h"
#import "Leaf.h"
#import "OverView.h"

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

static int coinIndices [kMaxTerrainItems]   = { 30, 33, 36, 39, 42, 70, 73, 76, 79 }; 
static int energyIndices [kMaxTerrainItems] = { 4, 10, 18, 20, 16 }; 
static int bushIndices [kMaxTerrainItems]   = { 15, 50, 70, 85, 95, 110, 135, 150, 165, 180, 199, 220, 240, 255, 280, 290, 301 };
static int treeIndices [kMaxTerrainItems]   = { 25, 35, 37, 60, 65, 80, 110, 112, 114, 116, 120, 140, 146, 170, 190, 210, 239, 278 };
static int woodIndices [kMaxTerrainItems]   = { 30, 40, 50, 60, 75, 85, 100, 200, 300 }; 
static int grassIndices [kMaxTerrainItems]  = { }; 

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
@synthesize clouds  = _clouds;

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
		[self addChild:_sky z:-2 tag:GameSceneNodeTagSky];
    
//    _hill = [Hill hillWithTextureSize:TEXTURE_SIZE_HILL];
//    [self addChild:_hill];
#endif
    
		self.terrain = [Terrain terrainWithWorld:_world];
    
    _bushes = [[NSMutableArray alloc] init];
    [_terrain addImageItemWithType:cTerrainImageItemBush At:bushIndices To:_bushes];
    
    _trees = [[NSMutableArray alloc] init];
    [_terrain addImageItemWithType:cTerrainImageItemTree At:treeIndices To:_trees];
    
    _woods = [[NSMutableArray alloc] init];
    [_terrain addImageItemWithType:cTerrainImageItemWood At:woodIndices To:_woods];
    
    _grasses = [[NSMutableArray alloc] init];
    int templePosition  = [_terrain getTemplePostition] / CC_CONTENT_SCALE_FACTOR();
    int indices[kMaxTerrainItems] = { templePosition-2, templePosition-0, templePosition + 2 };
    
    [_terrain addImageItemWithType:cTerrainImageItemGrass At:indices To:_grasses];
    
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
    
    _clouds = [[Cloud createCloudsTo:self Count:kMaxCloud Z:-1 Tag:GameSceneNodeTagCloud] retain];
    

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
    
    //create pause button
    
    CCSprite *sprite;
    
    sprite = [CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_PAUSE];
		sprite.opacity = 0;
		[sprite runAction:[CCFadeIn actionWithDuration:0.25f]];
    
    pauseButton = [CCMenuItemImage itemFromNormalSprite:sprite selectedSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_PAUSE_PRESSED] target:self selector:@selector(onPauseButtonClicked:)];
    
    CCMenu *gameMenu = [CCMenu menuWithItems:pauseButton, nil];
		gameMenu.anchorPoint = ccp(.5,0);
		gameMenu.position = ccp(_screenW-pauseButton.contentSize.width/2-kPauseButtonPadding, _screenH-pauseButton.contentSize.height/2-kPauseButtonPadding);
		[self addChild:gameMenu];
    
    score = 0;
    scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", score] fontName:kFontName fontSize:30];
    scoreLabel.position = ccp(scoreLabel.contentSize.width+kPauseButtonPadding, scoreLabel.contentSize.height+kPauseButtonPadding);
    [self addChild:scoreLabel];

    [self dim];
    
    
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

- (void) dealloc {
  
  [self deleteBox2DDebug];
	[self deleteBox2DWorld];
  
  colorLayer = nil;
  scoreLabel = nil;
	
	[super dealloc];
}

- (void)finish
{
  [super finish];
  [self dim];
  
  [Leaf createLeavesTo:self Count:kMaxLeaves Z:kLeafZDepth Tag:GameSceneNodeTagLeaf];
  
  OverView *overView = [[OverView alloc] init];
  overView.isRelativeAnchorPoint = YES;
  overView.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
  overView.tryAgainButtonTarget = self;
  overView.tryAgainButtonSelector = @selector(onRestartButtonClicked:);
  overView.menuButtonTarget = self;
  overView.menuButtonSelector = @selector(onMenuButtonClicked:);
  [overView setScore:score];
  
  [self addChild:overView z:kMenuZDepth];

}

- (void)start{
  [super start];
}

- (void)resume{
  [self light];
  [super resume];
  [self removeLeaves];
}

- (void)pause
{
  [super pause];
  [self dim];
  
  [Leaf createLeavesTo:self Count:kMaxLeaves Z:kLeafZDepth Tag:GameSceneNodeTagLeaf];
  
  PauseView *pauseView = [[PauseView alloc] init];
  pauseView.isRelativeAnchorPoint = YES;
  pauseView.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
  pauseView.resumeButtonTarget = self;
  pauseView.resumeButtonSelector = @selector(onResumeButtonClicked:);
  pauseView.restartButtonTarget = self;
  pauseView.restartButtonSelector = @selector(onRestartButtonClicked:);
  pauseView.menuButtonTarget = self;
  pauseView.menuButtonSelector = @selector(onMenuButtonClicked:);
  pauseView.quitButtonTarget = self;
  pauseView.quitButtonSelector = @selector(onQuitButtonClicked:);
  
  [self addChild:pauseView z:kMenuZDepth];
  
}

- (void) removeLeaves{
  while (Leaf *leaf = (Leaf *)[self getChildByTag:GameSceneNodeTagLeaf]) {
    [self removeChild:leaf cleanup:YES];
  }
}

- (void) onResumeButtonClicked:(id) sender
{
	// do something
  [self resume];
}

- (void) onRestartButtonClicked:(id) sender 
{
	// do something
  [self removeLeaves];
  [self reset];
  [self restart];
  [self dim];
}

- (void) onQuitButtonClicked:(id) sender 
{
	// do something
  [[CCDirector sharedDirector] popScene];	
}

- (void) onMenuButtonClicked:(id) sender 
{
	// do something
  [[CCDirector sharedDirector] popScene];	
}

- (void) onPauseButtonClicked:(id) sender
{
  if ([self isStarted]) [self pause];
}

- (void)incScore:(int)s
{
  score += s;
  [scoreLabel setString:[NSString stringWithFormat:@"%d", score]];
}

- (void)resetScore:(int)s
{
  score = 0;
  [scoreLabel setString:[NSString stringWithFormat:@"%d", score]];
}

- (void) addCoins:(int *)indices{
  for (int i=0; i<kMaxCoins; i++) {
    if (indices[i]) {
      [_coins addObject:(Coin *)[Coin createItemTo:self On:_terrain At:indices[i] * CC_CONTENT_SCALE_FACTOR()]];
    }
  }
}

- (void) addEnergies:(int *)indices{
  for (int i=0; i<kMaxEnergies; i++) {
    if (indices[i]) {
      [_energies addObject:(Energy *)[Energy createItemTo:self On:_terrain At:indices[i] * CC_CONTENT_SCALE_FACTOR()]];
    }
  }
}

/**********  Box2D World Creation and Deletion  ********/

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
  
  [self.clouds release];
  self.clouds = nil;
  
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
  
  for (Cloud *cloud in _clouds) {
    [cloud setScale:1.0f-(1.0f-scale)*0.975f];
  }
  
#endif
  
    _terrain.offsetX = _panda.position.x;
#ifndef DRAW_BOX2D_WORLD
    [_mud setOffsetX:_terrain.offsetX];
    [_hill setOffsetX:_terrain.offsetX*0.95f];
    [_sky setOffsetX:_terrain.offsetX*0.2f];
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
	
  if ( [self isIdle] ) {
    [self light];
    [self start];
    
    _panda.diving = YES;
    [_panda updatePhysics];
    return YES;
  }
  
  if ( [self isDimmed] ) return YES;
  if ( [self isRunning] ) _panda.diving = YES;

	return YES;
}

- (BOOL) touchEndedAt:(CGPoint)location {
	_panda.diving = NO;
	return YES;
}

#pragma mark methods

- (void) reset {
  [_terrain reset];
  [_panda reset];
  
  for (Coin *coin in _coins) [coin reset];
  for (Energy *en in _energies) [en reset];
  
  _state = kGameStateIdle;
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
