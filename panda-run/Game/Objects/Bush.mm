//
//  Bush.m
//  panda-run
//
//  Created by Qi He on 12-7-25.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Bush.h"
#import "Terrain.h"
#import "Constants.h"
#import "Game.h"
#import "Box2DHelper.h"

@implementation Bush

+ (id)bushWithPosition:(CGPoint)p {
  return [[[self alloc] initWithSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUSH] Position:p] autorelease];
}

+ (TTImageItem *)createItemOn:(CCNode *)terrain At:(int)index{
  ccVertex2F bp = [(Terrain*)terrain getBorderVerticeAt:index];
  CGPoint p = ccp(bp.x * [Box2DHelper pointsPerPixel], bp.y* [Box2DHelper pointsPerPixel] + kBushPositionYOffset);
  
  Bush *bush = [Bush bushWithPosition:p];
  [terrain addChild:bush z:-1];
  
  return bush;
}

@end
