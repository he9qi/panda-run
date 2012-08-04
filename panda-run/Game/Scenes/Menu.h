//
//  Menu.h
//  panda-run
//
//  Created by Qi He on 12-7-12.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "cocos2d.h"
#import "GLES-Render.h"

@interface Menu : CCLayer {
  CCMenuItemImage *playButton;
	CCMenuItemImage *tipsButton;
	CCMenuItemImage *quitButton;
  CCSpriteBatchNode* batch;
}

+ (CCScene*) scene;

@end
