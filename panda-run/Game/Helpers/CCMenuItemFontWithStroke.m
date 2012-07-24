//
//  CCMenuItemFontWithStroke.m
//  test2
//
//  Created by Robert Perry on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCMenuItemFontWithStroke.h"

@implementation CCMenuItemFontWithStroke

@synthesize stokeSize;
@synthesize strokeColor;

#define kTagStroke 1029384756

+(CCRenderTexture*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor
{
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width+size*2  height:label.texture.contentSize.height+size*2];
	CGPoint originalPos = [label position];
	ccColor3B originalColor = [label color];
	BOOL originalVisibility = [label visible];
	[label setColor:cor];
	[label setVisible:YES];
	ccBlendFunc originalBlend = [label blendFunc];
	[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
	CGPoint bottomLeft = ccp(label.texture.contentSize.width * label.anchorPoint.x + size, label.texture.contentSize.height * label.anchorPoint.y + size);
	//CGPoint positionOffset = ccp(label.texture.contentSize.width * label.anchorPoint.x - label.texture.contentSize.width/2,label.texture.contentSize.height * label.anchorPoint.y - label.texture.contentSize.height/2);
  //use this for adding stoke to its self...
  CGPoint positionOffset= ccp(-label.contentSize.width/2,-label.contentSize.height/2);
  
	CGPoint position = ccpSub(originalPos, positionOffset);
  
	[rt begin];
	for (int i=0; i<360; i+=30) // you should optimize that for your needs
	{
		[label setPosition:ccp(bottomLeft.x + sin(CC_DEGREES_TO_RADIANS(i))*size, bottomLeft.y + cos(CC_DEGREES_TO_RADIANS(i))*size)];
		[label visit];
	}
	[rt end];
	[label setPosition:originalPos];
	[label setColor:originalColor];
	[label setBlendFunc:originalBlend];
	[label setVisible:originalVisibility];
	[rt setPosition:position];
	return rt;
}

-(id) initFromString: (NSString*) value target:(id) rec selector:(SEL) cb  strokeSize:(int)strokeSize stokeColor:(ccColor3B)color
{
  
	self = [super initFromString:value target:rec selector:cb];
  
  self.strokeColor = color;
  self.stokeSize = strokeSize;
  
	if ([label_ isKindOfClass: [CCLabelTTF class]]) {
		CCRenderTexture * stroke  = [CCMenuItemFontWithStroke createStroke:(CCLabelTTF*)label_ size:strokeSize color:strokeColor];
		[self addChild:stroke z:-1 tag:kTagStroke];
	}else{
		NSLog(@"Error adding stroke in menu, label_ is not a CCLabelTTF.  This has only been tested on cocos2d 99.5");
	}
  
	return self;
}

//default 1 pixel, black
-(id) initFromString: (NSString*) value target:(id) rec selector:(SEL) cb {
  return [self initFromString:value target:rec selector:cb strokeSize:3 stokeColor:ccBLACK];
}

-(void) setString:(NSString *)string
{
	[super setString:string];
  
	if ([label_ isKindOfClass: [CCLabelTTF class]]) {
		[self removeChildByTag:kTagStroke cleanup:YES];
		CCRenderTexture * stroke  = [CCMenuItemFontWithStroke createStroke:(CCLabelTTF*)label_ size:stokeSize color:strokeColor];
		[self addChild:stroke z:-1 tag:kTagStroke];
    
	}else{
		NSLog(@"Error adding stroke in menu, label_ is not a CCLabelTTF.  This has only been tested on cocos2d 99.5");
	}
  
}

@end