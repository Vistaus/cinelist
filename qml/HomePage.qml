
import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtQuick.LocalStorage 2.7
import Ubuntu.Components.Popups 1.3
// import Lomiri.Components 1.3

Page{
id:root
property string tmdbAPIKey: "503625b1239efa916eb385ae4461e249"
property int movieCount:0
property string dbName: "CinieListDB"
property string dbVersion: "1.0"
property string dbDescription: "Database for CineList list app"
property int dbEstimatedSize: 10000
property var db: LocalStorage.openDatabaseSync(dbName, dbVersion, dbDescription, dbEstimatedSize)
property string cineListTable: "CineList"
// property array  movieArray:[]

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


function fetchPopularMovies() {
    // TMDb API Key
    // const tmdbAPIKey = "tmdbAPIKey";  // Replace with your actual API key
    
    // Base URL for the popular movies endpoint
    const url = `https://api.themoviedb.org/3/movie/popular?api_key=${tmdbAPIKey}&language=en-US&page=1`;  // You can change `page` if needed

    // Create a new XMLHttpRequest
    const xhr = new XMLHttpRequest();

    // Define the request behavior when the state changes
    xhr.onreadystatechange = function() {
        let movieArray=[]
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    // Parse the JSON response
                    const result = JSON.parse(xhr.responseText);
                    
                    // Check if movies are available in the result
                    if (result.results && result.results.length > 0) {
                      result.results.forEach(movie => {
                            // Log detailed properties of each movie
                            // console.log("Title: " + movie.title);
                            // console.log("Release Date: " + movie.release_date);
                            // console.log("Overview: " + movie.overview);
                            // console.log("Popularity: " + movie.popularity);
                            // console.log("Vote Average: " + movie.vote_average);
                            // console.log("Poster Path: " + movie.poster_path);  // For image URL construction
                            // console.log("----------------------------------------");
                            let movieObject={
                               title: movie.title,
                             release_date: movie.release_date,
                              overview: movie.overview,
                        popularity: movie.popularity,
                        vote_average: movie.vote_average,
                        poster_path: "https://image.tmdb.org/t/p/w500"+movie.poster_path
                            }
                            movieArray.push(movieObject)
                        });
                        console.log("final result",movieArray)
                          console.log("final result",movieArray[0].title)
                          console.log("final result",movieArray[0])
                          for(let i=0;i<movieArray.length;i++){
                            homeMoviesModel.changeMovieInList(movieArray[i].title,movieArray[i].vote_average,movieArray[i].release_date,movieArray[i].poster_path,movieArray[i].overview);
                          }
                          
                    } else {
                        console.log("No popular movies found.");
                    }
                } catch (e) {
                    console.error("Error parsing JSON: ", e);
                }
            } else {
                console.error("Failed to fetch data. HTTP Status: " + xhr.status);
            }
        }
    };

    // Open the GET request with the constructed URL
    xhr.open("GET", url, true);
    
    // Send the request
    xhr.send();
}



   
  Component.onCompleted: {
        
        fetchPopularMovies();
        // console.log("Hello world",homeMoviesModel.get(0).title)
                // homeMoviesModel.changeMovieInList(movieArray[0].title,movieArray[0].vote_average,movieArray[0].release_date,movieArray[0].poster_path,movieArray[0].overview)
		//  homeMoviesModel.clear()
		//  homeMoviesModel.append({"title": title, "vote_average": vote_average, "release_date": release_date,"poster_path":poster_path,"overview":overview});
	// root.getItemPrice(shoppinglistModel.get(shoppinglistModel.count - 1));
	}



    ListModel {
	id: homeMoviesModel
    
	function changeMovieInList(title,vote_average,release_date,poster_path,overview){
        console.log("yes im ececutin",title,poster_path)
		// homeMoviesModel.clear()
		homeMoviesModel.append({"title": title, "vote_average": vote_average, "release_date": release_date,"poster_path":poster_path,"overview":overview});
        console.log("jj",homeMoviesModel.get(movieCount).title)
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
Image {
    id:homePage
	// id:backgroundImage
    source: homeMoviesModel.count > 0 ? homeMoviesModel.get(movieCount).poster_path : ""
    anchors.fill:parent
    visible: homeMoviesModel.count > 0  // Only visible if there's a movie in the model


        Rectangle {
        id: previousMovie
        width: units.gu(8)  // Set the width to a desired size for the button
        height: width  // Make it circular by setting the height equal to the width
        radius: width / 2  // The radius will make it circular
        color: "green"
        anchors.bottom:addButton.top
        anchors.bottomMargin:units.gu(1)
        anchors.right: parent.right
        anchors.rightMargin: units.gu(0.8)
        // anchors.verticalCenter: parent.verticalCenter  // Align it vertically centered to the parent (image)

        Text {
            anchors.centerIn: parent
            text: "<"
            color: "white"
            font.pixelSize: units.gu(5)
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                
                console.log("Add button clicked")
				root.movieCount-=1

                // Perform actions when the button is clicked (e.g., search for another movie)
            }
        }
    }


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
				root.addMovie(homeMoviesModel.get(movieCount).title, homeMoviesModel.get(movieCount).vote_average)
				PopupUtils.open(informationPopUp)

                // Perform actions when the button is clicked (e.g., search for another movie)
            }
        }
    }

        Rectangle {
        id: negativeButton
        width: units.gu(8)  // Set the width to a desired size for the button
        height: width  // Make it circular by setting the height equal to the width
        radius: width / 2  // The radius will make it circular
        color: "red"
        anchors.top:addButton.bottom
        anchors.topMargin:units.gu(1)
        anchors.right: parent.right
        anchors.rightMargin: units.gu(0.8)
        // anchors.verticalCenter: parent.verticalCenter  // Align it vertically centered to the parent (image)

        Text {
            anchors.centerIn: parent
            text: "x"
            color: "white"
            font.pixelSize: units.gu(4)
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                negativeButton.color="transparent"
                console.log("negative button clicked")
                console.log("movie count first prionting:",movieCount)
                negativeButton.color="red";
				
                root.movieCount+=1;
                console.log("movieCount:",movieCount)
               
            }
        }
    }


        Rectangle {
            id: bottomRect
            width: parent.width
            height: units.gu(20)
            color: Qt.rgba(0, 0, 0, 0.5)  // Semi-transparent black
            anchors.bottom: homePage.bottom
            anchors.left: homePage.left
            anchors.right: homePage.right
            Text{
                id:movieTitle
                text:homeMoviesModel.count > 0 ? homeMoviesModel.get(movieCount).title : ""
                anchors.top:bottomRect.top
                anchors.left:bottomRect.left
                 font.pointSize: 12
                anchors.right:bottomRect.right
                anchors.leftMargin:units.gu(1)
                anchors.topMargin:units.gu(1)
                font.bold:true
                color:"white"
                wrapMode: Text.WordWrap
                width: parent.width - units.gu(2)

            }
            Text {
                id:subHeading
                anchors.top: movieTitle.bottom
                 anchors.right:bottomRect.right
                  anchors.left:bottomRect.left
                anchors.topMargin:units.gu(1)
				anchors.leftMargin:units.gu(1)
                text: homeMoviesModel.count > 0 ? homeMoviesModel.get(movieCount).release_date +"| Rating :"+homeMoviesModel.get(movieCount).vote_average : ""
                color: "white"
                font.pointSize: 10
                font.bold:true
                // font.pixelSize: units.gu(1.4)
                // horizontalAlignment: Text.AlignHCenter
                // verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                width: parent.width - units.gu(2)  // Prevent text from overflowing the screen
            }
            Text {
                anchors.top: subHeading.bottom
                anchors.right:bottomRect.right
                  anchors.left:bottomRect.left
                anchors.topMargin:units.gu(1)
				anchors.leftMargin:units.gu(1)
                text: homeMoviesModel.count > 0 ? homeMoviesModel.get(movieCount).overview : ""
                color: "white"
                font.pixelSize: units.gu(1.4)
                // horizontalAlignment: Text.AlignHCenter
                // verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                width: parent.width - units.gu(2)  // Prevent text from overflowing the screen
            }
        }

}












//tabs of the page
    Rectangle{
        id:tabRactangle
        height:units.gu(5)
        width:parent.width
        anchors.bottom:parent.bottom
        anchors.right:parent.right
        anchors.left:parent.left
        color:"lavender"

        Row {
        anchors.fill: tabRactangle
        spacing: 20
        z:1

        // First Button with image URL
        Button {
            // text: "Button 1"
            id:bookmark
            anchors.left:parent.left
            width: parent.width / 3  // Set width to 1/3 of parent width
            height: parent.height
            color:"lavender"
            onClicked: {
                searchPage.visible=false
                homePage.visible=false
                listPage.visible=true
            }

            Image {
                anchors.centerIn: parent
                source: "../assets/bookmark.png"  // Replace with your image URL
                fillMode: Image.PreserveAspectFit
                height:units.gu(3)
                width:units.gu(3)
                
            }
        }

        // Second Button with image URL
        Button {
            id:home
            anchors.left:bookmark.right
            width: parent.width / 3  // Set width to 1/3 of parent width
            height: parent.height
            color:"lavender"
            // borderColor:"lavender"
            onClicked: {
                homePage.visible=true
                listPage.visible=false
                searchPage.visible=false
            }

            Image {
                anchors.centerIn: parent
                source: "../assets/home.png"   // Replace with your image URL
                fillMode: Image.PreserveAspectFit
                height:units.gu(3)
                width:units.gu(3)
                
            }
        }

        // Third Button with image URL
        Button {
            // text: "Button 3"
            anchors.left:home.right
            width: parent.width / 3  // Set width to 1/3 of parent width
            height: parent.height
            color:"lavender"
            onClicked: {
                searchPage.visible=true
                homePage.visible=false
                listPage.visible=false
            }

            Image {
                anchors.centerIn: parent
                source: "../assets/search.png" // Replace with your image URL
                fillMode: Image.PreserveAspectFit
                height:units.gu(3)
                width:units.gu(3)
                
            }
        }
    }

    }

    ListingPage{
    id:listPage
    visible:false

  
 
    anchors.fill:parent
       
}
 SearchPage{
        id:searchPage
        anchors.fill:parent
        visible:false

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