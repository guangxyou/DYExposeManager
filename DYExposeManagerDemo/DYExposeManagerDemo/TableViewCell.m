//
//  TableViewCell.m
//  DYExposeManagerDemo
//
//  Created by ygx on 2019/12/11.
//  Copyright © 2019 ygx. All rights reserved.
//

#import "TableViewCell.h"
#import "DYExposeManager.h"

@implementation TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    self.dy_ShouldDetectExpose = YES;
    __weak typeof(self) weakSelf = self;
    self.dy_DidExposedBlock = ^{
        NSLog(@"%@ exposed.", weakSelf.textLabel.text);
    };
}

@end
