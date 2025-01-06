import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtQuick.LocalStorage 2.7
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components 1.3



Page {
    id: root
    property real spinnerAngle: 0
	property string dbName: "CinieListDB"
	property string dbVersion: "1.0"
	property string dbDescription: "Database for CineList list app"
	property int dbEstimatedSize: 10000
	property var db: LocalStorage.openDatabaseSync(dbName, dbVersion, dbDescription, dbEstimatedSize)
	property string cineListTable: "CineList"
    property string tmdbAPIKey: "503625b1239efa916eb385ae4461e249"
    property string tmdbSearchURL: "https://api.themoviedb.org/3/search/movie?api_key=" + tmdbAPIKey + "&query="

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

    function searchMovie(term) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
		loader.visible=true
        noMovieFoundMessage.visible=false
        if (xhr.readyState === XMLHttpRequest.DONE) {
            // console.log("Response Code: " + xhr.status); // Log the status code

            if (xhr.status === 200) {
                // console.log("Response Text: ", xhr.responseText); // Log the response
                try {
                    var result = JSON.parse(xhr.responseText);
                    // console.log("Parsed result: ", result);

                    if (result.results && result.results.length > 0) {
					
                        var title =result.results[0].title
                        var overview=result.results[0].overview
                        var release_date=result.results[0].release_date
						var vote_average=result.results[0].vote_average
						var poster_path="https://image.tmdb.org/t/p/w400"+result.results[0].poster_path
						shoppinglistModel.addMovie(title,vote_average,release_date,poster_path,overview)
                        backgroundImage.visible=true
                    	loader.visible=false
                    } else {
                        console.log("No movies found.");
                        shoppinglistModel.clear()
                        noMovieFoundMessage.visible=true
                        backgroundImage.visible=false
                        loader.visible=false

                    }
                } catch (e) {
                    shoppinglistModel.clear()
                        noMovieFoundMessage.visible=true
                        loader.visible=false
                    console.error("Error parsing JSON: ", e);
                }
            } else {
                shoppinglistModel.clear()
               noMovieFoundMessage.visible=true
                console.error("Failed to fetch data. HTTP Status: " + xhr.status);
            }
        }
    };

    // console.log("Sending request to: " + tmdbSearchURL + encodeURIComponent(term));
    xhr.open("GET", tmdbSearchURL + encodeURIComponent(term), true);  // Ensure asynchronous
    xhr.send();
}

   
Timer {
        id: searchTimer
        interval: 1000  // Wait for 2 seconds (2000 milliseconds)
        running: false   // Initially not running
        repeat: false    // Run only once after the delay
        onTriggered: {
            if(textFieldInput.text.length>0){
                root.searchMovie(textFieldInput.text) // Trigger search after 2 seconds
            }else{
                backgroundImage.visible=false
                noMovieFoundMessage.visible=false
            }
            
        }
    }

    TextField {
        id: textFieldInput
        anchors {
            top: parent.top
            left: parent.left
            right:parent.right
            topMargin: units.gu(8)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
            
        }
        placeholderText: i18n.tr('Search Movies')
         onTextChanged: {
                searchTimer.stop()  // Stop the previous timer
                searchTimer.start() // Start the timer again
            }
    }

    Text {
    id:noMovieFoundMessage
    visible:false
    text: "Movie not available.Please try again."
    font.family: "Helvetica"
    font.pointSize: 12
    font.bold:true
    color: "red"
    anchors.top:textFieldInput.bottom
    anchors.topMargin:units.gu(3)
    anchors.horizontalCenter:parent.horizontalCenter
}

  

	 Rectangle {
        id: loader
        width: 50
        height: 50
        visible: false
        anchors.centerIn: parent
        color: "transparent"
        
        Canvas {
            id: spinningCanvas
            anchors.fill: parent

            onPaint: {
                var ctx = spinningCanvas.getContext("2d");
                var centerX = spinningCanvas.width / 2;
                var centerY = spinningCanvas.height / 2;
                var radius = 20;
                var lineWidth = 5;
                
                ctx.clearRect(0, 0, spinningCanvas.width, spinningCanvas.height);  // Clear the canvas
                
                // Set properties for the arc
                ctx.lineWidth = lineWidth;
                ctx.strokeStyle = "indigo";  // Color for the spinner
                
                // Draw the spinning arc
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI * (spinnerAngle / 360), false);
                ctx.stroke();
            }

            

            // Animate the spinner by updating the angle every frame
            Timer {
                interval:15
                running: true
                repeat: true
                onTriggered: {
                    spinningCanvas.requestPaint();  // Request to redraw the canvas
                    spinnerAngle += 5;  // Increase the angle for the animation
                    if (spinnerAngle >= 360) {
                        spinnerAngle = 0;  // Reset the angle after a full rotation
                    }
                }
            }
        }
     }
	ListModel {
	id: shoppinglistModel
    
	function addMovie(title,vote_average,release_date,poster_path,overview){
		shoppinglistModel.clear()
		shoppinglistModel.append({"title": title, "vote_average": vote_average, "release_date": release_date,"poster_path":poster_path,"overview":overview});
	// root.getItemPrice(shoppinglistModel.get(shoppinglistModel.count - 1));
	}
	// function removeSelectedItems(){
	// 	for(let i=shoppinglistModel.count-1;i>=0;i--){
	// 		if(shoppinglistModel.get(i).selected){
	// 			shoppinglistModel.remove(i)
	// 		}
	// 	}
	// }
} 
ListModel {
	id: movieListModel
    
	function addMovieToFavourite(title,vote_average,release_date,poster_path,overview){
		// shoppinglistModel.clear()
		movieListModel.append({"title": title, "vote_average": vote_average, "release_date": release_date,"poster_path":poster_path,"overview":overview});
	// root.getItemPrice(shoppinglistModel.get(shoppinglistModel.count - 1));
	}
}
 
    // ListView {
	// id: shoppinglistView
	// model: shoppinglistModel
	// function refresh(){
	// 	var temp=model;
	// 	model=null;
	// 	model=temp;
	// }
	// anchors {
	// 	top: textFieldInput.bottom
	// 	bottom: parent.bottom
	// 	left: parent.left
	// 	right: parent.right
	// 	topMargin: units.gu(3)
    //     bottomMargin: units.gu(3)
	// }
	
    
	// delegate: ListItem {
	// 	width: parent.width
	// 	height: root.height-(units.gu(10))
		
Image {
	id:backgroundImage
    source: shoppinglistModel.count > 0 ? shoppinglistModel.get(0).poster_path : ""
    anchors.top: textFieldInput.bottom
    anchors.bottom: root.bottom
    anchors.right: root.right
    anchors.left: root.left
    anchors.leftMargin: units.gu(2)
    anchors.rightMargin: units.gu(2)
    anchors.topMargin: units.gu(1)
    anchors.bottomMargin: units.gu(4)
    visible: shoppinglistModel.count > 0  // Only visible if there's a movie in the model

		Rectangle {
        id: addButton
        width: units.gu(8)  // Set the width to a desired size for the button
        height: width  // Make it circular by setting the height equal to the width
        radius: width / 2  // The radius will make it circular
        color: "indigo"
        anchors.right: parent.right
        anchors.rightMargin: units.gu(0.8)
        anchors.verticalCenter: parent.verticalCenter  // Align it vertically centered to the parent (image)

        Text {
            anchors.centerIn: parent
            text: "+"
            color: "white"
            font.pixelSize: units.gu(5)
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("Add button clicked")
				root.addMovie(shoppinglistModel.get(0).title, shoppinglistModel.get(0).vote_average)
				PopupUtils.open(informationPopUp)

                // Perform actions when the button is clicked (e.g., search for another movie)
            }
        }
    }

	        Rectangle {
            id: topRect
            width: parent.width
            height: units.gu(10)
            color:Qt.rgba(0, 0, 0, 0.5)  // Semi-transparent black
            anchors.top: backgroundImage.top
            anchors.left: backgroundImage.left
            anchors.right: backgroundImage.right

            Text {
                anchors.centerIn: parent
                text: shoppinglistModel.count > 0 ? shoppinglistModel.get(0).title + "\n" + shoppinglistModel.get(0).release_date + "\n" + "Rating: " + shoppinglistModel.get(0).vote_average +"/10" : ""
                color: "white"
                font.bold: true
                font.pixelSize: units.gu(2)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: bottomRect
            width: parent.width
            height: units.gu(12)
            color: Qt.rgba(0, 0, 0, 0.5)  // Semi-transparent black
            anchors.bottom: backgroundImage.bottom
            anchors.left: backgroundImage.left
            anchors.right: backgroundImage.right

            Text {
                anchors.fill: bottomRect
				anchors.leftMargin:units.gu(1)
                text: shoppinglistModel.count > 0 ? shoppinglistModel.get(0).overview : ""
                color: "white"
                font.pixelSize: units.gu(1.4)
                // horizontalAlignment: Text.AlignHCenter
                // verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                width: parent.width - units.gu(2)  // Prevent text from overflowing the screen
            }
        }

}

Component {
	id: informationPopUp
	
	Popup {
		
		title: i18n.tr("Movie Added Successfully")
		text: i18n.tr("Movie added to My List")
		onDoAction:console.log("dummy printing") 
	}
}







        
	
}

