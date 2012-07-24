//
//  Energy.h
//  panda-run
//
//  Created by Qi He on 12-7-24.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "TTConsumableItem.h"

#define kEnergiesPositionYOffset 15.0f

@interface Energy : TTConsumableItem

+ (id) energyWithGame:(Game*)game Position:(CGPoint)p;

@end