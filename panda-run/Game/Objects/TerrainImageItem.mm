//
//  TerrainImageItem.m
//  panda-run
//
//  Created by Qi He on 12-7-25.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "TerrainImageItem.h"
#import "Box2DHelper.h"
#import "Terrain.h"
#import "Constants.h"

@implementation TerrainImageItem

+ (id) itemWithImage:(NSString *)imageName Position:(CGPoint)p Angle:(float)angle
{
  return [self itemWithImage:imageName Position:p Angle:angle Offset:TERRAIN_IMAGE_OFFSET_FACTOR];
}

+ (id) itemWithImage:(NSString *)imageName Position:(CGPoint)p Angle:(float)angle Offset:(float)offsetFactor
{
  CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:imageName];
  sprite.rotation = - angle * ANGLE_TO_DEGREE;
  
  float offset = [sprite boundingBox].size.height / offsetFactor;
  
  CGPoint newP = ccp(p.x, p.y+offset);
  return [[[self alloc] initWithSprite:sprite Position:newP] autorelease];
}

+ (TTImageItem *)createItemWithImage:(NSString *)imageName On:(CCNode *)terrain At:(int)index Offset:(float)offsetFactor
{
  ccVertex2F bp = [(Terrain*)terrain getBorderVerticeAt:index];
  CGPoint p = ccp(bp.x * [Box2DHelper pointsPerPixel], bp.y* [Box2DHelper pointsPerPixel]);
  
  b2Vec2 normal = [(Terrain*)terrain getBorderNormalAt:index];
  normal.Normalize();
  
  b2Vec2 vertical; vertical.x = 0; vertical.y = 1;
  float angle = b2Cross(normal, vertical);
  
  TerrainImageItem *tii = [TerrainImageItem itemWithImage:imageName Position:p Angle:angle Offset:offsetFactor];
  [terrain addChild:tii z:-1];
  
  return tii;
}

+ (TTImageItem *)createItemWithImage:(NSString *)imageName On:(CCNode *)terrain At:(int)index
{
  return [self createItemWithImage:imageName On:terrain At:index Offset:TERRAIN_IMAGE_OFFSET_FACTOR];
}

@end
