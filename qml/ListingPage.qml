import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtQuick.LocalStorage 2.7


    Page{
        id:testing
         visible:true

        property string dbName: "CinieListDB"
	    property string dbVersion: "1.0"
	    property string dbDescription: "Database for CineList list app"
	    property int dbEstimatedSize: 10000
	    property var db: LocalStorage.openDatabaseSync(dbName, dbVersion, dbDescription, dbEstimatedSize)
	    property string cineListTable: "CineList"

        function addMovie(title, rating) {
	db.transaction(function(tx) {
			
			tx.executeSql('CREATE TABLE IF NOT EXISTS ' + cineListTable + ' (title TEXT, rating double)');
			var result = tx.executeSql('INSERT INTO ' + cineListTable + ' (title, rating) VALUES( ?, ? )', [title, rating]);
			console.log(result)
			// var rowid = Number(result.insertId);
			// shoppinglistModel.append({"rowid": rowid, "name": name, "price": 0, "selected": selected});
			// getItemPrice(shoppinglistModel.get(shoppinglistModel.count - 1));
		}
	)
}
         anchors.fill: parent
    function testingfunction(){
        console.log("Hello World");
        movieListModel.clear()
        db.transaction(function(tx) {
			tx.executeSql('CREATE TABLE IF NOT EXISTS ' + cineListTable + ' (title TEXT, rating double)');
			var results = tx.executeSql('SELECT rowid, title, rating FROM ' + cineListTable);
            if(results.rows.length<1){
                noMovies.visible=true
            }else{
                noMovies.visible=false
            }
			// Update ListModel
			for (var i = 0; i < results.rows.length; i++) {
				movieListModel.append({"rowid": results.rows.item(i).rowid,
											"title": results.rows.item(i).title,
											"rating": results.rows.item(i).rating,
											
										});
				// getItemPrice(shoppinglistModel.get(shoppinglistModel.count - 1));
			}
		}
	)
    }

   function removeMovieFromDB(index) {
    var rowid = movieListModel.get(index).rowid;
    console.log("yes executing",rowid)
     movieListModel.remove(index)
    db.transaction(function(tx) {
        // Execute DELETE query to remove the record with the specified rowid
        tx.executeSql('DELETE FROM ' + cineListTable + ' WHERE rowid = ?', [rowid], function(tx, result) {
            console.log("Record deleted successfully!");
            movieListModel.remove(index)
        }, function(tx, error) {
            console.error("Error deleting record: " + error.message);
           
        });
        
        // Optionally, update the ListModel to reflect changes in the database
        // var results = tx.executeSql('SELECT rowid, title, rating FROM ' + cineListTable);

        // Clear the current movie list model before updating it
        // movieListModel.clear();

        // Update ListModel with remaining records after deletion
        // for (var i = 0; i < results.rows.length; i++) {
        //     movieListModel.append({
        //         "rowid": results.rows.item(i).rowid,
        //         "title": results.rows.item(i).title,
        //         "rating": results.rows.item(i).rating
        //     });
        // }
    });
}   

Text{
    id:noMovies
    visible:false
    anchors.centerIn:parent
    text:"No Movies"
    color:"red"
}

    Text{
        id:heading
        anchors.top:parent.top
        anchors.horizontalCenter:parent.horizontalCenter
        anchors.topMargin:units.gu(8)
        text:"My List"
        color:"black"
        font.bold:true
        font.pixelSize:24


    }

    ListModel {
	id: movieListModel
    
	function addMovieToFavourite(title,vote_average,release_date,poster_path,overview){
		// shoppinglistModel.clear()
		// movieListModel.append({"title": title, "vote_average": vote_average, "release_date": release_date,"poster_path":poster_path,"overview":overview});
	// root.getItemPrice(shoppinglistModel.get(shoppinglistModel.count - 1));
	}
}



    ListView {
	id: movieListView
	model:movieListModel
	function refresh(){
		var temp=model;
		model=null;
		model=temp;
	}
	anchors {
		top: parent.top
		bottom: parent.bottom
		left: parent.left
		right: parent.right
		topMargin: units.gu(12)
        bottomMargin: units.gu(5)
	}
	
    
	delegate: ListItem {
		width: parent.width
		height: units.gu(3)
// 		CheckBox {
// 	id: itemCheckbox
// 	visible: root.selectionMode
// 	checked:shoppinglistModel.get(index).selected
// 	anchors {
// 		left: parent.left
// 		leftMargin: units.gu(2)
// 		verticalCenter: parent.verticalCenter
// 	}
// }
Text {
	id: itemText
	text: title
	anchors {
		left:  parent.left
		leftMargin:  units.gu(2)
		verticalCenter: parent.verticalCenter
        // font.pixelSize: 24
	}
}
Text{
	text:rating+"/10"
	anchors.right:parent.right
	anchors.rightMargin:units.gu(2)
	anchors.verticalCenter:parent.verticalCenter
}

 leadingActions: ListItemActions{
	actions: [
		Action {
			iconName: "delete"
			onTriggered:{
                // movieListModel.remove(index)
                testing.removeMovieFromDB(index)
                // console.log(movieListModel.get(index))

            } 
		}
	]
}
	}
}
 onVisibleChanged: {
            if (listPage.visible) {
                testing.testingfunction(); // Call testingfunction when visible is true
            }
        }
    }
