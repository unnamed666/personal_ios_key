//
//  KeyboardCnnTestViewController.m
//  PandaKeyboard
//
//  Created by 张璐 on 2017/9/22.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "KeyboardCnnTestViewController.h"
#import "CMGroupDataManager.h"

@interface KeyboardCnnTestViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView * cnnTableView;
@property (nonatomic, strong) NSArray * dataSourceArray;
@property (nonatomic, strong) NSArray * desArray;
@end

@implementation KeyboardCnnTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _cnnTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    _cnnTableView.dataSource = self;
    _cnnTableView.delegate = self;
    _cnnTableView.rowHeight = 80;
    [self.view addSubview:_cnnTableView];
}

-(NSArray *)dataSourceArray
{
    if (!_dataSourceArray) {
        _dataSourceArray = [NSArray arrayWithObjects:@"404,405,406",@"510",@"334",@"515",@"724",@"520",@"250",@"310,311,312,313,314,315,316",@"452",@"722",@"222",@"502",@"262",@"736",@"208",@"655",@"732",@"234",@"default", nil];
    }
    return _dataSourceArray;
}

-(NSArray *)desArray
{
    if (!_desArray) {
        _desArray = [NSArray arrayWithObjects:@"en,(hi)",@"id,en",@"es,en",@"tl,en",@"pt,en",@"(th),en",@"ru,en",@"es,en",@"(vi),en",@"es,en",@"it,en",@"ms,en",@"de,en",@"en,es",@"fr,en",@"en",@"es,en",@"en",@"en", nil];
    }
    return _desArray;
}

#pragma mark - UITableViewDataSource Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"cellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    cell.textLabel.text = self.dataSourceArray[indexPath.row];
    
    cell.detailTextLabel.text = self.desArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef DEBUG
    kCMGroupDataManager.mccTestString = self.dataSourceArray[indexPath.row];
    [kCMGroupDataManager configMccLanguage];
#endif
    [self.navigationController popViewControllerAnimated:YES];
}
@end
