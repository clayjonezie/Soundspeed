//
//  SSDropboxChooser.m
//  Soundspeed
//
//  Created by Clay on 8/2/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SSDropboxChooser.h"

@interface SSDropboxChooser ()

@property (nonatomic) UITableView *tableView;
@property (nonatomic, copy) NSArray *fileInfos;

@end

@implementation SSDropboxChooser

- (id)initWithFrame:(CGRect)frame andFiles:(NSArray *)fileInfos {
    self = [super initWithFrame:frame];
    if (self) {
      _tableView = [[UITableView alloc] init];
      _tableView.delegate = self;
      _tableView.dataSource = self;
      _fileInfos = fileInfos;
      
      [self addSubview:_tableView];
    }
    return self;
}

-(void)layoutSubviews {
  [_tableView setFrame:self.frame];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  DBFileInfo *fileInfo = [_fileInfos objectAtIndex:indexPath.row];
  NSString *reuseId = @"SSDropboxChooserCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
  if (!cell) {
    cell = [[UITableViewCell alloc] init];
  }
  
  cell.textLabel.font = [SSStylesheet primaryFontLarge];
  cell.textLabel.textColor = [SSStylesheet primaryColor];
  
  cell.textLabel.text = fileInfo.path.name;
  
  return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_fileInfos count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.delegate dropboxChooser:self choseFile:[_fileInfos objectAtIndex:indexPath.row]];
}

@end
