import QtQuick 2.0
import Ubuntu.Components 0.1
import QtQuick.XmlListModel 2.0

XmlListModel {

    readonly property string baseUrl: "http://api.openstreetmap.fr/oapi/xapi?node[bbox={bbox}]{clause}"
    property string clause: ""
    property string label: ""

    function search (bbox) {
        if (clause === "") {
            return;
        }
        var url = baseUrl;
        url = url.replace('{bbox}', bbox);
        url = url.replace('{clause}', clause);
        console.log(url);
        source = url;
    }

    function clear () {
        clause = "";
        source = "";
    }

    function isActive () {
        return source != "";
    }

    source: ""
    query: "/osm/node"

    XmlRole { name: "osm_id"; query: "@id/string()"; }
    XmlRole { name: "name"; query: "tag[@k='name']/@v/string()"; }
    XmlRole { name: "phone"; query: "tag[@k='phone']/@v/string()"; }
    XmlRole { name: "website"; query: "tag[@k='website']/@v/string()"; }
    XmlRole { name: "cuisine"; query: "tag[@k='cuisine']/@v/string()"; }
    XmlRole { name: "wheelchair"; query: "tag[@k='wheelchair']/@v/string()"; }
    XmlRole { name: "lat"; query: "@lat/string()"; }
    XmlRole { name: "lng"; query: "@lon/string()"; }

}
