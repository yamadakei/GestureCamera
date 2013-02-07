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

- (void)drawRect:(CGRect)rect{
    
    UIBezierPath *topPath = [UIBezierPath bezierPath];
    [topPath moveToPoint:CGPointMake(0, 200)];
    [topPath addLineToPoint:CGPointMake(320, 200)];
    
    [[UIColor whiteColor] setStroke];
    
    [topPath stroke];
}

- (void)drawRectAccel:(CGRect)rect accel:(CGFloat)accel {
    
    UIBezierPath *topPath = [UIBezierPath bezierPath];
    [topPath moveToPoint:CGPointMake(0, 200-accel*10)];
    [topPath addLineToPoint:CGPointMake(320, 200+accel*10)];
    
    [[UIColor redColor] setStroke];
    
    [topPath stroke];
}


@end
