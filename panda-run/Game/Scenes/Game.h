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

#define kVelocityIterations 8
#define kPositionIterations 3
#define kMaxCoins 101
#define kMaxWoods 101

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
}

@property (readonly) int screenW;
@property (readonly) int screenH;
@property (nonatomic, readonly) b2World *world;
@property (nonatomic, retain) Sky *sky;
@property (nonatomic, retain) Terrain *terrain;
@property (nonatomic, retain) Panda *panda;
@property (nonatomic, copy  ) NSMutableArray  *coins;
@property (nonatomic, copy  ) NSMutableArray  *woods;


+ (CCScene*) scene;

@end
