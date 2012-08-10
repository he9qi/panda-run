//
//  Coin.h
//  panda-run
//
//  Created by Qi He on 12-6-29.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "TTConsumableItem.h"

#define kCoinScore 10
#define kPandaCoinMultiFactor 2

@interface Coin : TTConsumableItem

+ (id) coinWithGame:(Game*)game Position:(CGPoint)p;

@end
