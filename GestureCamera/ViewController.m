//
//  ViewController.m
//  GestureCamera
//
//  Created by 山田 慶 on 2013/02/05.
//  Copyright (c) 2013年 山田 慶. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMotion/CoreMotion.h>
#import "GridView.h"
#import "LevelView.h"

@interface ViewController ()
{
    GPUImageStillCamera *stillCamera;
    GPUImageWhiteBalanceFilter *whiteBalance;
    GPUImageBrightnessFilter *blightness;
    GPUImageFilterGroup *filterGroup;
    GPUImageCropFilter *crop;
    GPUImageFilter *firstFilter;
    GPUImageFilter *endFilter;
    
    NSInteger flashFlag;
    NSInteger gridFlag;
    NSInteger levelFlag;
    CGAffineTransform currentTransForm;
    CGAffineTransform pinchTransform;
    
    GridView *gridView;
    LevelView *levelView;
    LevelView *levelViewAccel;
    
}

@end

@implementation ViewController

#pragma mark - LifeCycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    flashFlag = 0;
    gridFlag = 0;
    levelFlag = 0;
    
    [self.flashButton setImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
    
    // setting for stiilCamera
    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    // 保存される画像はPortrait
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    // フィルターの設定
    //// まずフィルターグループを作る。フィルターを一つにまとめることで、あとで画像をつくるときに全部のフィルターがかかった画像が得られる
    filterGroup = [[GPUImageFilterGroup alloc] init];
    
    firstFilter = [[GPUImageWhiteBalanceFilter alloc] init];
    endFilter = [[GPUImageWhiteBalanceFilter alloc] init];
    whiteBalance = [[GPUImageWhiteBalanceFilter alloc] init];
    blightness = [[GPUImageBrightnessFilter alloc] init];
    crop = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0.125f, 1.0f, 0.75f)];
    
    [filterGroup addFilter:firstFilter];
    [filterGroup addFilter:whiteBalance];
    [filterGroup addFilter:blightness];
    [filterGroup addFilter:endFilter];
    
    [stillCamera addTarget:firstFilter];
    [firstFilter addTarget:whiteBalance];
    [whiteBalance addTarget:blightness];
    [blightness addTarget:endFilter];
    [endFilter addTarget:self.imageView];
    
    [filterGroup setInitialFilters:@[firstFilter]];
    [filterGroup setTerminalFilter:endFilter];
    
    [whiteBalance setTemperature:5000];
    [blightness setBrightness:-0.5];

    [stillCamera startCameraCapture];
    

    
    [self addGestureRecognizersToPiece];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addGestureRecognizersToPiece{
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGesture:)];
    UILongPressGestureRecognizer *twoFingersLongPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleTwoFingersLongPressGesture:)];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    UIPinchGestureRecognizer* pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    UITapGestureRecognizer* twoFingerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTapGesture:)];
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    
    tapGesture.numberOfTapsRequired = 1;
    
    doubleTapGesture.numberOfTapsRequired = 2;
    
    longPressGesture.allowableMovement = 100;
    longPressGesture.minimumPressDuration = 0.9f;
    longPressGesture.numberOfTapsRequired = 0;
    
    twoFingersLongPressGesture.allowableMovement = 100;
    twoFingersLongPressGesture.minimumPressDuration = 0.9f;
    twoFingersLongPressGesture.numberOfTapsRequired = 0;
    twoFingersLongPressGesture.numberOfTouchesRequired = 2;
    
    twoFingerTapGesture.numberOfTouchesRequired = 2;
    
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    
    [self.imageView addGestureRecognizer:longPressGesture];
    [self.imageView addGestureRecognizer:twoFingersLongPressGesture];
    [self.imageView addGestureRecognizer:panGesture];
    [self.imageView addGestureRecognizer:tapGesture];
    [self.imageView addGestureRecognizer:doubleTapGesture];
    [self.imageView addGestureRecognizer:twoFingerTapGesture];
    [self.view addGestureRecognizer:pinchGesture];
    [self.swipeView addGestureRecognizer:swipeGesture];
    
}


#pragma mark - Gesture Methods

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:.2 delay:.2 options:UIViewAnimationTransitionNone animations:^{
        if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
            
            [self.swipeView setTransform:CGAffineTransformMakeTranslation(0, -40.0)];
            [self.levelButton setTransform:CGAffineTransformMakeTranslation(0, -40.0)];
            [self.gridButton setTransform:CGAffineTransformMakeTranslation(0, -40.0)];
        }else if (recognizer.direction == UISwipeGestureRecognizerDirectionDown){
            [self.swipeView setTransform:CGAffineTransformMakeTranslation(0,0)];
            [self.levelButton setTransform:CGAffineTransformMakeTranslation(0,0)];
            [self.gridButton setTransform:CGAffineTransformMakeTranslation(0,0)];
        }
    } completion:^(BOOL finished) {
        if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
            recognizer.direction = UISwipeGestureRecognizerDirectionDown;
        }else{
            recognizer.direction = UISwipeGestureRecognizerDirectionUp;
        }
    }];
}

- (void) handlePinchGesture:(UIPinchGestureRecognizer*) sender {
//    UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)sender;
    // ピンチジェスチャー発生時に、Imageの現在のアフィン変形の状態を保存する
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        currentTransForm = self.transparentView.transform;
        // currentTransFormは、フィールド変数。imgViewは画像を表示するUIImageView型のフィールド変数。
    }
    CGFloat scale = [(UIPinchGestureRecognizer *)sender scale];
    
    //以前のピンチした時の拡大率と現在ピンチでとれた拡大率を掛け合わしたTransform
    //
    CGAffineTransform transform = CGAffineTransformConcat(currentTransForm,CGAffineTransformMakeScale(scale, scale));
    if ( transform.a < 1.0){
        transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
    self.transparentView.transform = transform;
    pinchTransform = transform;
}

- (void) handleTapGesture:(UITapGestureRecognizer*)sender {
    NSLog(@"tap");
    UITapGestureRecognizer* tap = (UITapGestureRecognizer*) sender;
    CGPoint location = [tap locationInView:self.imageView];
    CGSize viewSize = self.view.bounds.size;
    CGPoint pointOfInterest = CGPointMake(location.y / viewSize.height,1.0 - location.x / viewSize.width);
    NSError *error = nil;
    if ([stillCamera.inputCamera lockForConfiguration:&error]) {
        if ([stillCamera.inputCamera isFocusPointOfInterestSupported] &&
            [stillCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            stillCamera.inputCamera.focusPointOfInterest = pointOfInterest;
            stillCamera.inputCamera.focusMode = AVCaptureFocusModeAutoFocus;
        }
    }
    
}

- (void) handleDoubleTapGesture:(UITapGestureRecognizer*)sender {
    NSLog(@"doubletap");
    UITapGestureRecognizer* tap = (UITapGestureRecognizer*) sender;
    CGPoint location = [tap locationInView:self.imageView];
    CGSize viewSize = self.view.bounds.size;
    CGPoint pointOfInterest = CGPointMake(location.y / viewSize.height,1.0 - location.x / viewSize.width);
    NSError *error = nil;
    if ([stillCamera.inputCamera lockForConfiguration:&error]) {
        if ([stillCamera.inputCamera isFocusPointOfInterestSupported] &&
            [stillCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeLocked]) {
            stillCamera.inputCamera.focusPointOfInterest = pointOfInterest;
            stillCamera.inputCamera.focusMode = AVCaptureFocusModeLocked;
        }
    }

}

- (void) handlePanGesture:(UIPanGestureRecognizer*) sender {
    UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*) sender;
    CGPoint location = [pan translationInView:self.imageView];
    [whiteBalance setTemperature:location.x * 15.625+2500];
    [blightness setBrightness:location.y * 0.0036 * -1 - 0.5];
}


- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)sender
{
    if ([sender state] == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
    }else if([sender state] == UIGestureRecognizerStateEnded){
        NSLog(@"UIGestureRecognizerStateEnded");
        // 指定したFilterがかかった、画像が取得できる。そのために、プロパティでfilterをもたせている。
        [stillCamera capturePhotoAsImageProcessedUpToFilter:filterGroup withCompletionHandler:^(UIImage *processedImage, NSError *error){
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            
            [library writeImageToSavedPhotosAlbum:processedImage.CGImage
                                         metadata:nil
                                  completionBlock:^(NSURL *assetURL, NSError *error){
                                      if (!error) {
                                          NSLog(@"保存成功！");
                                      }
                                  }
             ];
        }];
    }
}

- (void) handleTwoFingersLongPressGesture:(UILongPressGestureRecognizer*)sender
{
    NSLog(@"%f",pinchTransform.a);
    if ([sender state] == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
    }else if([sender state] == UIGestureRecognizerStateEnded){
    if (pinchTransform.a > 1.f) {
        NSLog(@"UIGetScreenImage");
        CGImageRef imageRef = UIGetScreenImage();
        UIImage* proseccedImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        CGFloat width = 320;
        CGFloat height = 568;
        
        UIImage *finalImage = [[UIImage alloc]init];
        
        CGRect rect = CGRectMake(200, 200, 320, 320);
        
        UIGraphicsBeginImageContext(rect.size);
        [proseccedImage drawInRect:CGRectMake(0, -142, width, height)];
        finalImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        [stillCamera capturePhotoAsImageProcessedUpToFilter:filterGroup withCompletionHandler:^(UIImage *processedImage, NSError *error){
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            
            [library writeImageToSavedPhotosAlbum:finalImage.CGImage
                                         metadata:nil
                                  completionBlock:^(NSURL *assetURL, NSError *error){
                                      if (!error) {
                                          NSLog(@"保存成功！");
                                      }
                                  }
             ];
        }];    }else{
    GPUImageFilterGroup* filterGroupForCrop = [[GPUImageFilterGroup alloc] init];
    
    [filterGroupForCrop addTarget:filterGroup];
    [filterGroup addTarget:crop];

    
    [filterGroupForCrop setInitialFilters:@[firstFilter]];
    [filterGroupForCrop setTerminalFilter:crop];
    
        [stillCamera capturePhotoAsImageProcessedUpToFilter:filterGroupForCrop withCompletionHandler:^(UIImage *processedImage, NSError *error){
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            
            [library writeImageToSavedPhotosAlbum:processedImage.CGImage
                                         metadata:nil
                                  completionBlock:^(NSURL *assetURL, NSError *error){
                                      if (!error) {
                                          NSLog(@"保存成功！");
                                          [blightness removeTarget:crop];
                                          [blightness addTarget:endFilter];
                                          [endFilter addTarget:self.imageView];
                                      }
                                  }
             ];
        }];
    }
    }
    

}

- (void) handleTwoFingerTapGesture:(UITapGestureRecognizer*)sender
{
    NSLog(@"2fingers");
    NSError *error = nil;
    if ([stillCamera.inputCamera lockForConfiguration:&error]) {
        if (flashFlag == 0) {
            [stillCamera.inputCamera setFlashMode:AVCaptureFlashModeOn];
            flashFlag = 1;
            [self.flashButton setImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateNormal];
        }else if (flashFlag == 1){
            [stillCamera.inputCamera setFlashMode:AVCaptureFlashModeOff];
            flashFlag = 0;
            [self.flashButton setImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
        }
    }

}

#pragma mark - Private Methods

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
//    if (acceleration.x > -0.01 && acceleration.x < 0.01) {
        levelView.backgroundColor = [UIColor clearColor];
        levelView.userInteractionEnabled = NO;
        [self.view addSubview:levelView];
        [levelView setTransform:CGAffineTransformMakeTranslation(0, -7.0)];
        [self.view bringSubviewToFront:levelView];
        [levelView drawRect:self.view.frame];
        
        levelView.alpha = 0.5;
//    }
    NSLog(@"%f",acceleration.x);
}

- (IBAction)showLevel:(id)sender {
    if (levelFlag ==0) {
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:0.1];
        [[UIAccelerometer sharedAccelerometer] setDelegate:self];
        levelView = [[LevelView alloc] initWithFrame:self.view.frame];
        levelFlag = 1;
    }else if (levelFlag ==1){
        [levelView removeFromSuperview];
        [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
        levelFlag = 0;
    }
    
    
}

- (IBAction)showGrid:(id)sender {
    if (gridFlag == 0) {
        
        gridView = [[GridView alloc] initWithFrame:self.view.frame];
        gridView.backgroundColor = [UIColor clearColor];
        gridView.userInteractionEnabled = NO;
        [self.view addSubview:gridView];
        [gridView setTransform:CGAffineTransformMakeTranslation(0, -20.0)];
        [self.view bringSubviewToFront:gridView];
        [gridView drawRect:self.view.frame];
        
        gridView.alpha = 0.3;
        
        [self.view bringSubviewToFront:self.swipeView];
        [self.view bringSubviewToFront:self.gridButton];
        [self.view bringSubviewToFront:self.levelButton];
        [self.view bringSubviewToFront:self.flashButton];
        
        gridFlag = 1;
        
    }else if(gridFlag == 1){
        
        [gridView removeFromSuperview];
        
        gridFlag = 0;
        
    }
    
}
@end;
