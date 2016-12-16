//
//  ViewController.m
//  DownloadImagesFormWebView
//
//  Created by 非整勿扰 on 16/12/16.
//  Copyright © 2016年 iHTCboy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *urlFiled;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *downBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.urlFiled.delegate = self;
    self.webView.delegate = self;
    self.downBtn.enabled = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField.text.length) {
        self.downBtn.enabled = NO;
        NSURL * url = [NSURL URLWithString:textField.text];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.downBtn.enabled = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.downBtn.enabled = YES;
}

- (IBAction)gotoWebView:(id)sender {
    if (self.urlFiled.text.length) {
        NSURL * url = [NSURL URLWithString:self.urlFiled.text];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}


- (IBAction)downloadImages:(UIButton *)sender {
    sender.enabled = NO;
    if (!self.webView.isLoading) {
        NSArray * array = [self getImageURLs];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj class] isSubclassOfClass:[NSString class]]) {
                // replace some especially string or coustom format
                //obj = [obj stringByReplacingOccurrencesOfString:@"_570" withString:@"_301_301"];
                NSURL * url =[NSURL URLWithString:obj];
                NSData * data = [NSData dataWithContentsOfURL:url];
                //写入文件内容
                NSString *savedImagePath = [NSString stringWithFormat:@"/Users/fzwr/Desktop/DownloadImages/%ldimage.png",idx];
                NSLog(@"写入文件");
                [data writeToFile:savedImagePath atomically:YES];
            }
        }];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Download Finished!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    sender.enabled = YES;
}

- (NSArray *)getImageURLs{
    //这里是js，主要目的实现对url的获取
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    };\
    return imgScr;\
    };";
    
    [self.webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    
    NSString *urlResurlt = [self.webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    NSMutableArray * mUrlArray = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"+"]];
    if (mUrlArray.count >= 2) {
        [mUrlArray removeLastObject];
    }
    return mUrlArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
