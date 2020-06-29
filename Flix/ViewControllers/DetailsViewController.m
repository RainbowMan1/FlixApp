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
@property (weak, nonatomic) IBOutlet UILabel *synopsisHeading;
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
    __block NSDictionary *prominentColor = [[NSDictionary alloc] init];
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropURLString];
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString];
    [self.backdropImage setImageWithURLRequest:[NSURLRequest requestWithURL:backdropURL] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        prominentColor = [self mainColoursInImage:image detail:1];
        //NSLog(@"%@",prominentColor);
        
        [self.backdropImage setImage:image];
        NSMutableArray *keyarray = [[NSMutableArray alloc] init];
        for(id key in prominentColor){
            [keyarray addObject:key];
            
        }
        NSNumber *primaryColorKey = [keyarray valueForKeyPath:@"@max.self"];
        NSNumber *secondaryColorKey = [keyarray valueForKeyPath:@"@min.self"];
        UIColor *primaryColor =prominentColor[primaryColorKey];
        UIColor *secondaryColor =prominentColor[secondaryColorKey];
        self.backgroudView.backgroundColor = primaryColor;
        self.dateLabel.textColor=secondaryColor;
        self.genreLabel.textColor=secondaryColor;
        self.movieLabel.textColor=secondaryColor;
        self.synopsisLabel.textColor=secondaryColor;
        self.synopsisHeading.textColor=secondaryColor;
    }
                                       failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        prominentColor = nil;
        
    }];
    self.movieLabel.text = self.movie[@"title"];
    self.dateLabel.text = [@"Release Date: " stringByAppendingString:self.movie[@"release_date"]];
    self.synopsisLabel.text = self.movie[@"overview"];
    self.genreLabel.text = self.genreList;
    [self.synopsisLabel setNumberOfLines:0];
    [self.synopsisLabel sizeToFit];
    [self.genreLabel setNumberOfLines:0];
    [self.genreLabel sizeToFit];
    [self.movieLabel setNumberOfLines:0];
    [self.movieLabel sizeToFit];
}


-(NSDictionary*)mainColoursInImage:(UIImage *)image detail:(int)detail {
    
    //1. determine detail vars (0==low,1==default,2==high)
    //default detail
    float dimension = 10;
    float flexibility = 2;
    float range = 60;
    
    //low detail
    if (detail==0){
        dimension = 4;
        flexibility = 1;
        range = 100;
        
        //high detail (patience!)
    } else if (detail==2){
        dimension = 100;
        flexibility = 10;
        range = 20;
    }
    
    //2. determine the colours in the image
    NSMutableArray * colours = [NSMutableArray new];
    CGImageRef imageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(dimension * dimension * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * dimension;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, dimension, dimension, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, dimension, dimension), imageRef);
    CGContextRelease(context);
    
    float x = 0;
    float y = 0;
    for (int n = 0; n<(dimension*dimension); n++){
        
        int index = (bytesPerRow * y) + x * bytesPerPixel;
        int red   = rawData[index];
        int green = rawData[index + 1];
        int blue  = rawData[index + 2];
        int alpha = rawData[index + 3];
        NSArray * a = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%i",red],[NSString stringWithFormat:@"%i",green],[NSString stringWithFormat:@"%i",blue],[NSString stringWithFormat:@"%i",alpha], nil];
        [colours addObject:a];
        
        y++;
        if (y==dimension){
            y=0;
            x++;
        }
    }
    free(rawData);
    
    //3. add some colour flexibility (adds more colours either side of the colours in the image)
    NSArray * copyColours = [NSArray arrayWithArray:colours];
    NSMutableArray * flexibleColours = [NSMutableArray new];
    
    float flexFactor = flexibility * 2 + 1;
    float factor = flexFactor * flexFactor * 3; //(r,g,b) == *3
    for (int n = 0; n<(dimension * dimension); n++){
        
        NSArray * pixelColours = copyColours[n];
        NSMutableArray * reds = [NSMutableArray new];
        NSMutableArray * greens = [NSMutableArray new];
        NSMutableArray * blues = [NSMutableArray new];
        
        for (int p = 0; p<3; p++){
            
            NSString * rgbStr = pixelColours[p];
            int rgb = [rgbStr intValue];
            
            for (int f = -flexibility; f<flexibility+1; f++){
                int newRGB = rgb+f;
                if (newRGB<0){
                    newRGB = 0;
                }
                if (p==0){
                    [reds addObject:[NSString stringWithFormat:@"%i",newRGB]];
                } else if (p==1){
                    [greens addObject:[NSString stringWithFormat:@"%i",newRGB]];
                } else if (p==2){
                    [blues addObject:[NSString stringWithFormat:@"%i",newRGB]];
                }
            }
        }
        
        int r = 0;
        int g = 0;
        int b = 0;
        for (int k = 0; k<factor; k++){
            
            int red = [reds[r] intValue];
            int green = [greens[g] intValue];
            int blue = [blues[b] intValue];
            
            NSString * rgbString = [NSString stringWithFormat:@"%i,%i,%i",red,green,blue];
            [flexibleColours addObject:rgbString];
            
            b++;
            if (b==flexFactor){ b=0; g++; }
            if (g==flexFactor){ g=0; r++; }
        }
    }
    
    //4. distinguish the colours
    //orders the flexible colours by their occurrence
    //then keeps them if they are sufficiently disimilar
    
    NSMutableDictionary * colourCounter = [NSMutableDictionary new];
    
    //count the occurences in the array
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:flexibleColours];
    for (NSString *item in countedSet) {
        NSUInteger count = [countedSet countForObject:item];
        [colourCounter setValue:[NSNumber numberWithInteger:count] forKey:item];
    }
    
    //sort keys highest occurrence to lowest
    NSArray *orderedKeys = [colourCounter keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj2 compare:obj1];
    }];
    
    //checks if the colour is similar to another one already included
    NSMutableArray * ranges = [NSMutableArray new];
    for (NSString * key in orderedKeys){
        NSArray * rgb = [key componentsSeparatedByString:@","];
        int r = [rgb[0] intValue];
        int g = [rgb[1] intValue];
        int b = [rgb[2] intValue];
        bool exclude = false;
        for (NSString * ranged_key in ranges){
            NSArray * ranged_rgb = [ranged_key componentsSeparatedByString:@","];
            
            int ranged_r = [ranged_rgb[0] intValue];
            int ranged_g = [ranged_rgb[1] intValue];
            int ranged_b = [ranged_rgb[2] intValue];
            
            if (r>= ranged_r-range && r<= ranged_r+range){
                if (g>= ranged_g-range && g<= ranged_g+range){
                    if (b>= ranged_b-range && b<= ranged_b+range){
                        exclude = true;
                    }
                }
            }
        }
        
        if (!exclude){ [ranges addObject:key]; }
    }
    
    //return ranges array here if you just want the ordered colours high to low
    NSMutableArray * colourArray = [NSMutableArray new];
    for (NSString * key in ranges){
        NSArray * rgb = [key componentsSeparatedByString:@","];
        float r = [rgb[0] floatValue];
        float g = [rgb[1] floatValue];
        float b = [rgb[2] floatValue];
        UIColor * colour = [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0f];
        [colourArray addObject:colour];
    }
    
    //if you just want an array of images of most common to least, return here
    //return [NSDictionary dictionaryWithObject:colourArray forKey:@"colours"];
    
    
    //if you want percentages to colours continue below
    NSMutableDictionary * temp = [NSMutableDictionary new];
    float totalCount = 0.0f;
    for (NSString * rangeKey in ranges){
        NSNumber * count = colourCounter[rangeKey];
        totalCount += [count intValue];
        temp[rangeKey]=count;
    }
    
    //set percentages
    NSMutableDictionary * colourDictionary = [NSMutableDictionary new];
    for (NSString * key in temp){
        float count = [temp[key] floatValue];
        float percentage = count/totalCount;
        NSArray * rgb = [key componentsSeparatedByString:@","];
        float r = [rgb[0] floatValue];
        float g = [rgb[1] floatValue];
        float b = [rgb[2] floatValue];
        UIColor * colour = [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0f];
        colourDictionary[[NSNumber numberWithFloat:percentage]]=colour;
    }
    
    return colourDictionary;
    
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
