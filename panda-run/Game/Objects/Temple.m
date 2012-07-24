//
//  Temple.m
//  panda-run
//
//  Created by Qi He on 12-7-22.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Temple.h"
#import "Constants.h"

@implementation Temple

+ (id) templeWithPosition:(CGPoint)p{
	return [[[self alloc] initWithSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_TEMPLE] Position:p] autorelease];
}

@end
