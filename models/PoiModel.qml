import QtQuick 2.0

ListModel {

    readonly property string baseUrl: 'http://overpass-api.de/api/interpreter?data=[out:json];(node{clause}({bbox});way{clause}({bbox}));out center;'
    property string clause: ""
    property string label: ""
    property bool active: !!clause

    signal error()
    signal loading()
    signal done()

    function search (bbox) {
        if (clause === "") {
            return;
        }
        var url = baseUrl;
        url = url.replace(/\{bbox\}/g, bbox);
        url = url.replace(/\{clause\}/g, clause);

        var xhr = new XMLHttpRequest;
        xhr.open("GET", url);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    fromJSON(JSON.parse(xhr.responseText));
                    done();
                } else {
                    error();
                }
            }
        }

        xhr.send();
        loading();
    }

    function purge () {
        clause = "";
        label = "";
        clear();
    }

    function fromJSON (data) {
        var el, place;
        for (var i = 0, l = data.elements.length; i < l; i++) {
            place = {};
            el = data.elements[i];
            if (el.type === "node") {
                place.lat = el.lat;
                place.lng = el.lon;
            } else if (el.type === "way") {
                place.lat = el.center.lat;
                place.lng = el.center.lon;
            } else {
                continue;
            }
            place.osm_id = el.id + el.type;
            place.name = el.tags.name;
            place.phone = el.tags.phone;
            place.website = el.tags.website;
            place.wheelchair = el.tags.wheelchair;
            place.cuisine = el.tags.cuisine;
            append(place);
        }
    }
}
