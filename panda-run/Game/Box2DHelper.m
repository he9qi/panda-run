//
//  Tiny Wings Remake
//  http://github.com/haqu/tiny-wings
//
//  Created by Sergey Tikhonov http://haqu.net
//  Released under the MIT License
//

#import "Box2DHelper.h"
#import "Constants.h"

@implementation Box2DHelper

+ (float) pointsPerMeter {
	return 32.0f;
}

+ (float) metersPerPoint {
	return 1.0f / [self pointsPerMeter];
}

+ (float) pointsPerPixel {
	return 1 / CC_CONTENT_SCALE_FACTOR();
}

+ (float) pixelsPerMeter {
	return [self pointsPerMeter] * CC_CONTENT_SCALE_FACTOR();
}

+ (float) metersPerPixel {
	return 1.0f / [self pixelsPerMeter];
}

+ (ccColor4F) randomColor {
	const int minSum = 450;
	const int minDelta = 150;
	int r, g, b, min, max;
	while (true) {
		r = arc4random()%256;
		g = arc4random()%256;
		b = arc4random()%256;
		min = MIN(MIN(r, g), b);
		max = MAX(MAX(r, g), b);
		if (max-min < minDelta) continue;
		if (r+g+b < minSum) continue;
		break;
	}
	return ccc4FFromccc3B(ccc3(r, g, b));
}

static CCSpriteBatchNode * spriteBatch;

+ (CCSpriteBatchNode *)getSpriteBatch{
  if ( !spriteBatch ){
    // create sprite sheet
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
    spriteBatch = [[CCSpriteBatchNode alloc] initWithFile:IMAGE_SPRITE capacity:50];
  }
  return spriteBatch;
}

@end
