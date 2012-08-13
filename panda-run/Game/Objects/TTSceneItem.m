//
//  TTSceneItem.m
//  panda-run
//
//  Created by Qi He on 12-7-22.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "TTSceneItem.h"

@interface TTSceneItem()
- (CCSprite*) generateSprite;
- (CCTexture2D*) generateTexture;
@end

@implementation TTSceneItem

@synthesize scale   = _scale;
@synthesize sprite  = _sprite;
@synthesize offsetX = _offsetX;

+ (id) itemWithTexture:(CCSprite *)sprite Size:(int)ts Color:(ccColor3B)color{
	return [[[self alloc] initWithTexture:sprite Size:ts Color:color] autorelease];
}

- (id) initWithTexture:(CCSprite *)sprite Size:(int)ts Color:(ccColor3B)color{
	
	if ((self = [super init])) {
		
		textureSize = ts;
    
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		screenW = screenSize.width;
		screenH = screenSize.height;
		
    _innerSprite = sprite;
    _color       = color;
    
    self.sprite = sprite;
    _sprite.position = ccp(0, screenH/4);
    _sprite.anchorPoint = ccp(0, 0.5);
		_sprite.scale = CC_CONTENT_SCALE_FACTOR(); //remove this if we have HD version of the image
//    self.sprite  = [self generateSprite];
    
		[self addChild:_sprite];
		
	}
	return self;
}

- (void) dealloc {
	self.sprite = nil;
  _innerSprite = nil;
	[super dealloc];
}

- (CCSprite*) generateSprite {
	
	CCTexture2D *texture = [self generateTexture];
	
	float w = (float)screenW/(float)screenH*textureSize;
	float h = textureSize;
	CGRect rect = CGRectMake(0, 0, w, h);
	
	CCSprite *sprite = [CCSprite spriteWithTexture:texture rect:rect];
	ccTexParams tp = {GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT};
	[sprite.texture setTexParameters:&tp];
	sprite.anchorPoint = ccp(0, 0);
	sprite.flipY = YES;
  
	return sprite;
}

- (void) renderNoise{
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
	
	[_innerSprite setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
	_innerSprite.position = ccp(textureSize/2, textureSize/2);
	_innerSprite.scale = CC_CONTENT_SCALE_FACTOR();
  
	glColor4f(1,1,1,0);
	glLineWidth(0.0f);
  
	[_innerSprite visit];
}

- (CCTexture2D*) generateTexture {
  
	CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize height:textureSize];
	
  //sky color
	ccColor4F cf = ccc4FFromccc3B(_color);
	
	[rt beginWithClear:cf.r g:cf.g b:cf.b a:cf.a];
  
  [self renderNoise];
	
	[rt end];
	
	return rt.sprite.texture;
}

- (void) setOffsetX:(float)offsetX {
	if (_offsetX != offsetX) {
		_offsetX = offsetX;
		CGSize size = _sprite.textureRect.size;
		_sprite.textureRect = CGRectMake(_offsetX, 0, size.width, size.height);
	}
}

- (void) setScale:(float)scale {
	if (_scale != scale) {
		const float minScale = (float)screenH / (float)textureSize;
		if (scale < minScale) {
			_scale = minScale;
		} else {
			_scale = scale;
		}
		_sprite.scale = _scale * CC_CONTENT_SCALE_FACTOR();
	}
}

@end
