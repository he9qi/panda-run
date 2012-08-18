//
//  Game.m
//  panda-run
//
//  Created by Qi He on 12-6-26.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"
#import "Constants.h"
#import "Box2DHelper.h"
#import "PauseView.h"

#import "TerrainImageItem.h"
#import "TTSpriteItem.h"
#import "Cloud.h"
#import "Leaf.h"
#import "OverView.h"
#import "Rain.h"
#import "Fire.h"
#import "Sky.h"
#import "Terrain.h"
#import "Panda.h"
#import "Coin.h"
#import "BreakableWood.h"
#import "Bridge.h"
#import "Water.h"
#import "Mud.h"
#import "Hill.h"
#import "Energy.h"
#import "Bush.h"
#import "Waves.h"

#import "SimpleAudioEngine.h"

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
- (void) saveScore;
- (int)  highScore;
@end

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
@synthesize waves   = _waves;

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
    
    _hill = [Hill hillWithTextureSize:TEXTURE_SIZE_HILL];
    [self addChild:_hill];
#endif
    
    
    /*************** BUILD TERRAIN ***************/
    
    _bushes = [[NSMutableArray alloc] init];
    _trees = [[NSMutableArray alloc] init];
    _woods = [[NSMutableArray alloc] init];
    _grasses = [[NSMutableArray alloc] init];
    
		self.terrain = [Terrain terrainWithWorld:_world];
    int templePosition  = [_terrain getTemplePostition] / CC_CONTENT_SCALE_FACTOR();
    
    for (int i = 10; i < [_terrain getNumBorderVertices]; i++) {
      if (i%5 != 0) { continue; }
      switch ( arc4random() % 20 ) {
        case cTerrainImageItemTree:
          [_terrain addImageItemWithType:cTerrainImageItemTree At:i To:_trees];
          break;
        case cTerrainImageItemBush:
          [_terrain addImageItemWithType:cTerrainImageItemBush At:i To:_bushes];
          break;
        case cTerrainImageItemWood:
          [_terrain addImageItemWithType:cTerrainImageItemWood At:i To:_woods];
          break;
        case cTerrainImageItemGrass:
          [_terrain addImageItemWithType:cTerrainImageItemTree At:i To:_trees]; //more trees
          break;
        default:
          break;
      }
    }
//    
    //temple
    [_terrain addImageItemWithType:cTerrainImageItemTemple At:templePosition To:nil];
    
//    //add bush now (instead of grass as before)
//    for (int i = templePosition - kTempleGrassLength; i < templePosition + kTempleGrassLength * 2; i+=2) {
      [_terrain addImageItemWithType:cTerrainImageItemBush At:templePosition - kTempleGrassLength To:_bushes];
      [_terrain addImageItemWithType:cTerrainImageItemBush At:templePosition + kTempleGrassLength To:_bushes];
//    }
    
		[self addChild:_terrain z:kTerrainZDepth tag:GameSceneNodeTagTerrain];
    
		self.panda = [Panda heroWithGame:self];
		[_terrain addChild:_panda];
    
    /*************** BUILD TERRAIN END ***************/
    
    _coins = [[NSMutableArray alloc] init];
    for (int i=kTempleCoinsLength; i<templePosition-kTempleCoinsLength; i++) {
      int max = arc4random()%20;
      if( max % 5 == 0) {
        for (int k=0; k<max; k+=3) {
          [_coins addObject:(Coin *)[Coin createItemTo:self On:_terrain At:(i+k) * CC_CONTENT_SCALE_FACTOR()]];
        }
      }
      i = i + max;
    }

    _energies = [[NSMutableArray alloc] init];
    for (int i=2; i< [_terrain getNumHilKeyPoints]-2; i+=2) {
      if( arc4random() % 3 == 1) {
        [_energies addObject:(Energy *)[Energy createItemTo:self On:_terrain At:i]];
      }
    }
    
    //Clouds
    _clouds = [[Cloud createCloudsTo:self Count:kMaxCloud Z:-1 Tag:GameSceneNodeTagCloud] retain];
    
    
//    _mud = [Mud mudWithTextureSize:1024];
//    [self addChild:_mud];
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
    
    //create leaves
    
    _rainSystem = [[Rain alloc] init];
    [self addChild:_rainSystem z:1 tag:GameSceneNodeTagRain];
    
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
    scoreLabel.position = ccp(scoreLabel.contentSize.width+kScoreLabelPadding, scoreLabel.contentSize.height+kScoreLabelPadding/4);
    [self addChild:scoreLabel z:kTipsZDepth tag:GameSceneNodeTagText];

    [self dim];
    
    [self showTips]; 
    
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game.mp3"];
    
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

/****************** State functions *********************/

- (void)finish
{
  [super finish];
  [self dim];
  
  OverView *overView = [[OverView alloc] init];
  overView.isRelativeAnchorPoint = YES;
  overView.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
  overView.tryAgainButtonTarget = self;
  overView.tryAgainButtonSelector = @selector(onRestartButtonClicked:);
  overView.menuButtonTarget = self;
  overView.menuButtonSelector = @selector(onMenuButtonClicked:);
  [overView setScore:score];
  
  int highScore = [self highScore];
  [overView setHighScore:highScore];
  
  if (score > highScore) { [self saveScore]; }
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


/****************** Other functions *********************/

- (void) removeLeaves{
  while (Leaf *leaf = (Leaf *)[self getChildByTag:GameSceneNodeTagLeaf]) {
    [self removeChild:leaf cleanup:YES];
  }
}

- (void)incScore:(int)s
{
  score += s;
  [scoreLabel setString:[NSString stringWithFormat:@"%d", score]];
}

- (void)resetScore
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
  
  _waves = nil;
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
	[_sky setScale:1.0f-(1.0f-scale)*kSkyScaleFactor];
	[_hill setScale:1.0f-(1.0f-scale)*kHillScaleFactor];
	[_mud setScale:1.0f-(1.0f-scale)];
  
  for (Cloud *cloud in _clouds) {
    [cloud setScale:1.0f-(1.0f-scale)*kCloudScaleFactor];
  }
  
#endif
  
    _terrain.offsetX = _panda.position.x;
#ifndef DRAW_BOX2D_WORLD
    [_mud setOffsetX:_terrain.offsetX];
    [_hill setOffsetX:_terrain.offsetX*kHillOffsetFactor];
    [_sky setOffsetX:_terrain.offsetX*kSkyOffsetFactor];
#endif

}

#pragma mark methods

- (void) reset {
  [_terrain reset];
  [_panda reset];
  
  for (Coin *coin in _coins) [coin reset];
  for (Energy *en in _energies) [en reset];
  
  _state = kGameStateIdle;
  [self resetScore];
  [self showTips];
}

/************  touches  **************/

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
    [self hideTips];
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

/************ game show **************/

- (void) showHint:(NSString *)hint Scale:(float)scale Duration:(float)duration Position:(CGPoint)position{
  CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:hint] fontName:kHintFontName fontSize:kHintFontSize];
  label.position = position;
	[label runAction:[CCScaleTo actionWithDuration:duration scale:scale]];
	[label runAction:[CCSequence actions:
                    [CCFadeOut actionWithDuration:duration],
                    [CCCallFuncND actionWithTarget:label selector:@selector(removeFromParentAndCleanup:) data:(void*)YES],
                    nil]];
	[self addChild:label z:kTipsZDepth tag:GameSceneNodeTagText];
}

- (void) showPerfectSlide{
  [self showHint:@"perfect" Scale:1.2f Duration:1.0f Position:ccp(_screenW/2, _screenH/16)];
}

- (void) showHit {
  [self showHint:@"hit" Scale:1.2f Duration:1.0f Position:ccp(_screenW/2, _screenH/16)];
}

- (void) showFrenzy {
  [self showHint:@"CRAZY" Scale:1.4f Duration:2.0f Position:ccp(_screenW/2, _screenH/16)];
}

- (void) showTips {
  if( !![self getChildByTag:GameSceneNodeTagTips] ) return;
  CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:kTipsText] fontName:kTipsFontName fontSize:kTipsFontSize];
  label.position = ccp(_screenW/2, _screenH/2);
	[self addChild:label z:kTipsZDepth tag:GameSceneNodeTagTips];
}

- (void) hideTips{
  [self removeChildByTag:GameSceneNodeTagTips cleanup:YES];
}

/************** score saving ***************/
-(void)saveScore {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setInteger:score forKey:TEXT_HIGH_SCORE];
  [defaults synchronize];
//  CCLOG(@"saved high score %d", score);
}

-(int)highScore{
  return [[NSUserDefaults standardUserDefaults] integerForKey: TEXT_HIGH_SCORE];
}

@end
