function getDatabase() {
     return LocalStorage.openDatabaseSync("osmtouch", "0.1", "history", 100);
}

function init () {
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS history(id INTEGER PRIMARY KEY, name TEXT, lat FLOAT, lng FLOAT)');
   });
}

function reset () {
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql('DROP TABLE history;');
   });
}

function push(name, lat, lng) {
    var db = getDatabase(),
    res = 0;
    db.transaction(function(tx) {
        // We doesn't want twice the same result in history, and when doing twice the same
        // search and click, we want it to turn first on the history list again.
        tx.executeSql('DELETE FROM history WHERE name=? AND lat=? AND lng=?;', [name, lat, lng]);
        var rs = tx.executeSql('INSERT OR REPLACE INTO history (name, lat, lng) VALUES (?,?,?);', [name,lat,lng]);
        if (rs.rowsAffected > 0) {
            res = 1;
        }
        tx.executeSql('DELETE FROM history ORDER BY id desc LIMIT -1 OFFSET 20;');
    });
    return res;
}

function pull(limit) {
    var db = getDatabase(),
        res = [];
    limit = limit || 10;
    try {
        db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT name, lat, lng FROM history ORDER BY id DESC LIMIT ?;', [limit]);
            if (rs.rows.length > 0) {
                res = rs.rows;
            }
        });
    } catch (err) {
        console.log("Database Error: " + err);
    };
    return res
}
