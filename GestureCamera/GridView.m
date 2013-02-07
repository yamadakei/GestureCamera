//
//  GridView.m
//  GestureCamera
//
//  Created by 山田 慶 on 2013/02/07.
//  Copyright (c) 2013年 山田 慶. All rights reserved.
//

#import "GridView.h"

@implementation GridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    int xStart = 0, yStart = 0;
    int gridSizeX = 480;
    int gridSizeY = 480;
    
    UIBezierPath *topPath = [UIBezierPath bezierPath];
    // draw vertical lines
    for(int xId=1; xId<=5; xId++) {
        int x = xStart + xId * gridSizeX / 9;
        [topPath moveToPoint:CGPointMake(x, yStart)];
        [topPath addLineToPoint:CGPointMake(x, yStart+gridSizeX)];
    }
    
    // draw horizontal lines
    for(int yId=1; yId<=12; yId++) {
        int y = yStart + yId * gridSizeY / 9;
        [topPath moveToPoint:CGPointMake(xStart, y)];
        [topPath addLineToPoint:CGPointMake(xStart+gridSizeY, y)];
    }
    
    [[UIColor whiteColor] setStroke];
    
    [topPath stroke];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
