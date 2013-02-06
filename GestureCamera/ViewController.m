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
    CGAffineTransform currentTransForm;
    CGAffineTransform pinchTransform;
}

@end

@implementation ViewController

#pragma mark - LifeCycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    flashFlag = 0;
    
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
    
    [self.imageView addGestureRecognizer:longPressGesture];
    [self.imageView addGestureRecognizer:twoFingersLongPressGesture];
    [self.imageView addGestureRecognizer:panGesture];
    [self.imageView addGestureRecognizer:tapGesture];
    [self.imageView addGestureRecognizer:doubleTapGesture];
    [self.imageView addGestureRecognizer:twoFingerTapGesture];
    [self.view addGestureRecognizer:pinchGesture];
    
}


#pragma mark - Gesture Methods

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

#pragma mark - save

- (void) handleTwoFingersLongPressGesture:(UILongPressGestureRecognizer*)sender
{
    NSLog(@"%f",pinchTransform.a);
    if ([sender state] == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
    }else if([sender state] == UIGestureRecognizerStateEnded){
    if (pinchTransform.a > 1.f) {
        NSLog(@"UIGetScreenImage");
        CGImageRef imageRef = UIGetScreenImage();
        UIImage * proseccedImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        CGFloat width = 320;
        CGFloat height = 568;
        
        UIImage *finalImage = [[UIImage alloc]init];
        
        CGRect rect = CGRectMake(200, 200, 320, 320);
        
        UIGraphicsBeginImageContext(rect.size);
        [proseccedImage drawInRect:CGRectMake(0, -142, width, height)];
        finalImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        [library writeImageToSavedPhotosAlbum:finalImage.CGImage
                                     metadata:nil
                              completionBlock:^(NSURL *assetURL, NSError *error){
                                  if (!error) {
                                      NSLog(@"保存成功！");

                                  }
                              }
         ];
    }else{
    GPUImageFilterGroup* filterGroupForCrop = [[GPUImageFilterGroup alloc] init];
    
    [filterGroupForCrop addTarget:filterGroup];
    [filterGroup addTarget:crop];

    
    [filterGroupForCrop setInitialFilters:@[firstFilter]];
    [filterGroupForCrop setTerminalFilter:crop];
    
        // 指定したFilterがかかった、画像が取得できる。そのために、プロパティでfilterをもたせている。
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

@end;
