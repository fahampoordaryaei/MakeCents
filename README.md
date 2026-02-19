
# MakeCents
**Student Finance Tracker Application**

# Features
  * **Overall UI/UX**
    * User-friendly GUI
    * Search bar with a dropdown list of features
  
  * **Core Buttons and Sections**
    * Balance and Analytics
    * Scholarships and loans
    * Points and Rewards
  
  * **Balance and Analytics**
    * Current balance with real-time tracking
    * Expense categories (e.g., food, rent, books)
    * Analytics page highlighting spending trends (e.g., “You spent 20% more on food.”)
	* Transaction logging
  
  * **Points**
    * Points earned based on variables such as:
      * grades-based (more points for higher grades)
	  * Meeting spending goals
    * Points can be redeemed via the scholarship/discount system for items/services
 
  * **Scholarship and Loans**
    * Grade-based eligibility
    * Personalised Scholarship Opportunities
 
  * **Safety System**
    * Login attempt counter
    * After 3 failed attempts: timed out for 5 minutes
    * Data stored in a secure AWS database

# Requirements
* [Flutter extension on VS Code](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
* [Android Studio](https://developer.android.com/studio)

# Installation
Android Studio:
* Open the SDK Manager (More Actions -> SDK Manager)
* Go to SDK Tools
* Install Android SDK Command-line Tools (latest)

Visual Studio Code:
* Open an integrated terminal in the folder containing the github repository.
* Type the following commands and follow instructions:
`flutter doctor`
`flutter doctor --android licenses`

To start-up the app:
* Launch the emulator
`flutter emulators`
* Copy the ID of the available emulator (something like `Phone_API`)
`flutter emulators --launch [emulator Id]`
* Run the app
`flutter run`

# Contributors

Project Manager
**Jaden Cushcieri**

Business Analysis
**Adam Azzopardi**

Software Development
**John Manfred Preddy**
**Faham Poordaryaei**

Security Design
**Abraham Okoro Chijioke**
**John Manfred Preddy**

Database Design
**Patrick Ofosuhene**