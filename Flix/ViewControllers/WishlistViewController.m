//
//  WishlistViewController.m
//  Flix
//
//  Created by Nikesh Subedi on 6/26/20.
//  Copyright © 2020 Nikesh Subedi. All rights reserved.
//

#import "WishlistViewController.h"
#import "WishlistCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface WishlistViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NSMutableArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation WishlistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.movies = [[NSMutableArray alloc] init];
    self.collectionView.dataSource = self;
    self.collectionView.delegate=self;
    
    [self fetchMovies];
    UICollectionViewFlowLayout *layout =  (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    CGFloat posterPerRow = 2;
    CGFloat posterwidth =self.collectionView.frame.size.width/posterPerRow;
    layout.itemSize = CGSizeMake(posterwidth, 1.5*posterwidth);
    self.refreshControl =[[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}
-(void)fetchMovies {
    NSMutableArray *wishlistArray = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"wishlist"];
    if (wishlistArray==nil || [wishlistArray count] == 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Movies in Wishlist"
                                                                       message:@"Please add movies to your wishlist to proceed"
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Go Back"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
            [self.refreshControl endRefreshing];
            [self.tabBarController setSelectedIndex:0];
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{}];
    }
    else{
        [self.movies removeAllObjects];
        for(NSNumber *movie in wishlistArray){
            NSString *moviestring = [movie stringValue];
            NSString *urlWithId =[[@"https://api.themoviedb.org/3/movie/" stringByAppendingString: moviestring]stringByAppendingString:@"?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
            //NSLog(@"%@",urlWithId);
            NSURL *url = [NSURL URLWithString:urlWithId];
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
                    //NSLog(@"%@",dataDictionary);
                    [self.movies addObject:dataDictionary];
                    //NSLog(@"%@", self.movies);
                    [self.collectionView reloadData];
                    
                }
                
            }];
            [task resume];
        }
        [self.refreshControl endRefreshing];
    }
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     UICollectionViewCell *tappedCell =sender;
     NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
     NSDictionary *movie = self.movies[indexPath.item];
     DetailsViewController *detailsViewController = [segue destinationViewController];
     detailsViewController.movie = movie;
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WishlistCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WishlistCollectionCell" forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.item];
    NSString *posterURLString = movie[@"poster_path"];
    NSString *baseURLString =@"https://image.tmdb.org/t/p/w500";
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

@end
