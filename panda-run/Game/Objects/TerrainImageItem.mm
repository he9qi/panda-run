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
  CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:imageName];
  sprite.rotation = - angle * 180 / M_PI;
  
  
  //TODO: offset is different for different image, will find a better way!
  float offset = [sprite boundingBox].size.height / 20.0f;
  
  if( ![imageName isEqualToString:IMAGE_GRASS] ){
    offset += [sprite boundingBox].size.height / 2.0f;
  }
  
  CGPoint newP = ccp(p.x, p.y+offset);
  return [[[self alloc] initWithSprite:sprite Position:newP] autorelease];
}

+ (TTImageItem *)createItemWithImage:(NSString *)imageName On:(CCNode *)terrain At:(int)index
{
  ccVertex2F bp = [(Terrain*)terrain getBorderVerticeAt:index];
  CGPoint p = ccp(bp.x * [Box2DHelper pointsPerPixel], bp.y* [Box2DHelper pointsPerPixel]);
  
  b2Vec2 normal = [(Terrain*)terrain getBorderNormalAt:index];
  normal.Normalize();
  
  b2Vec2 vertical; vertical.x = 0; vertical.y = 1;
  float angle = b2Cross(normal, vertical);
  
  TerrainImageItem *tii = [TerrainImageItem itemWithImage:imageName Position:p Angle:angle];
  [terrain addChild:tii z:-1];
  
  return tii;
}

@end
