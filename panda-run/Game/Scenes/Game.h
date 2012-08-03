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
#import "Sky.h"
#import "Terrain.h"
#import "Panda.h"
#import "Coin.h"
#import "BreakableWood.h"
#import "Bridge.h"
#import "Water.h"
#import "Mud.h"
#import "Hill.h"
#import "Temple.h"
#import "Energy.h"
#import "Bush.h"

#define kVelocityIterations 8
#define kPositionIterations 3

#define kMaxCloud 3
#define kMaxCoins 101
#define kMaxEnergies 101

#define kTemplePositionYOffset 38.0f

typedef enum
{
	GameSceneNodeTagLeaf = 1,
	GameSceneNodeTagCloud,
	GameSceneNodeTagSky,
	GameSceneNodeTagSpritesBatch,
	
} GameSceneNodeTags;

@interface Game : CCLayer{
  int _screenW;             //screen width
	int _screenH;             //screen height
	b2World *_world;          //physics world
	GLESDebugDraw *_render;   //debug
  
	Sky *_sky;
	Terrain *_terrain;
  Panda *_panda;
  
	NSMutableArray *_coins;
	NSMutableArray *_woods;
	NSMutableArray *_energies;
	NSMutableArray *_bushes;
	NSMutableArray *_trees;
	NSMutableArray *_grasses;
	NSMutableArray *_clouds;
  
  Water *_water;
  Mud *_mud;
  Hill *_hill;
  Temple *_temple;
}

@property (readonly) int screenW;
@property (readonly) int screenH;
@property (nonatomic, readonly) b2World *world;
@property (nonatomic, retain) Sky *sky;
@property (nonatomic, retain) Terrain *terrain;
@property (nonatomic, retain) Panda *panda;
@property (nonatomic, retain) Mud *mud;
@property (nonatomic, retain) Hill *hill;
@property (nonatomic, copy  ) NSMutableArray  *coins;
@property (nonatomic, copy  ) NSMutableArray  *woods;
@property (nonatomic, copy  ) NSMutableArray  *energies;
@property (nonatomic, copy  ) NSMutableArray  *bushes;
@property (nonatomic, copy  ) NSMutableArray  *trees;
@property (nonatomic, copy  ) NSMutableArray  *grasses;
@property (nonatomic, copy  ) NSMutableArray  *clouds;


+ (CCScene*) scene;
- (void)pause;
- (void)resume;
- (void)over;

- (void) onAlertButtonOK:(id) alertView;

@end
