//
//  Game.m
//  panda-run
//
//  Created by Qi He on 12-6-26.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Game.h"


@interface Game()
- (void) createBox2DWorld;    // create the physics world
- (void) deleteBox2DWorld;    // delete objects and world
- (void) createBox2DDebug;    // draw box2d world for debug
- (void) deleteBox2DDebug;    // remove debug
@end

@implementation Game

@synthesize screenW = _screenW;
@synthesize screenH = _screenH;
@synthesize world   = _world;
@synthesize sky     = _sky;

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
    
    
    // When this is called, the update method will be called every frame 
    // with the “delta time” as argument.
		[self scheduleUpdate];
	}
	return self;
}

- (void) createBox2DWorld {
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -9.8f);
	
	_world = new b2World(gravity, false);
  
}

- (void) deleteBox2DWorld {
  
	self.sky = nil;
  
	delete _world;
	_world = NULL;
}

- (void) update:(ccTime)dt {
  

}



- (void) dealloc {
  
  [self deleteBox2DDebug];
	[self deleteBox2DWorld];
	
	[super dealloc];
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
  //	flags += b2Draw::e_jointBit;
  //	flags += b2Draw::e_aabbBit;
  //	flags += b2Draw::e_pairBit;
  //	flags += b2Draw::e_centerOfMassBit;
	_render->SetFlags(flags);
	
#endif
}

@end
