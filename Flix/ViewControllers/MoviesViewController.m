//
//  MoviesViewController.m
//  Flix
//
//  Created by Nikesh Subedi on 6/24/20.
//  Copyright © 2020 Nikesh Subedi. All rights reserved.
//

#import "MoviesViewController.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"
#import "MovieCell.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong,nonatomic) NSMutableDictionary *genres;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.genres = [[NSMutableDictionary alloc] init];
    self.tableView.rowHeight = 200;
    
    [self updategenres];
    // Do any additional setup after loading the view.
    [self fetchMovies];
    
    self.refreshControl =[[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    
    // TODO: Get the array of movies
    // TODO: Store the movies in a property to use elsewhere
    // TODO: Reload your table view data
}


-(void)fetchMovies {
    [self.activityIndicator startAnimating];
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Internet Connection"
                                                                           message:@"Please connect to a WiFi or a cellular network."
                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                [self fetchMovies];
            }];
            // add the OK action to the alert controller
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:^{
                [self fetchMovies];
            }];
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.movies = dataDictionary[@"results"];
            [self.tableView reloadData];
            
        }
        [self.refreshControl endRefreshing];
        [self.activityIndicator stopAnimating];
    }];
    [task resume];
}

-(void)updategenres{
    [self.activityIndicator startAnimating];
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/genre/movie/list?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Internet Connection"
                                                                           message:@"Please connect to a WiFi or a cellular network."
                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                [self updategenres];
            }];
            // add the OK action to the alert controller
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:^{
                [self updategenres];
            }];
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            for(NSDictionary *dict in dataDictionary[@"genres"]){
                [self.genres setValue:dict[@"name"] forKey:dict[@"id"]];
                [self.tableView reloadData];
            }
            //self.movies = dataDictionary[@"results"];
        }
        [self.activityIndicator stopAnimating];

    }];
    [task resume];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCell *cell =[tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSString *baseURLString =@"https://image.tmdb.org/t/p/w500";
    //NSString *baseURLString =@"https://image.tmdb.org/t/p/original";
    NSDictionary *movie = self.movies[indexPath.row];
    NSString *posterURLString = movie[@"poster_path"];
    /*if (posterURLString){
     posterURLString = movie[@"poster_path"];
     }*/
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.movieTitleLabel.text = movie[@"title"];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    NSMutableArray *wishlistArray = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"wishlist"];
    cell.wishlistButton.accessibilityLabel = movie[@"id"];
    if (wishlistArray!=nil){
        NSString *movieId = movie[@"id"];
        if ([wishlistArray containsObject:movieId]){
            [cell.wishlistButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
        }
        else{
            [cell.wishlistButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
        }
    }
    
    NSArray *genrearray = movie[@"genre_ids"];
    //NSLog(@"%@", genrearray);
    NSString *genreString = @"Genre: ";
    if ([self.genres count] != 0){
    for (NSNumber *genreID in genrearray){
        genreString = [[genreString stringByAppendingString:self.genres[genreID]]stringByAppendingString:@", "];
    }
    genreString = [genreString substringToIndex:[genreString length] - 2];
    //NSLog(@"%@",genreString);
        cell.genreLabel.text = genreString;
    }

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}
- (IBAction)addToWishlist:(id)sender {
    UIButton *button = (UIButton*) sender;
    NSString *movieId= button.accessibilityLabel;
    NSMutableArray *wishlistArray = [[NSUserDefaults standardUserDefaults]
                                     mutableArrayValueForKey:@"wishlist"];
    if (wishlistArray==nil){
        NSMutableArray *newwishlist = [[NSMutableArray alloc] init];
        [newwishlist addObject:movieId];
        [[NSUserDefaults standardUserDefaults] setObject:newwishlist forKey:@"wishlist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        if ([wishlistArray containsObject:movieId]){
            [wishlistArray removeObject: movieId];
        }
        else{
            [wishlistArray addObject:movieId];
            [[NSUserDefaults standardUserDefaults] setObject:wishlistArray forKey:@"wishlist"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        //NSLog(@"%@",wishlistArray);
    }
}
-(IBAction) toggleUIButtonImage:(id)sender{
    UIButton *button = (UIButton*) sender;
    //NSLog(@"%lu",button.state);
    //NSLog(@"%@",button.currentImage);
    if ([button.currentImage.imageAsset isEqual: [UIImage systemImageNamed:@"heart"].imageAsset]){
        [button setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
    }
    else{
        [button setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell =sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    DetailsViewController *detailsViewController = [segue destinationViewController];
    NSArray *genrearray = movie[@"genre_ids"];
    NSString *genreString = @"Genre: ";
    if ([self.genres count] != 0){
    for (NSNumber *genreID in genrearray){
        genreString = [[genreString stringByAppendingString:self.genres[genreID]]stringByAppendingString:@", "];
    }
    genreString = [genreString substringToIndex:[genreString length] - 2];
    detailsViewController.genreList = genreString;
    detailsViewController.movie = movie;
}

}

@end
