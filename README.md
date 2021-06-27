# pixl

**pixl** is an iOS client app for **Unsplash** built using UIKit.

This app is developed on Xcode 12.5 and requires at least Swift version 5.4. To run the project in your machine, you need to download the project and open Pixl.xcodeproj. After opening the project, you need to add some environment variables and a url type.

First go to [Unsplash Developers](https://unsplash.com/developers) and apply for a new application to access Unsplash API. Make sure you add redirect uri (eg. `pixl-app://unsplash-authentication`) and mark all permissions.  After finished creating applications, go back to Xcode project that you have already opened. 

Then you need to add **Environment Variables** in your project scheme. Go select your project target from Xcode toolbar and select **Edit Scheme...**. Please select **Arguments** of **Run** and click "+" button in Environment Variables section to add variables. Add the values of ***access key***,  ***secret key*** and ***redirect uri*** from unsplash application with the names - **ACCESS_KEY**, **SECRET_KEY** and **REDIRECT_URI** respectively. 

The final thing is to add URL scheme in your project. Go to project target and select **Info** tab. In URL Types dropdown, click "+" button and add only the scheme of redirect uri (eg. `pixl-app`) that you provided in unsplash application. Then hit the run button and wait for your simulator.

Here are some snapshots of **pixl**.
| <img src="https://github.com/dscyrescotti/Pixl/blob/main/Assets/LoginView.png?raw=true" alt="Login View"/> | <img src="https://github.com/dscyrescotti/Pixl/blob/main/Assets/PhotosView.png?raw=true" alt="Photos View"/> | <img src="https://github.com/dscyrescotti/Pixl/blob/main/Assets/CollectionsView.png?raw=true" alt="Collections View"/> | 
|--|--|--|
| <img src="https://github.com/dscyrescotti/Pixl/blob/main/Assets/CollectionView.png?raw=true" alt="Collection View"/> | <img src="https://github.com/dscyrescotti/Pixl/blob/main/Assets/PhotoView.png?raw=true" alt="Photo View"/> | <img src="https://github.com/dscyrescotti/Pixl/blob/main/Assets/UserView.png?raw=true" alt="User View"/> |
| <img src="https://github.com/dscyrescotti/Pixl/blob/main/Assets/BrowseView.png?raw=true" alt="Browse View"/> | <img src="https://github.com/dscyrescotti/Pixl/blob/main/Assets/SearchResultsView.png?raw=true" alt="Search Results View"/> | <img src="https://github.com/dscyrescotti/Pixl/blob/main/Assets/SettingsView.png?raw=true" alt="Settings View"/> |

# License
**pixl** is available under the MIT license. See the [LICENSE](https://github.com/dscyrescotti/Pixl/blob/main/LICENSE) file for more info.