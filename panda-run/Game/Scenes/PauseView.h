//
//  PauseView.h
//  panda-run
//
//  Created by Qi He on 12-8-4.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "cocos2d.h"

@interface PauseView : CCLayer{
	CCMenuItemImage *resumeButton;
	CCMenuItemImage *restartButton;
	CCMenuItemImage *menuButton;
	CCMenuItemImage *quitButton;
  
  CCSprite *viewSprite;
  
  id resumeButtonTarget;
  SEL resumeButtonSelector;
  
  id restartButtonTarget;
  SEL restartButtonSelector;
  
  id menuButtonTarget;
  SEL menuButtonSelector;
  
  id quitButtonTarget;
  SEL quitButtonSelector;
}

@property (nonatomic, retain) id resumeButtonTarget;
@property (nonatomic) SEL resumeButtonSelector;
@property (nonatomic, retain) id restartButtonTarget;
@property (nonatomic) SEL restartButtonSelector;
@property (nonatomic, retain) id menuButtonTarget;
@property (nonatomic) SEL menuButtonSelector;
@property (nonatomic, retain) id quitButtonTarget;
@property (nonatomic) SEL quitButtonSelector;

@end
