//
//  TTImageItem.m
//  panda-run
//
//  Created by Qi He on 12-7-22.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//


#import "TTImageItem.h"
#import "Constants.h"

@implementation TTImageItem

@synthesize sprite = _sprite;

+ (id) itemWithSprite:(CCSprite *)sprite Position:(CGPoint)p{
	return [[[self alloc] initWithSprite:sprite Position:p] autorelease];
}

- (id) initWithSprite:(CCSprite *)sprite Position:(CGPoint)p{
	
	if ((self = [super init])) {
    
    self.position = p;
		
    //#ifndef DRAW_BOX2D_WORLD
		self.sprite = sprite;
		[self addChild:_sprite];
    //#endif
    
	}
	return self;
}

+ (TTImageItem *)createItemOn:(CCNode *)terrain At:(int)index
{
  return nil;
}

+ (TTImageItem *)createItemWithImage:(NSString *)imageName On:(CCNode *)terrain At:(int)index
{
  return nil;
}

- (void) dealloc {
  
	//#ifndef DRAW_BOX2D_WORLD
	self.sprite = nil;
  //#endif
  
	[super dealloc];
}

@end
