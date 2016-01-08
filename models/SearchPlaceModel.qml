import QtQuick 2.0
import Ubuntu.Components 0.1
import QtQuick.XmlListModel 2.0

XmlListModel {

    readonly property string searchUrl: "http://open.mapquestapi.com/nominatim/v1/search.php?format=xml&q="
    readonly property int limit: 10
    property string searchString: "paris"

    function search() {
        source = (searchUrl + searchString + "&limit=" + limit + "&viewbox=" + map.toBboxString());
    }

    function clear() {
        source = "";
    }

    source: ""
    query: "/searchresults/place"

    XmlRole { name: "name"; query: "@display_name/string()"; isKey: true }
    XmlRole { name: "lat"; query: "@lat/string()"; isKey: true }
    XmlRole { name: "lng"; query: "@lon/string()"; isKey: true }

}
