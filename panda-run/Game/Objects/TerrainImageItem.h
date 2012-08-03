//
//  TerrainImageItem.h
//  panda-run
//
//  Created by Qi He on 12-7-25.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "TTImageItem.h"

#define TERRAIN_IMAGE_OFFSET_FACTOR 5.0f


@interface TerrainImageItem : TTImageItem

+ (id) itemWithImage:(NSString *)imageName Position:(CGPoint)p Angle:(float)angle;
+ (id) itemWithImage:(NSString *)imageName Position:(CGPoint)p Angle:(float)angle Offset:(float)offsetFactor;

+ (TTImageItem *)createItemWithImage:(NSString *)imageName On:(CCNode *)terrain At:(int)index Offset:(float)offsetFactor;

@end
