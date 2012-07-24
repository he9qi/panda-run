//
//  Terrain.h
//  panda-run
//
//  Created by Qi He on 12-6-27.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

#define kMaxHillKeyPoints 30
#define kMaxHillVertices 2000
#define kMaxBorderVertices 10000
#define kHillSegmentWidth 15
#define kTemplePositionOffset 12

@interface Terrain : CCNode{
	
  // key points - turning points of hill
  ccVertex2F hillKeyPoints[kMaxHillKeyPoints];
	int nHillKeyPoints;
	int fromKeyPointI;
	int toKeyPointI;
  bool firstTime;
  
  // hill vertices
	ccVertex2F hillVertices[kMaxHillVertices];
	ccVertex2F hillTexCoords[kMaxHillVertices];
	int nHillVertices;
  
  // border vertices - actual collision
	ccVertex2F borderVertices[kMaxBorderVertices];
	int nBorderVertices;
  
  // sprite
	CCSprite *_sprite;
	
  // physics world
  b2World *world;
  
  // make terrain a physics body
	b2Body *body;
  
	int screenW;
	int screenH;
	int textureSize;
	float _offsetX;
}

@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic, assign) float offsetX;

+ (id) terrainWithWorld:(b2World*)w;
- (id) initWithWorld:(b2World*)w;

- (ccVertex2F)getBorderVerticeAt:(int)index;
- (ccVertex2F)getHillKeyPointAt:(int)index;
- (ccVertex2F)getTempleBorderVertice;

- (int) getTemplePostition;
- (bool)reachedEnd;
- (void)reset;

@end
