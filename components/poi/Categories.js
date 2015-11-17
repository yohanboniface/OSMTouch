var groups = [
            {
                label: i18n.tr("Tourism"),
                elements: [
                    {label: i18n.tr("Restaurant"), clause: "[amenity=restaurant]", extraTags: 'cuisine'},
                    {label: i18n.tr("Bar"), clause: "[amenity=bar]"},
                    {label: i18n.tr("Cafe"), clause: "[amenity=cafe]"},
                    {label: i18n.tr("Pub"), clause: "[amenity=pub]"},
                    {label: i18n.tr("Fast food"), clause: "[amenity=fast_food]"},
                    {label: i18n.tr("Hotel"), clause: "[tourism=hotel]"},
                    {label: i18n.tr("Cinema"), clause: "[amenity=cinema]"},
                    {label: i18n.tr("Theatre"), clause: "[amenity=theatre]"},
                    {label: i18n.tr("Library"), clause: "[amenity=library]"},
                ]
            },
            {
                label: i18n.tr("Transports"),
                elements: [
                    {label: i18n.tr("Bicycle rental"), clause: "[amenity=bicycle_rental]"},
                    {label: i18n.tr("Railway station"), clause: "[railway=station]"},
                    {label: i18n.tr("Bus stop"), clause: "[highway=bus_stop]"},
                    {label: i18n.tr("Taxi"), clause: "[amenity=taxi]"},
                    {label: i18n.tr("Fuel"), clause: "[amenity=fuel]"},
                ]
            },
            {
                label: i18n.tr("Services"),
                elements: [
                    {label: i18n.tr("ATM"), clause: "[amenity=atm]"},
                    {label: i18n.tr("Post Office"), clause: "[amenity=post_office]"},
                    {label: i18n.tr("Post Box"), clause: "[amenity=post_box]"},
                    {label: i18n.tr("Bank"), clause: "[amenity=bank]"},
                    {label: i18n.tr("Toilets"), clause: "[amenity=toilets]"},
                    {label: i18n.tr("Recycling container"), clause: "[amenity=recycling][recycling_type=container]"},
                    {label: i18n.tr("Drinking Water"), clause: "[amenity=drinking_water]"},
                ]
            },
            {
                label: i18n.tr("Shopping"),
                elements: [
                    {label: i18n.tr("Organic shop"), clause: "[shop][organic=only]"},
                    {label: i18n.tr("Supermarket"), clause: "[shop=supermarket]"},
                    {label: i18n.tr("Bakery"), clause: "[shop=bakery]"},
                    {label: i18n.tr("Sea Food"), clause: "[shop=seafood]"},
                    {label: i18n.tr("Bicycle"), clause: "[shop=bicycle]"},
                ]
            },
            {
                label: i18n.tr("Health"),
                elements: [
                    {label: i18n.tr("Hospital"), clause: "[amenity=hospital]"},
                    {label: i18n.tr("Doctor"), clause: "[amenity=doctors]"},
                    {label: i18n.tr("Pharmacy"), clause: "[amenity=pharmacy]"},
                    {label: i18n.tr("Dentist"), clause: "[amenity=dentist]"},
                ]
            },
            {
                label: i18n.tr("Education"),
                elements: [
                    {label: i18n.tr("University"), clause: "[amenity=university]"},
                    {label: i18n.tr("College"), clause: "[amenity=college]"},
                    {label: i18n.tr("School"), clause: "[amenity=school]"},
                    {label: i18n.tr("Kindergarten"), clause: "[amenity=kindergarten]"},
                ]
            },
            {
                label: i18n.tr("Waterway"),
                elements: [
                    {label: i18n.tr("Harbour"), clause: "[harbour=yes]"},
                    {label: i18n.tr("Lock"), clause: "[lock=yes]", extraTags: 'lock_name,lock:VHF_channel,vhf_channel,lock:height,lock_ref'},
                    {label: i18n.tr("Boatyard"), clause: "[waterway=boatyard]"},
                ]
            }
];
var data = function () {
    var d = [], e;
    groups.forEach(function (group) {
        group.elements.forEach(function (e) {
            e.theme = group.label;
            d.push(e);
        });
    });
    return d;
}();
