//
//  MovieCell.h
//  Flix
//
//  Created by Nikesh Subedi on 6/24/20.
//  Copyright © 2020 Nikesh Subedi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;
@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;
@end

NS_ASSUME_NONNULL_END

