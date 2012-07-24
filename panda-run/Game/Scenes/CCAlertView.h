//
//  CCAlertView.h
//  panda-run
//
//  Created by Qi He on 2/16/11.
//  Copyright 2011 __Heyook__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCAlertView : CCLayer {
	NSString *Message;
	NSString *SubMessage;
	NSString *Button1;
	NSString *Button2;
  
  CCSprite *alertViewSprite;
  
  CCLabelTTF *MessageLabel;
  CCLabelTTF *SubMessageLabel;
  CCMenuItemFont *OK;
  CCMenuItemFont *Cancel;
  
  id button1Target;
  SEL button1Selector;
  
  id button2Target;
  SEL button2Selector;
  
}

@property (nonatomic, retain) NSString *Message;
@property (nonatomic, retain) NSString *SubMessage;
@property (nonatomic, retain) NSString *Button1;
@property (nonatomic, retain) NSString *Button2;
@property (nonatomic, retain) id button1Target;
@property (nonatomic) SEL button1Selector;
@property (nonatomic, retain) id button2Target;
@property (nonatomic) SEL button2Selector;

@end