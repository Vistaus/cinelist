/*
 * Copyright (C) 2024  jj
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * cinelist is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
// import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.7

MainView {
    id: root
    property string dbName: "CinieListDB"
	property string dbVersion: "1.0"
	property string dbDescription: "Database for CineList list app"
	property int dbEstimatedSize: 10000
	property var db: LocalStorage.openDatabaseSync(dbName, dbVersion, dbDescription, dbEstimatedSize)
	property string surveyTable: "survey"
    objectName: 'mainView'
    applicationName: 'cinelist.jj'
    automaticOrientation: true
    
     function addStatus(status) {
        console.log("yes executing")
	db.transaction(function(tx) {
			
			tx.executeSql('CREATE TABLE IF NOT EXISTS ' + surveyTable + ' (status boolean)');
			var result = tx.executeSql('INSERT INTO ' + surveyTable + ' (status) VALUES( ? )', [status]);
			console.log("success")
			// var rowid = Number(result.insertId);
			// shoppinglistModel.append({"rowid": rowid, "name": name, "price": 0, "selected": selected});
			// getItemPrice(shoppinglistModel.get(shoppinglistModel.count - 1));
		}
	)
}

    function checkSurvayStatus() {
	db.transaction(function(tx) {
			
			tx.executeSql('CREATE TABLE IF NOT EXISTS ' + surveyTable + ' (status boolean)');
			var results = tx.executeSql('SELECT rowid, status FROM ' + surveyTable);
            if(results.rows.length>0){
                surveyPage.visible=false
                homePage.visible=true
            }
			console.log(success)
			// var rowid = Number(result.insertId);
			// shoppinglistModel.append({"rowid": rowid, "name": name, "price": 0, "selected": selected});
			// getItemPrice(shoppinglistModel.get(shoppinglistModel.count - 1));
		}
	)
}
    width: units.gu(45)
    height: units.gu(75)

    Page {
    id:firstPage
    visible: true
    anchors.fill: parent

    

    // statusBar:null

   
Image {
    id: rootImage
    source: "../assets/icon.png"
    width: units.gu(50)   // Set the width of the image
    height: units.gu(50)  // Set the height of the image
    anchors.centerIn: parent  // Center the image within the parent
}

Text {
    id:initialLogoText
    anchors.bottom: rootImage.bottom  // Anchor the bottom of the text just above the image
    anchors.horizontalCenter: parent.horizontalCenter  // Center the text horizontally
    anchors.bottomMargin: units.gu(3)  // Margin between the image and the text
    // anchors.leftMargin:units.gu(3)
    width: parent.width * 0.8  // Set text width to 80% of the parent width
    wrapMode: Text.Wrap  // Allow text to wrap if it exceeds the width
    text: "We help you to discover movies tailored to your taste"
    font.family: "Helvetica"
    font.pointSize: 14
    color: "indigo"
    z: 1
}

 Button {
    anchors.top: initialLogoText.bottom
    anchors.topMargin:units.gu(3)
    anchors.horizontalCenter: parent.horizontalCenter 
    color:"indigo"
	text: i18n.tr('Lets Go')
    onClicked: {
        firstPage.visible=false
        surveyPage.visible=true
        root.checkSurvayStatus()
    }
    // highlighted : true
}



}

    
           
Page {
    id: surveyPage
    visible: false  // Set the page to be visible, or toggle visibility based on the user's action


//    orientation: Qt.Vertical 

    // width:parent.width
    ScrollView {
    width: parent.width

    height: parent.height
Column{
    width:surveyPage.width
    Text {
    id: headingText
    text: "Let's Get to Know Your Movie Taste!"
    anchors.top: surveyPage.top  // Anchors the heading to the top of the parent container
    width: surveyPage.width * 1.0  // Set text width to 80% of the parent width
    wrapMode: Text.Wrap 
    anchors.horizontalCenter: surveyPage.horizontalCenter  // Centers the text horizontally
    anchors.topMargin: units.gu(2)  // Adds margin from the top of the parent container
   
    // width: surveyPage.width * 1.0
    // wrapMode: Text.Wrap
    color: "red"
    font.pixelSize: 24  // Optional: Adjust font size if needed
}

    // Name input field
    Text {
        id:text
        text: "What is your name ?"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top  // Place the text at the top of the parent
        anchors.topMargin: units.gu(8)  // Adds margin from the top of the parent container
         color:"indigo"
    }

   TextField {
    id: nameField
    placeholderText: "Enter your name"
    anchors.top: text.bottom  // Anchors the TextField below the Text element
    anchors.left: surveyPage.left  // Align the TextField to the left of the parent
    anchors.right: surveyPage.right  // Align the TextField to the right of the parent
    // anchors.topMargin: units.gu(2)  // Optional: Add margin between Text and TextField
    color: "indigo"
    width: surveyPage.width * 1.0 // Set the width to 80% of the parent width
    font.pixelSize:14 // Optional: Increase font size for better visibility
}

    // Age input field
    Text {
        id:ageText
        text: "What is your age ?"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: nameField.bottom  // Anchors below the name input field
        anchors.topMargin: units.gu(2)
        color:"indigo"
    }

    TextField {
        id: ageField
        placeholderText: "Enter your age"
        anchors.top: ageText.bottom  // Anchors the age field below the "What is your age?" text
        anchors.left: surveyPage.left
        anchors.right: surveyPage.right
         color:"indigo"
          width: surveyPage.width * 1.0
        // anchors.topMargin: units.gu(2)
    }

     
    

    // Gender selection (Example Row for radio buttons or combo box)
    Row {
        id:favoriteGesturesText
        anchors.top: ageField.bottom
        anchors.left: parent.left
        spacing: units.gu(2)
        anchors.topMargin: units.gu(2)

        Text {
            
            text: "Favorite Getures:"
            anchors.verticalCenter: parent.verticalCenter
            color:"indigo"
        }
        
        // ComboBox {  // Example combo box for gender selection
        //     id: genderComboBox
        //     model: ["Male", "Female", "Other"]
        //     anchors.verticalCenter: parent.verticalCenter
        // }
    }

     Text {
        id:favoriteActorText
        text: "Favorite Actor:"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: favoriteGesturesText.bottom  // Anchors below the name input field
        anchors.topMargin: units.gu(4)
        color:"indigo"
    }

    TextField {
        id: actorField
        placeholderText: "Type Your Actor"
        anchors.top: favoriteActorText.bottom  // Anchors the age field below the "What is your age?" text
        anchors.left: surveyPage.left
        anchors.right: surveyPage.right
         color:"indigo"
          width: surveyPage.width * 1.0
        //   borderColor:"indigo"
        // anchors.topMargin: units.gu(2)
    }

     Text {
        id:recomendedMovieText
        text: "What's the one movie you would recomended to someone who's never seen it?"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: actorField.bottom  // Anchors below the name input field
        anchors.topMargin: units.gu(4)
        width: surveyPage.width * 1.0  // Set text width to 80% of the parent width
        wrapMode: Text.Wrap 
        color:"indigo"
    }

    TextField {
        id: recomendedeMovieField
        placeholderText: "Type your recomendation"
        anchors.top: recomendedMovieText.bottom  // Anchors the age field below the "What is your age?" text
        anchors.left: surveyPage.left
        anchors.right: surveyPage.right
         color:"indigo"
          width: surveyPage.width * 1.0
        //   borderColor:"indigo"
        // anchors.topMargin: units.gu(2)
    }

         Text {
        id:whatchAgainText
        text: "What's the one movie you wish you could experience for the first time again?"
        anchors.left: parent.left
        anchors.right: parent.right
        width: surveyPage.width * 1.0  // Set text width to 80% of the parent width
        wrapMode: Text.Wrap 
        anchors.top: recomendedeMovieField.bottom  // Anchors below the name input field
        anchors.topMargin: units.gu(4)
        color:"indigo"
    }

    TextField {
        id: whatchAgainField
        placeholderText: "Type your answer"
        anchors.top: whatchAgainText.bottom  // Anchors the age field below the "What is your age?" text
        anchors.left: surveyPage.left
        anchors.right: surveyPage.right
         color:"indigo"
          width: surveyPage.width * 1.0
        //   borderColor:"indigo"
        // anchors.topMargin: units.gu(2)
    }
   // Submit button
    Button {
        text: "Submit"
        anchors.top: whatchAgainField.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: units.gu(3)
        width:surveyPage.width
        color:"indigo"
        onClicked: {
            // Collect the user's information
            var name = nameField.text
            var age = ageField.text
            // var gender = genderComboBox.currentText
            console.log("Name:", name)
            console.log("Age:", age)
            surveyPage.visible=false
            homePage.visible=true
            root.addStatus(true);
            // console.log("Gender:", gender)

            // Navigate to the results page (for example)
            // stackView.push(resultsPage)
        }
    }

}
}
}

HomePage{
    id:homePage
    visible:false
    anchors.fill:parent
    header: PageHeader {
	id: header
    Image{
        id:pageHeaderImage
        anchors.right:parent.right
        anchors.top:parent.top
        anchors.bottom:parent.bottom
         width: units.gu(10)  
         height: units.gu(10) 
        source:"../assets/icon.png"
    }
	title: i18n.tr('Cineist')
	subtitle: i18n.tr('Never forget your movies')
	StyleHints {
		foregroundColor:"indigo"
	}
}
}
}


