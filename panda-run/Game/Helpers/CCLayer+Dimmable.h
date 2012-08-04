//
//  CCLayer+Dimmable.h
//  panda-run
//
//  Created by Qi He on 12-8-4.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "CCLayer.h"

#define kDimColorZDepth 1000
#define kDimColorTag 9797

@interface CCLayer (Dimmable)

- (BOOL)isDimmed;
- (void)dim;
- (void)light;

@end
