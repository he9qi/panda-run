//
//  OverView.h
//  panda-run
//
//  Created by Qi He on 12-8-4.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "cocos2d.h"

@interface OverView : CCLayer{
	CCMenuItemImage *tryAgainButton;
	CCMenuItemImage *menuButton;
  CCLabelTTF *scoreLabel;
  
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

@end
