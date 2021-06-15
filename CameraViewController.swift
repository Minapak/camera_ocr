//  Converted to Swift 5.4 by Swiftify v5.4.22430 - https://swiftify.com/
//
//  CameraViewController.swift
//  CertApp
//
//  Created by Hongmo on 2014. 2. 18..
//  Copyright (c) 2014년 Digitalzone. All rights reserved.
//

import CvCamera
import Tesseract
import UIKit

var appDelegate = UIApplication.shared.delegate as? AppDelegate





var vc = presentingViewController as? ViewController

var part1: String?
var part2: String?
var part3: String?
var part4: String?
var rst = "\(part1 ?? "")-\(part2 ?? "")-\(part3 ?? "")-\(part4 ?? "")"

class CameraViewController: UIViewController, DZCvVideoCameraDelegate {
    var certAddr: String?
    var certPort: String?
    var certMinno: String?


    var videoCamera: PortraitCvVideoCamera?
    var imageView: UIButton?
    var resultImageView: UIImageView?
    var guideImageView: UIImageView?
    var resultLabel: UILabel?
    var checkSerialURL: String?
    var minCompilerURL: String?
    var tesseract: G8Tesseract?

    @IBAction func closeView() {
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView?.removeFromSuperview()
        imageView?.translatesAutoresizingMaskIntoConstraints = true
        imageView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        if let imageView = imageView {
            view.addSubview(imageView)
            view.sendSubviewToBack(imageView)
        }
        // 레이아웃의 크기를 미리 화면크기로 설정해야 비디오 화면의 크기가 화면 크기로 변경됨

        if UI_USER_INTERFACE_IDIOM() == .pad {
            resultLabel?.text = "증명서 상단 좌측에 인쇄된 ▣표시가 있는 문서번호를 박스안에 넣어주세요"
            guideImageView?.image = UIImage(named: "cam_guide_i.png")
        } else {
            resultLabel?.text = "증명서 상단 좌측에 인쇄된\n▣표시가 있는 문서번호를 박스안에\n넣어주세요"

            let height = UIScreen.main.bounds.size.height

            if height >= 568 {
                guideImageView?.image = UIImage(named: "cam_guide_w.png")
            } else {
                guideImageView?.image = UIImage(named: "cam_guide.png")
            }
        }

    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {

        return .portrait

    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {

        return .portrait

    }

    @IBAction func doCameraFocus(_ sender: Any, for event: UIEvent) {
        let devices = AVCaptureDevice.devices()
        var frontCamera: AVCaptureDevice?
        var backCamera: AVCaptureDevice?

        for device in devices {

            //NSLog(@"Device name: %@", [device localizedName]);

            if device.hasMediaType(.video) {

                if device.position == .back {
                    //NSLog(@"Device position : back");
                    backCamera = device
                } else {
                    //NSLog(@"Device position : front");
                    frontCamera = device
                }
            }
        }

        if backCamera?.isFocusPointOfInterestSupported ?? false && backCamera?.isFocusModeSupported(.autoFocus) ?? false {
            var error: Error?
            let poi = CGPoint(x: (videoCamera?.imageWidth ?? 0) / 2, y: 200)
            do {
                if try backCamera?.lockForConfiguration() != nil {
                    backCamera?.focusPointOfInterest = poi
                    //[backCamera setExposurePointOfInterest:poi];
                    backCamera?.focusMode = .autoFocus
                    backCamera?.unlockForConfiguration()
                    print("Tab to focus")
                } else {
                    print("Setting up focus error")
                }
            } catch {
            }
        }

        //[self dismissViewControllerAnimated:YES completion:nil];
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ReportView" {
            let reportViewController = segue.destination as? ReportViewController

            reportViewController?.minCompilerURL = minCompilerURL
            reportViewController?.addr = certAddr
            reportViewController?.port = certPort
            reportViewController?.minno = certMinno
            reportViewController?.tpid = "Mobile-Viewer"
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

    func validAndFixSerial(_ serial: String?) -> String? {
        var serial = serial
        serial = serial?.replacingOccurrences(of: " ", with: "")
        serial = serial?.replacingOccurrences(of: "-", with: "")
        serial = serial?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        print(String(format: "serial: '%@', %lu", serial ?? "", UInt(serial?.count ?? 0)))

        if (serial?.count ?? 0) == 16 {
            return serial
        } else {
            return nil
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// Dispose of any resources that can be recreated.//[self.tesseract = [[G8Tesseract alloc] initWithDataPath:@"/tessdata" language:@"eng"]];
//self.tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];