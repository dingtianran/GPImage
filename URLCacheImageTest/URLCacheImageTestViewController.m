//
//  URLCacheImageTestViewController.m
//  URLCacheImageTest
//
//  Created by dingtr on 11-4-10.
//  Copyright 2011年 communication university of China. All rights reserved.
//

#import "URLCacheImageTestViewController.h"
#import "GPImageView.h"




@implementation URLCacheImageTestViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    table_ = [[[UIScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    table_.delegate = self;
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sources" ofType:@"plist"]];
    NSInteger i=0;
    for (NSDictionary *dict in array) {
        GPImageView *image = [[[GPImageView alloc] initWithFrame:CGRectMake(15, 15+i*90, 80, 60)] autorelease];
        [image setImageURL:[dict objectForKey:@"url"]];
        [table_ addSubview:image];
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(100, 15+i*90, 200, 30)] autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.text = [dict objectForKey:@"desc"];
        [table_ addSubview:label];
        
        i++;
        
    }
    table_.contentSize = CGSizeMake(self.view.frame.size.width, [array count]*90);
    [self.view addSubview:table_];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
