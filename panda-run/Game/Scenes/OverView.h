//
//  OverView.h
//  panda-run
//
//  Created by Qi He on 12-8-4.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "cocos2d.h"

static const ccColor3B ccScore = {255, 124, 5};
static const ccColor3B ccHighScore = {190,120,120};

@interface OverView : CCLayer{
	CCMenuItemImage *tryAgainButton;
	CCMenuItemImage *menuButton;
  CCLabelTTF *scoreLabel;
  CCLabelTTF *highScoreLabel;
  
  CCSprite *viewSprite;
  
  id tryAgainButtonTarget;
  SEL tryAgainButtonSelector;

  id menuButtonTarget;
  SEL menuButtonSelector;
}

@property (nonatomic, retain) id tryAgainButtonTarget;
@property (nonatomic) SEL tryAgainButtonSelector;
@property (nonatomic, retain) id menuButtonTarget;
@property (nonatomic) SEL menuButtonSelector;

- (void)setScore:(int)score;
- (void)setHighScore:(int)score;

@end
