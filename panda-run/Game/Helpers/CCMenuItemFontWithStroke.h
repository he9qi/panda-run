//
//  CCMenuItemFontWithStroke.h
//  test2
//
//  Created by Robert Perry on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCMenuItemFontWithStroke : CCMenuItemFont  {
  int stokeSize;
  ccColor3B strokeColor;
  
}

@property (nonatomic) int stokeSize;
@property (nonatomic)ccColor3B strokeColor;

-(id) initFromString: (NSString*) value target:(id) rec selector:(SEL) cb  strokeSize:(int)strokeSize stokeColor:(ccColor3B)color;

@end