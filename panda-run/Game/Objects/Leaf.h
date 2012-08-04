//
//  Leaf.h
//  panda-run
//
//  Created by Qi He on 12-8-4.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "TTSpriteItem.h"

@interface Leaf : TTSpriteItem

+ (Leaf *)createLeaf;
+ (NSMutableArray *) createLeavesTo:(CCNode *)batch Count:(int)count Z:(NSInteger)z Tag:(NSInteger)tag;

@end
