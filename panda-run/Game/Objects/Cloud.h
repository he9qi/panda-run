//
//  Cloud.h
//  panda-run
//
//  Created by Qi He on 12-8-1.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "TTSpriteItem.h"

@interface Cloud : TTSpriteItem

+ (Cloud *)createCloud;
+ (NSMutableArray *) createCloudsTo:(CCNode *)node Count:(int)count Z:(NSInteger)z Tag:(NSInteger)tag;

@end
