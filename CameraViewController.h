//
//  CameraViewController.h
//  CertApp
//
//  Created by Hongmo on 2014. 2. 18..
//  Copyright (c) 2014년 Digitalzone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tesseract/TesseractOCR/TesseractOCR.h"
#import "ImageProcess.h"
#import "PortraitCvVideoCamera.h"
#import "CvCamera/cap_ios.h"

@interface CameraViewController : UIViewController <DZCvVideoCameraDelegate> {
    
    PortraitCvVideoCamera *videoCamera;
    IBOutlet UIButton *imageView;
    IBOutlet UIImageView *resultImageView;
    IBOutlet UIImageView *guideImageView;
    IBOutlet UILabel *resultLabel;
    NSString *checkSerialURL;
    NSString *minCompilerURL;
    
    NSString *certAddr;
    NSString *certPort;
    NSString *certMinno;
    
    G8Tesseract *tesseract;
}

@property (nonatomic, retain) PortraitCvVideoCamera *videoCamera;
@property (nonatomic, retain) UIButton *imageView;
@property (nonatomic, retain) UIImageView *resultImageView;
@property (nonatomic, retain) UIImageView *guideImageView;
@property (nonatomic, retain) UILabel *resultLabel;
@property (nonatomic, retain) NSString *checkSerialURL;
@property (nonatomic, retain) NSString *minCompilerURL;
@property (nonatomic, retain) G8Tesseract *tesseract;

- (IBAction) closeView;
- (IBAction) doCameraFocus:(id)sender forEvent:(UIEvent*)event;

@end
