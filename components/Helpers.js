function formatDistance (distance) {
    if (distance < 1000) {
        return Math.round(distance) + " m";
    } else {
        return round(distance / 1000, 1) + " km"
    }
}

function round(value, digits){
    return (Math.round((value*Math.pow(10,digits)).toFixed(digits-1))/Math.pow(10,digits)).toFixed(digits);
}

function cleanPhoneNumber (s) {
    return s.replace(/\(\d*\)/g, '').replace(/[^\d+]/g, '');
}

function getIcon (name) {
    return Qt.resolvedUrl("/usr/share/icons/ubuntu-mobile/actions/scalable/" + name + ".svg");
}
