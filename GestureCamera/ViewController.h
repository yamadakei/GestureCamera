//
//  ViewController.h
//  GestureCamera
//
//  Created by 山田 慶 on 2013/02/05.
//  Copyright (c) 2013年 山田 慶. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet GPUImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *flashButton;
@property (strong, nonatomic) IBOutlet UIView *transparentView;
@property (strong, nonatomic) IBOutlet UIButton *swipeView;
@property (strong, nonatomic) IBOutlet UIButton *levelButton;
@property (strong, nonatomic) IBOutlet UIButton *gridButton;

- (IBAction)showLevel:(id)sender;
- (IBAction)showGrid:(id)sender;

@end
