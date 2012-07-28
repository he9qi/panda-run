//
//  Hill.m
//  panda-run
//
//  Created by Qi He on 12-7-21.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Hill.h"
#import "Constants.h"

@implementation Hill

+ (id) hillWithTextureSize:(int)ts {
	return [[[self alloc] initWithTexture:[CCSprite spriteWithFile:IMAGE_HILL] Size:ts Color:(ccColor3B){255,255,255}] autorelease];
}

@end
