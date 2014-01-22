/*
 * Copyright (C) 2013 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Nekhelesh Ramananthan <krnekhelesh@gmail.com>
 */

import QtQuick 2.0
import QtQuick.XmlListModel 2.0

// Xml model to retrieve user's current location based on geoIP
XmlListModel {
    id: geoIPModel;

    source: "http://geoip.ubuntu.com/lookup"
    query: "/Response"
    XmlRole { name: "city"; query: "City/string()"; isKey: true }
    XmlRole { name: "lat"; query: "Latitude/string()"; isKey: true }
    XmlRole { name: "lng"; query: "Longitude/string()"; isKey: true }
}
