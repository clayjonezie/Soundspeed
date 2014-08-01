//
//  SLOptionsViewController.m
//  Soundspeed
//
//  Created by Clay Jones on 4/24/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SLOptionsViewController.h"
#import "SLHelper.h"
#import "SLRecordViewController.h"

@interface SLOptionsViewController ()

@end

@implementation SLOptionsViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _cachedFiles = [SLHelper m4aFilesInCachesDirectory];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)closeView:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark d/ds methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cachedFiles.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Failed uploads - tap to retry";
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = [_cachedFiles objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    SLRecordViewController *recVC;
    for (UIViewController* vc in [[self navigationController] viewControllers]) {
        if ([vc isKindOfClass:[SLRecordViewController class]]) {
            recVC = vc;
            break;
        }
    }
    NSString *fn = [_cachedFiles objectAtIndex:indexPath.row];
    NSString *path = [[SLHelper cachesDirectory] stringByAppendingPathComponent:fn];
    [recVC uploadFile:fn fromPath:path];
}

@end
