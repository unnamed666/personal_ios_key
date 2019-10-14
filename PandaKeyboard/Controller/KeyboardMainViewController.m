//
//  KeyboardMainViewController.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/8.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "KeyboardMainViewController.h"
#import "KeyboardReturnTypeViewController.h"
#import "KeyboardInputTypeViewController.h"
#import "KeyboardCorrectionTypeViewController.h"
#import "KeyboardCnnTestViewController.h"


@interface KeyboardMainViewController ()
@property (nonatomic, strong)UISegmentedControl* segmentCtrl;
@property (nonatomic, strong)KeyboardInputTypeViewController* inputTypeController;
@property (nonatomic, strong)KeyboardReturnTypeViewController* returnTypeController;
@property (nonatomic, strong)KeyboardCorrectionTypeViewController* autocorrectionTypeController;
@property (nonatomic, strong)KeyboardCnnTestViewController * cnnTestViewController;

@end

@implementation KeyboardMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = self.segmentCtrl;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.segmentCtrl setSelectedSegmentIndex:0];
    [self.segmentCtrl sendActionsForControlEvents:UIControlEventValueChanged];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)segmentIndexChanged:(UISegmentedControl *)ctrl {
    if (ctrl.selectedSegmentIndex == 0) {
        if (self.returnTypeController) {
            [self.returnTypeController willMoveToParentViewController:nil];
            [self.returnTypeController.view removeFromSuperview];
            [self.returnTypeController removeFromParentViewController];
            self.returnTypeController = nil;
        }
        if (self.autocorrectionTypeController) {
            [self.autocorrectionTypeController willMoveToParentViewController:nil];
            [self.autocorrectionTypeController.view removeFromSuperview];
            [self.autocorrectionTypeController removeFromParentViewController];
            self.autocorrectionTypeController = nil;
        }
       
        if (self.cnnTestViewController) {
            [self.cnnTestViewController willMoveToParentViewController:nil];
            [self.cnnTestViewController.view removeFromSuperview];
            [self.cnnTestViewController removeFromParentViewController];
            self.cnnTestViewController = nil;
        }
        [self.view addSubview:self.inputTypeController.view];
        [self.inputTypeController didMoveToParentViewController:self];
        
    }
    else if (ctrl.selectedSegmentIndex == 1) {
        if (self.inputTypeController) {
            [self.inputTypeController willMoveToParentViewController:nil];
            [self.inputTypeController.view removeFromSuperview];
            [self.inputTypeController removeFromParentViewController];
            self.inputTypeController = nil;
        }
        if (self.autocorrectionTypeController) {
            [self.autocorrectionTypeController willMoveToParentViewController:nil];
            [self.autocorrectionTypeController.view removeFromSuperview];
            [self.autocorrectionTypeController removeFromParentViewController];
            self.autocorrectionTypeController = nil;
        }
        if (self.cnnTestViewController) {
            [self.cnnTestViewController willMoveToParentViewController:nil];
            [self.cnnTestViewController.view removeFromSuperview];
            [self.cnnTestViewController removeFromParentViewController];
            self.cnnTestViewController = nil;
        }
        
        [self.view addSubview:self.returnTypeController.view];
        [self.returnTypeController didMoveToParentViewController:self];
    
    }
    else if (ctrl.selectedSegmentIndex == 2) {
        if (self.returnTypeController) {
            [self.returnTypeController willMoveToParentViewController:nil];
            [self.returnTypeController.view removeFromSuperview];
            [self.returnTypeController removeFromParentViewController];
            self.returnTypeController = nil;
        }
        if (self.inputTypeController) {
            [self.inputTypeController willMoveToParentViewController:nil];
            [self.inputTypeController.view removeFromSuperview];
            [self.inputTypeController removeFromParentViewController];
            self.inputTypeController = nil;
        }
        if (self.cnnTestViewController) {
            [self.cnnTestViewController willMoveToParentViewController:nil];
            [self.cnnTestViewController.view removeFromSuperview];
            [self.cnnTestViewController removeFromParentViewController];
            self.cnnTestViewController = nil;
        }
        [self.view addSubview:self.autocorrectionTypeController.view];
        [self.autocorrectionTypeController didMoveToParentViewController:self];
        
    }
    else if (ctrl.selectedSegmentIndex == 3){
        if (self.returnTypeController) {
            [self.returnTypeController willMoveToParentViewController:nil];
            [self.returnTypeController.view removeFromSuperview];
            [self.returnTypeController removeFromParentViewController];
            self.returnTypeController = nil;
        }
        if (self.inputTypeController) {
            [self.inputTypeController willMoveToParentViewController:nil];
            [self.inputTypeController.view removeFromSuperview];
            [self.inputTypeController removeFromParentViewController];
            self.inputTypeController = nil;
        }
        if (self.autocorrectionTypeController) {
            [self.autocorrectionTypeController willMoveToParentViewController:nil];
            [self.autocorrectionTypeController.view removeFromSuperview];
            [self.autocorrectionTypeController removeFromParentViewController];
            self.autocorrectionTypeController = nil;
        }
        [self.view addSubview:self.cnnTestViewController.view];
        [self.cnnTestViewController didMoveToParentViewController:self];
    }

}

#pragma mark - setter/getter
- (UISegmentedControl *)segmentCtrl {
    if (!_segmentCtrl) {
        _segmentCtrl = [[UISegmentedControl alloc] initWithItems:@[@"InputType", @"ReturnType",@"CorrectionType",@"CnnTest"]];
        [_segmentCtrl addTarget:self action:@selector(segmentIndexChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentCtrl;
}

- (KeyboardInputTypeViewController *)inputTypeController {
    if (!_inputTypeController) {
        _inputTypeController = [KeyboardInputTypeViewController new];
        [self addChildViewController:_inputTypeController];
    }
    return _inputTypeController;
}

- (KeyboardReturnTypeViewController *)returnTypeController {
    if (!_returnTypeController) {
        _returnTypeController = [KeyboardReturnTypeViewController new];
        [self addChildViewController:_returnTypeController];
    }
    return _returnTypeController;
}

-(KeyboardCorrectionTypeViewController *)autocorrectionTypeController
{
    if (!_autocorrectionTypeController) {
        _autocorrectionTypeController = [KeyboardCorrectionTypeViewController new];
        [self addChildViewController:_autocorrectionTypeController];
    }
    return _autocorrectionTypeController;
}

- (KeyboardCnnTestViewController *)cnnTestViewController
{
    if (!_cnnTestViewController) {
        _cnnTestViewController = [KeyboardCnnTestViewController new];
        [self addChildViewController:_cnnTestViewController];
    }
    return _cnnTestViewController;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
