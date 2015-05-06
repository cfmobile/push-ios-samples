//
//  MapViewController.m
//  PushSample
//
//  Created by DX173-XL on 2015-04-30.
//  Copyright (c) 2015 DX123-XL. All rights reserved.
//

#import "MapViewController.h"
#import "PCFPushDebug.h"

#define MAP_PADDING 1.1
#define MINIMUM_VISIBLE_LATITUDE 0.01
#define METERS_PER_DEGREEE_LATITUDE 111131.74

@interface MapViewController()

@property (nonatomic) UILabel *notificationLabel;
@property (nonatomic) NSInteger notificationCount;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.notificationCount = 0;
    self.mapView.showsUserLocation = YES;
    self.navigationController.toolbarHidden = YES;
    [self drawGeofences];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geofencesUpdated:) name:@"pivotal.push.geofences.updated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localNotificationReceived:) name:@"pivotal.push.demo.localnotification" object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) geofencesUpdated:(NSNotification*)notification
{
    [self drawGeofences];
}

- (void) localNotificationReceived:(NSNotification*)notification
{
    if (!self.notificationLabel) {
        self.notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, 310.0, 30.0)];
        self.notificationLabel.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.notificationLabel];
    }
    UILocalNotification *n = (UILocalNotification*) notification.object;
    self.notificationLabel.text = n.alertBody;
    self.notificationCount += 1;

    __weak MapViewController *mapViewController = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (mapViewController) {
            mapViewController.notificationCount -= 1;
            if (!mapViewController.notificationCount) {
                [mapViewController.notificationLabel removeFromSuperview];
                mapViewController.notificationLabel = nil;
            }
        }
    });
}

- (void) drawGeofences
{
    
    [self clearAllGeofences];
    NSArray *geofences = [self loadGeofences];
    if (!geofences) {
        return;
    }

    for (NSDictionary *geofence in geofences) {
        self.mapView.delegate = self;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:((NSString*)(geofence[@"expiry"])).doubleValue];
        CLLocationDistance radius = ((NSString*)(geofence[@"rad"])).doubleValue;
        CLLocationCoordinate2D centre = CLLocationCoordinate2DMake(((NSString*)(geofence[@"lat"])).doubleValue, ((NSString*)(geofence[@"long"])).doubleValue);
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:centre radius:radius];
        circle.title = geofence[@"name"];
        circle.subtitle = [@"Expires " stringByAppendingString:[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle]];
        [self.mapView addOverlay:circle];
        [self.mapView addAnnotation:circle];
    }

    if (self.mapView.overlays.count > 0) {
        [self zoomToOverlayBounds:self.mapView.overlays];
    }
}


- (void) clearAllGeofences
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (NSArray*) loadGeofences
{
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:self.geofencesFilename options:0 error:&error];
    if (!data) {
        return nil;
    }

    return [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
}

- (NSString*) geofencesFilename
{
    NSArray *possibleURLs = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    if (!possibleURLs || possibleURLs.count <= 0) {
        PCFPushLog(@"Error getting user library directory.");
        return nil;
    }

    return [((NSURL *) (possibleURLs[0])).path stringByAppendingPathComponent:@"pivotal.push.geofence_status.json"];
}

- (void)zoomToOverlayBounds:(NSArray *)overlays
{
    __block CLLocationDegrees minLatitude = DBL_MAX;
    __block CLLocationDegrees maxLatitude = -DBL_MAX;
    __block CLLocationDegrees minLongitude = DBL_MAX;
    __block CLLocationDegrees maxLongitude = -DBL_MAX;

    for (MKCircle *circle in overlays) {
        minLatitude = fmin(circle.coordinate.latitude - (circle.radius / METERS_PER_DEGREEE_LATITUDE), minLatitude);
        maxLatitude = fmax(circle.coordinate.latitude + (circle.radius / METERS_PER_DEGREEE_LATITUDE), maxLatitude);
        minLongitude = fmin(circle.coordinate.longitude - (circle.radius / METERS_PER_DEGREEE_LATITUDE), minLongitude);
        maxLongitude = fmax(circle.coordinate.longitude + (circle.radius / METERS_PER_DEGREEE_LATITUDE), maxLongitude);
    }

    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
}

-(void) setMapRegionForMinLat:(double)minLatitude minLong:(double)minLongitude maxLat:(double)maxLatitude maxLong:(double)maxLongitude
{
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;

    region.span.latitudeDelta = (maxLatitude - minLatitude) * MAP_PADDING;

    region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE)
            ? MINIMUM_VISIBLE_LATITUDE
            : region.span.latitudeDelta;

    region.span.longitudeDelta = (maxLongitude - minLongitude) * MAP_PADDING;

    MKCoordinateRegion scaledRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:scaledRegion animated:YES];
}

#pragma mark - MKMapViewDelegate methods

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    circleRenderer.strokeColor = [UIColor redColor];
    circleRenderer.lineWidth = 1.0;
    circleRenderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    return circleRenderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"GeofenceAnnotation"];
    view.pinColor = MKPinAnnotationColorRed;
    view.canShowCallout = YES;
    return view;
}

@end