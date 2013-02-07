//
//  LevelView.m
//  GestureCamera
//
//  Created by 山田 慶 on 2013/02/07.
//  Copyright (c) 2013年 山田 慶. All rights reserved.
//

#import "LevelView.h"

@implementation LevelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRectAccel:(CGRect)rect accelX:(NSInteger)x {
    
    UIBezierPath *topPath = [UIBezierPath bezierPath];
    [topPath moveToPoint:CGPointMake(0, 200)];
    [topPath addLineToPoint:CGPointMake(320, 200)];
    
    [[UIColor whiteColor] setStroke];
    
    [topPath stroke];
    
    UIBezierPath *topPath2 = [UIBezierPath bezierPath];
    [topPath2 moveToPoint:CGPointMake(0, 200-x)];
    [topPath2 addLineToPoint:CGPointMake(320, 200+x)];
    
    [[UIColor redColor] setStroke];
    
    [topPath2 stroke];
}

@end
