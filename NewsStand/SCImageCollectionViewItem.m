//
//  SCImageCollectionViewItem.m
//  SSCatalog
//
//  Created by Sam Soffes on 5/3/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

#import "SCImageCollectionViewItem.h"
#import "UIImageResizing.h"
@implementation SCImageCollectionViewItem

#pragma mark -
#pragma mark Accessors

@synthesize imageURL = _imageURL;

- (void)setImageURL:(NSString *)url {
	[_imageURL release];
	_imageURL = [url retain];
	
	self.imageView.image = [[JMImageCache sharedCache] imageForURL:_imageURL delegate:self];
}

- (void)setImage:(UIImage *)imageIn
{
	NSLog(@"set image");
	self.imageView.image = imageIn;
	
}

- (void)setDupeAlpha
{
	self.imageView.alpha = .6;
}

- (void)setFullAlpha
{
	self.imageView.alpha = 1;
}

- (void)setSize
{
    [self.imageView.image scaleToSize:CGSizeMake(30.0, 80.0)];
    [self.imageView setFrame:CGRectMake(0, 0, 30.0, 80.0)];
}

- (UIImage*)getImage
{
	//NewsStandViewController *nsvc = [[[UIApplication sharedApplication] delegate] myViewController];
	//[nsvc.videoViewController.tableView reloadData];
	return self.imageView.image;
}

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
    [[JMImageCache sharedCache] removeImageForURL:_imageURL];
	[_imageURL release];
	[super dealloc];
}


#pragma mark -
#pragma mark Initializer

- (id)initWithReuseIdentifier:(NSString *)aReuseIdentifier {
	if ((self = [super initWithStyle:SSCollectionViewItemStyleImage reuseIdentifier:aReuseIdentifier])) {
		self.imageView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
	}
	return self;
}


- (void)prepareForReuse {
	[super prepareForReuse];
	self.imageURL = nil;
}


#pragma mark -
#pragma mark JMImageCacheDelegate

- (void)cache:(JMImageCache *)cache didDownloadImage:(UIImage *)image forURL:(NSString *)url {
	if ([url isEqualToString:_imageURL]) {
		self.imageView.image = image;
		[self setNeedsDisplay];
	}
}

@end
