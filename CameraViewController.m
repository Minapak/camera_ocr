//
//  CameraViewController.m
//  CertApp
//
//  Created by Hongmo on 2014. 2. 18..
//  Copyright (c) 2014년 Digitalzone. All rights reserved.
//

#import "CameraViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

@synthesize videoCamera;
@synthesize imageView;
@synthesize resultImageView;
@synthesize guideImageView;
@synthesize resultLabel;
@synthesize checkSerialURL;
@synthesize minCompilerURL;
@synthesize tesseract;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [imageView removeFromSuperview];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [imageView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    // 레이아웃의 크기를 미리 화면크기로 설정해야 비디오 화면의 크기가 화면 크기로 변경됨
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        resultLabel.text = @"증명서 상단 좌측에 인쇄된 ▣표시가 있는 문서번호를 박스안에 넣어주세요";
        guideImageView.image = [UIImage imageNamed:@"cam_guide_i.png"];
    }
    else
    {
        resultLabel.text = @"증명서 상단 좌측에 인쇄된\n▣표시가 있는 문서번호를 박스안에\n넣어주세요";
        
        CGFloat height = [[UIScreen mainScreen] bounds].size.height;
        
        if (height >= 568)
            guideImageView.image = [UIImage imageNamed:@"cam_guide_w.png"];
        else
            guideImageView.image = [UIImage imageNamed:@"cam_guide.png"];
    }
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
    
}

- (IBAction) doCameraFocus:(id)sender forEvent:(UIEvent*)event
{
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        //NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                //NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                //NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    if ([backCamera isFocusPointOfInterestSupported] && [backCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        CGPoint poi = CGPointMake(videoCamera.imageWidth / 2, 200);
        if ([backCamera lockForConfiguration:&error]) {
            [backCamera setFocusPointOfInterest:poi];
            //[backCamera setExposurePointOfInterest:poi];
            [backCamera setFocusMode:AVCaptureFocusModeAutoFocus];
            [backCamera unlockForConfiguration];
            NSLog(@"Tab to focus");
        }
        else
            NSLog(@"Setting up focus error");
    }
    
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ReportView"])
    {
        ReportViewController *reportViewController = (ReportViewController *)[segue destinationViewController];
        
        [reportViewController setMinCompilerURL:minCompilerURL];
        [reportViewController setAddr:certAddr];
        [reportViewController setPort:certPort];
        [reportViewController setMinno:certMinno];
        [reportViewController setTpid:@"Mobile-Viewer"];
    }
    
}

//#pragma mark - Protocol CvVideoCameraDelegate
//
//#ifdef __cplusplus
//- (void)processImage:(cv::Mat&)image;
//{
//    UIImage *uiimage;
//    int rst = processCV(image, &uiimage);
//    
//    
//    //Accessing UI Thread
//    /*[[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        resultImageView.image = uiimage;
//    }];*/
//    
//    if (rst == 1)
//    {
//        
//        [tesseract setVariableValue:@"0123456789ABCDEFGHIJKLMNPQRSTUVWXYZ-" forKey:@"tessedit_char_whitelist"];
//        [tesseract setImage:uiimage];
//        [tesseract recognize];
//        
//        NSString *serial = tesseract.recognizedText;
//        NSString *sn = [self validAndFixSerial:serial];
//        
//        if (sn != NULL)
//        {
//            NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?sn=%@", checkSerialURL, sn]];
//            NSError *error;
//            NSString *serialCheckResult = [[NSString alloc]
//                                           initWithContentsOfURL:URL
//                                           encoding:NSUTF8StringEncoding
//                                           error:&error];
//            serialCheckResult = [serialCheckResult stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//            
//            NSLog(@"SN: %@", serialCheckResult);
//            if (serialCheckResult != nil)
//            {
//                NSArray *fields = [serialCheckResult componentsSeparatedByString:@"|"];
//                
//                //인식된 문서확인번호를 보여준다
//                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                    resultLabel.text = [self makeSerialWithHypen:sn];
//                }];
//
//                if ([fields[0] isEqualToString:@"true"])
//                {
//                    AudioServicesPlaySystemSound(1052);
//                    
//                    certMinno = fields[2];
//                    certAddr = fields[3];
//                    certPort = fields[4];
//                    
//                    //Accessing UI Thread
//                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                        [self performSegueWithIdentifier:@"ReportView" sender:self];
//                    }];
//                }
//            }
//        }
//    }
//    else if (rst == 2)
//    {
//        //Accessing UI Thread
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            resultLabel.text = @"조금 더 가까이 촬영해 주세요";
//        }];
//    }
//}
//#endif

- (NSString*)validAndFixSerial:(NSString*)serial
{
    serial = [serial stringByReplacingOccurrencesOfString:@" " withString:@""];
    serial = [serial stringByReplacingOccurrencesOfString:@"-" withString:@""];
    serial = [serial stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"serial: '%@', %lu", serial, (unsigned long)serial.length);
    
    if (serial.length == 16)
    {
        return serial;
    }
    else
        return NULL;
}

- (NSString*)makeSerialWithHypen:(NSString*)serial
{
    NSString *part1 = [serial substringWithRange:{0, 4}];
    NSString *part2 = [serial substringWithRange:{4, 4}];
    NSString *part3 = [serial substringWithRange:{8, 4}];
    NSString *part4 = [serial substringWithRange:{12, 4}];
    NSString *rst = [NSString stringWithFormat:@"%@-%@-%@-%@", part1, part2, part3, part4];
    
    return rst;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.currentViewName = NSStringFromClass(self.class);
    appDelegate.currentView = self;
    NSLog(@"currentViewName: %@", appDelegate.currentViewName);
    
    //[self.tesseract = [[G8Tesseract alloc] initWithDataPath:@"/tessdata" language:@"eng"]];
    //self.tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    self.videoCamera = [[PortraitCvVideoCamera alloc] initWithParentView:imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 10;
    self.videoCamera.delegate = self;
    
    [self.videoCamera start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self.videoCamera stop];
    self.tesseract = nil;
    self.videoCamera = nil;
}

- (IBAction)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)manualInput{
    ViewController *vc = (ViewController*)self.presentingViewController;
    [vc gotoURL:[NSString stringWithFormat:@"%@%@", vc.mobileWebURL, @"/servlet/MBINDEX?COMMAND=VERIFYFORM"]];
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
