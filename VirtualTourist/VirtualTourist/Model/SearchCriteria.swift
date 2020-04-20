//
//  SearchCriteria.swift
//  VirtualTourist
//
//  Created by Joey Berger on 4/19/20.
//  Copyright © 2020 Joey Berger. All rights reserved.
//

struct SearchCriteria {
    let latitude: Double
    let longitude: Double
    var page: Int = 1
    let perPage: Int = PhotoAlbumViewController().totalThumbnails
}
