//
//  DetailsViewController.m
//  Flix
//
//  Created by Nikesh Subedi on 6/25/20.
//  Copyright © 2020 Nikesh Subedi. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropImage;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UILabel *movieLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UILabel *genreLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroudView;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.movie[@"title"];
    NSString *baseURLString =@"https://image.tmdb.org/t/p/w500";
    //NSString *baseURLString =@"https://image.tmdb.org/t/p/original";
    
    NSString *posterURLString = self.movie[@"poster_path"];
    /*if (posterURLString){
        posterURLString = movie[@"poster_path"];
    }*/
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    [self.posterImage setImageWithURL:posterURL];
    NSString *backdropURLString = self.movie[@"backdrop_path"];
    /*if (posterURLString){
        posterURLString = movie[@"poster_path"];
    }*/
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropURLString];
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString];
    [self.backdropImage setImageWithURL:backdropURL];
    self.movieLabel.text = self.movie[@"title"];
    self.dateLabel.text = [@"Release Date: " stringByAppendingString:self.movie[@"release_date"]];
    self.synopsisLabel.text = self.movie[@"overview"];
    self.genreLabel.text = self.genreList;
    [self.synopsisLabel setNumberOfLines:0];
    [self.synopsisLabel sizeToFit];

}


#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
*/
@end
