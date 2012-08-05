//
//  CCLayer+Dimmable.m
//  panda-run
//
//  Created by Qi He on 12-8-4.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "CCLayer+Dimmable.h"

@implementation CCLayer (Dimmable)

- (BOOL)isDimmed{
  return !![self getChildByTag:kDimColorTag];
}

- (void)dim{
  if ([self isDimmed]) return;
  CCLayerColor *colorLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
  [colorLayer setOpacity:175];
  [self addChild:colorLayer z:kDimColorZDepth tag:kDimColorTag];
}

- (void)light{
  [self removeChildByTag:kDimColorTag cleanup:YES];
}

@end
