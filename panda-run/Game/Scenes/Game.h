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

@interface Game : CCLayer{
  int _screenW;             //screen width
	int _screenH;             //screen height
	b2World *_world;          //physics world
	GLESDebugDraw *_render;   //debug
  
	Sky *_sky;
}

@property (readonly) int screenW;
@property (readonly) int screenH;
@property (nonatomic, readonly) b2World *world;
@property (nonatomic, retain) Sky *sky;


+ (CCScene*) scene;

@end
