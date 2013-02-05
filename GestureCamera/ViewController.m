//
//  ViewController.m
//  GestureCamera
//
//  Created by 山田 慶 on 2013/02/05.
//  Copyright (c) 2013年 山田 慶. All rights reserved.
//

#import "ViewController.h"


//#import "UIKitHelper.h"
#import "GPUImage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
{
    GPUImageStillCamera *stillCamera;
    GPUImageWhiteBalanceFilter *whiteBalance;
    GPUImageBrightnessFilter *blightness;
    GPUImageFilterGroup *filterGroup;
    GPUImageFilterGroup *panFilterGroup;
    
    NSInteger flashFlag;
    CGAffineTransform   currentTransForm;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    flashFlag = 0;
    
    // setting for stiilCamera
    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    // 保存される画像はPortrait
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    // フィルターの設定
    //// まずフィルターグループを作る。フィルターを一つにまとめることで、あとで画像をつくるときに全部のフィルターがかかった画像が得られる
    filterGroup = [[GPUImageFilterGroup alloc] init];
    
    whiteBalance = [[GPUImageWhiteBalanceFilter alloc] init];
    blightness = [[GPUImageBrightnessFilter alloc] init];
    
    [whiteBalance setTemperature:5000];
    [blightness setBrightness:0];

    [stillCamera startCameraCapture];
    
    [self addGestureRecognizersToPiece];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addGestureRecognizersToPiece{
    NSLog(@"addGestureRecognizersToPiece");
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(sellongPressGesture:)];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    UIPinchGestureRecognizer* pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    
    doubleTapGesture.numberOfTapsRequired = 2;
    
    longPressGesture.allowableMovement = 100;
    longPressGesture.minimumPressDuration = 0.9f;
    longPressGesture.numberOfTapsRequired = 1;
//    longPressGesture.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:longPressGesture];
    [self.imageView addGestureRecognizer:panGesture];
    [self.imageView addGestureRecognizer:doubleTapGesture];
    [self.view addGestureRecognizer:pinchGesture];
}


#pragma mark - Gesture Methods

- (void) handlePinchGesture:(UIPinchGestureRecognizer*) sender {
//    UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)sender;
    // ピンチジェスチャー発生時に、Imageの現在のアフィン変形の状態を保存する
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        currentTransForm = self.view.transform;
        // currentTransFormは、フィールド変数。imgViewは画像を表示するUIImageView型のフィールド変数。
    }
    CGFloat scale = [(UIPinchGestureRecognizer *)sender scale];
    
    //以前のピンチした時の拡大率と現在ピンチでとれた拡大率を掛け合わしたTransform
    //
    CGAffineTransform transform = CGAffineTransformConcat(currentTransForm,CGAffineTransformMakeScale(scale, scale));
    if ( transform.a < 1.0){
        transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
    self.view.transform = transform;
}

- (void) handleDoubleTapGesture:(UITapGestureRecognizer*)sender {
    NSLog(@"double tap");
    NSError *error = nil;
     if ([stillCamera.inputCamera lockForConfiguration:&error]) {
         if (flashFlag == 0) {
             [stillCamera.inputCamera setFlashMode:AVCaptureFlashModeOn];
             flashFlag = 1;
         }else if (flashFlag == 1){
             [stillCamera.inputCamera setFlashMode:AVCaptureFlashModeOff];
             flashFlag = 0;
         }
     }
}

- (void) handlePanGesture:(UIPanGestureRecognizer*) sender {
    UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*) sender;
    CGPoint location = [pan translationInView:self.imageView];
    [whiteBalance setTemperature:location.x * 15.625+2500];
    [blightness setBrightness:location.y * 0.0036 * -1 - 0.5];
    [filterGroup addFilter:whiteBalance];
    [filterGroup addFilter:blightness];
    
    [stillCamera addTarget:whiteBalance];
    
    [whiteBalance addTarget:blightness];
    [blightness addTarget:self.imageView];
}


- (void)sellongPressGesture:(UILongPressGestureRecognizer*)sender
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

@end;
