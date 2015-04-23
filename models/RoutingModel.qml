import QtQuick 2.0

ListModel {
    readonly property string nearestURL: 'https://router.project-osrm.org/nearest?loc={lat},{lon}'
    readonly property string viarouteURL: 'https://router.project-osrm.org/viaroute?loc={cur_lat},{cur_lon}&loc={dst_lat},{dst_lon}'

    signal error()
    signal loading()
    signal done()

    function navigateTo (lat, lng) {
        var curr = src.position.coordinate;
        console.log('Current position', curr.latitude, curr.longitude);
        var starting_lat = curr.latitude;
        var starting_lon = curr.longitude;
        var ending_lat = lat;
        var ending_lon = lng;

        var url = nearestURL;
        url = url.replace(/\{lat\}/g, curr.latitude);
        url = url.replace(/\{lon\}/g, curr.longitude);

        xhr = new XMLHttpRequest;
        xhr.open("GET", url);
        xhr.setRequestHeader('User-Agent','OSMTouch');
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var result = JSON.parse(xhr.responseText);
                    starting_lat = result.mapped_coordinate[0];
                    starting_lon = result.mapped_coordinate[1];
                } else {
                    error();
                }
                done();
            }
        }

        xhr.send();

        console.log('navigating from', starting_lat, starting_lon);

        url = nearestURL;
        url = url.replace(/\{lat\}/g, lat);
        url = url.replace(/\{lon\}/g, lng);

        xhr = new XMLHttpRequest;
        xhr.open("GET", url);
        xhr.setRequestHeader('User-Agent','OSMTouch');
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var result = JSON.parse(xhr.responseText);
                    ending_lat = result.mapped_coordinate[0];
                    ending_lon = result.mapped_coordinate[1];
                } else {
                    error();
                }
                done();
            }
        }

        xhr.send();

        console.log('navigating to', ending_lat, ending_lon);

        if(mapPage.trackPoly !== null) {
            mapPage.map.removeMapItem(mapPage.trackPoly);
            mapPage.trackPoly.destroy();
            mapPage.trackPoly = null;
        }

        mapPage.trackPoly = Qt.createQmlObject("import QtLocation 5.0; MapPolyline {}", mapPage, "dynamicSnippet1");
        mapPage.trackPoly.line.width = 3;
        mapPage.trackPoly.line.color = "green";

        url = viarouteURL;
        url = url.replace(/\{cur_lat\}/g, starting_lat);
        url = url.replace(/\{cur_lon\}/g, starting_lon);
        url = url.replace(/\{dst_lat\}/g, ending_lat);
        url = url.replace(/\{dst_lon\}/g, ending_lon);

        var items = [];
        xhr = new XMLHttpRequest;
        xhr.open("GET", url);
        xhr.setRequestHeader('User-Agent','OSMTouch');
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var result = JSON.parse(xhr.responseText);
                    //items = result.via_points;
                    items = [[starting_lat, starting_lon], [ending_lat, ending_lon]];
                } else {
                    error();
                }
                done();
            }
        }

        xhr.send();
        // TODO: Make items the list of points from the viaroute response
        var coord = QtPositioning.coordinate();

        for (var i=0; i < items.length; i++) {
            coord.latitude = items[i][0];
            coord.longitude = items[i][1];
            mapPage.trackPoly.addCoordinate(coord);
        }

        mapPage.trackPoly.visible = true;
        mapPage.map.addMapItem(mapPage.trackPoly);
    }

    function _decode(encoded, precision) {
        precision = Math.pow(10, -precision);
        var len = encoded.length, index=0, lat=0, lng = 0, array = [];
        while (index < len) {
            var b, shift = 0, result = 0;
            do {
                b = encoded.charCodeAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            var dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
            lat += dlat;
            shift = 0;
            result = 0;
            do {
                b = encoded.charCodeAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            var dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
            lng += dlng;
            //array.push( {lat: lat * precision, lng: lng * precision} );
            array.push( [lat * precision, lng * precision] );
        }
        return array;
    }
}
