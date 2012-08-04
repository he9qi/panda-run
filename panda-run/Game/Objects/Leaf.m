//
//  Leaf.m
//  panda-run
//
//  Created by Qi He on 12-8-4.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Leaf.h"
#import "Constants.h"

@implementation Leaf

+ (Leaf *) createLeaf {
  return (Leaf *)[TTSpriteItem createSpriteItemWithName:IMAGE_LEAF];
}

+ (NSMutableArray *) createLeavesTo:(CCNode *)batch Count:(int)count Z:(NSInteger)z Tag:(NSInteger)tag{
  // Create a number of leaves up front and re-use them whenever necessary.
  NSMutableArray *items = [[[NSMutableArray alloc] init] autorelease];
  
  for (int i = 0; i < count; i++){
    Leaf* si = [Leaf createLeaf];
    [batch addChild:si z:z tag:tag];
    [si start];
    
    [items addObject:si];
  }
  
  return items;
}

@end
