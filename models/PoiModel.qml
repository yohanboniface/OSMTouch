import QtQuick 2.0

ListModel {

    readonly property string baseUrl: 'http://overpass-api.de/api/interpreter?data=[out:json];(node{clause}({bbox});way{clause}({bbox}));out center;'
    property var category
    property string label: category? category.label: '';
    property bool active: !!category
    property var xhr;

    signal error()
    signal loading()
    signal done()

    function search (bbox) {
        if (!active) {
            return;
        }
        var url = baseUrl;
        url = url.replace(/\{bbox\}/g, bbox);
        url = url.replace(/\{clause\}/g, category.clause);

        xhr = new XMLHttpRequest;
        xhr.open("GET", url);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    fromJSON(JSON.parse(xhr.responseText));
                } else {
                    error();
                }
                done();
            }
        }

        xhr.send();
        loading();
    }

    function purge () {
        category = null;
        if (xhr) xhr.abort();
        done();
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
            place.name = el.tags.name || label;
            place.tags = el.tags || {};
            append(place);
        }
    }
}
