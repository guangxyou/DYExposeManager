# DYExposeManager
UIView Expose Manager.

Useage:

```
@interface TableViewCell : UITableViewCell

@end

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
    self.dy_DidExposedBlock = ^{
        // do you work here
    };
}
```
