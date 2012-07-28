//
//  TerrainImageItem.h
//  panda-run
//
//  Created by Qi He on 12-7-25.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "TTImageItem.h"

@interface TerrainImageItem : TTImageItem

+ (id) itemWithImage:(NSString *)imageName Position:(CGPoint)p Angle:(float)angle;

@end
