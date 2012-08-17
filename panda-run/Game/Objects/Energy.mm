//
//  Energy.m
//  panda-run
//
//  Created by Qi He on 12-7-24.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Energy.h"
#import "UserData.h"
#import "Constants.h"
#import "Box2DHelper.h"
#import "Game.h"
#import "Terrain.h"

@implementation Energy

+ (id) energyWithGame:(Game*)game Position:(CGPoint)p{
  [Box2DHelper getSpriteBatch];
	return [[[self alloc] initWithGame:game Sprite:[CCSprite spriteWithSpriteFrameName:IMAGE_ENERGY] Radius:RADIUS_ENERGY Position:p] autorelease];
}

+ (TTConsumableItem *)createItemTo:(Game *)game On:(Terrain *)terrain At:(int)index{
  ccVertex2F bp = [terrain getHillKeyPointAt:index];
  CGPoint p = ccp(bp.x * [Box2DHelper pointsPerPixel], bp.y* [Box2DHelper pointsPerPixel] +kEnergiesPositionYOffset);
  
  Energy *energy = [Energy energyWithGame:game Position:p];
  [terrain addChild:energy];
  
  return energy;
}

@end
