//
//  SpacetimeTableViewCell.m
//  GigRadio
//
//  Created by Michael Forrest on 26/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SpacetimeTableViewCell.h"
#import "DateFormats.h"
@import MapKit;

@implementation SpacetimeTableViewCell{
    
    __weak IBOutlet MKMapView *mapView;
    __weak IBOutlet UILabel *eventTime;
    __weak IBOutlet UILabel *addressLabel;
}
-(void)awakeFromNib{
    mapView.showsUserLocation = YES;
}
-(void)setEvent:(SongKickEvent *)event{
    _event = event;
    eventTime.text = [[DateFormats eventDateFormatter] stringFromDate:event.start.datetime];
    addressLabel.text = event.venue.address;
   
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = {event.venue.location.coordinate, span};
    
    MKPointAnnotation * annotation = [MKPointAnnotation new];
    annotation.coordinate = event.venue.location.coordinate;
    
    [mapView setRegion:region];
    [mapView addAnnotation:annotation];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
