//
//  Menu.h
//  panda-run
//
//  Created by Qi He on 12-7-12.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "cocos2d.h"
#import "GLES-Render.h"

#define kMaxLeaves 3

@interface Menu : CCLayer {
  CCSprite *playButton;
	CCSprite *tipsButton;
	CCSprite *quitButton;
  
  CCSpriteBatchNode* batch;
  int nextInactiveLeaf;
	NSMutableArray *_leaves;
}

+ (CCScene*) scene;

@end
