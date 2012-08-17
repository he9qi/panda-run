//
//  Game.h
//  panda-run
//
//  Created by Qi He on 12-6-26.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

#import "CCLayer+Dimmable.h"
#import "TTStatableGame.h"

#define kVelocityIterations 8
#define kPositionIterations 3

#define kMaxCloud 3
#define kMaxCoins 101
#define kMaxEnergies 101
#define kMaxLeaves 3

#define kLeafZDepth 1
#define kTerrainZDepth 2
#define kMenuZDepth 1001
#define kDimColorZDepth 1000

#define kPauseButtonPadding 8
#define kScoreLabelPadding 30

#define kHillOffsetFactor 0.0035f
#define kSkyOffsetFactor 0.0035f
#define kHillScaleFactor 0.2f
#define kSkyScaleFactor 0.2f

#define kCloudScaleFactor 0.015f
#define kTempleGrassLength 4
#define kTempleCoinsLength 30

@class Sky;
@class Terrain;
@class Panda;
@class Coin;
@class BreakableWood;
@class Bridge;
@class Water;
@class Mud;
@class Hill;
@class Energy;
@class Bush;
@class Waves;

typedef enum
{
	GameSceneNodeTagLeaf = 1,
	GameSceneNodeTagCloud,
	GameSceneNodeTagSky,
	GameSceneNodeTagSpritesBatch,
  GameSceneNodeTagTips,
  GameSceneNodeTagFire,
  GameSceneNodeTagShadow,
	GameSceneNodeTagTerrain,
  GameSceneNodeTagRain,
  GameSceneNodeTagText,
	
} GameSceneNodeTags;

@interface Game : TTStatableGame{
  int _screenW;             //screen width
	int _screenH;             //screen height
	b2World *_world;          //physics world
	GLESDebugDraw *_render;   //debug
  
	Sky *_sky;
	Terrain *_terrain;
  Panda *_panda;
  
	NSMutableArray *_coins;
	NSMutableArray *_energies;
	NSMutableArray *_clouds;
  
  NSMutableArray *_bushes;
	NSMutableArray *_trees;
	NSMutableArray *_grasses;
	NSMutableArray *_woods;
  
  Water *_water;
  Mud *_mud;
  Hill *_hill;
  
  CCMenuItemImage *pauseButton;
  CCLayerColor* colorLayer;
  
  int score;
  CCLabelTTF *scoreLabel;
  
  CCParticleSystem* _rainSystem;
  CCParticleSystem* _fireSystem;
  
  Waves *_waves;
}

@property (readonly) int screenW;
@property (readonly) int screenH;
@property (nonatomic, readonly) b2World *world;
@property (nonatomic, retain) Sky *sky;
@property (nonatomic, retain) Terrain *terrain;
@property (nonatomic, retain) Panda *panda;
@property (nonatomic, retain) Mud *mud;
@property (nonatomic, retain) Hill *hill;
@property (nonatomic, retain) Waves *waves;
@property (nonatomic, copy  ) NSMutableArray  *coins;
@property (nonatomic, copy  ) NSMutableArray  *woods;
@property (nonatomic, copy  ) NSMutableArray  *energies;
@property (nonatomic, copy  ) NSMutableArray  *bushes;
@property (nonatomic, copy  ) NSMutableArray  *trees;
@property (nonatomic, copy  ) NSMutableArray  *grasses;
@property (nonatomic, copy  ) NSMutableArray  *clouds;


+ (CCScene*) scene;

- (void) incScore:(int)score;
- (void) showHit;
- (void) showPerfectSlide;
- (void) showFrenzy;

@end
