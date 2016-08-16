//
//  ViewController.m
//  WSNavigationMapController
//
//  Created by ws on 16/8/16.
//  Copyright © 2016年 ws. All rights reserved.
//

#import "ViewController.h"
#import "WSNavigationMapController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClick:(id)sender {
    
    // 进入系统自带地图
    WSNavigationMapController *navigationMapController = [[WSNavigationMapController alloc] init];
    [self.navigationController pushViewController:navigationMapController animated:YES];
}

+ (instancetype)initFromStoryBoard {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    return [sb instantiateInitialViewController];
    
}


@end
