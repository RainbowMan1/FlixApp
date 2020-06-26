//
//  DetailsViewController.h
//  Flix
//
//  Created by Nikesh Subedi on 6/25/20.
//  Copyright © 2020 Nikesh Subedi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController
@property (nonatomic, strong) NSDictionary *movie;
@property (nonatomic, strong) NSString *genreList;
@end

NS_ASSUME_NONNULL_END
