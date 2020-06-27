# Project 2 - *FlixApp*

**FlixApp** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **25** hours spent in total

## User Stories

The following **required** functionality is complete:

- [x] User sees an app icon on the home screen and a styled launch screen.
- [x] User can view a list of movies currently playing in theaters from The Movie Database.
- [x] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [x] User sees a loading state while waiting for the movies API.
- [x] User can pull to refresh the movie list.
- [x] User sees an error message when there's a networking error.
- [x] User can tap a tab bar button to view a grid layout of Movie Posters using a CollectionView.

The following **optional** features are implemented:

- [x] User can tap a poster in the collection view to see a detail screen of that movie
- [ ] User can search for a movie.
- [ ] All images fade in as they are loading.
- [x] User can view the large movie poster by tapping on a cell.
- [ ] For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- [ ] Customize the selection effect of the cell.
- [x] Customize the navigation bar.
- [x] Customize the UI.

The following **additional** features are implemented:

- [x] Added Wishlist, the ability to wishlist a movie to store it to your wishlist which is viewed on a tab bar.
- [x] DetailsView's background changes based on the prominent colors in the corresponding movie's backdrop image.

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Blocks and Closures were something I had to work with and had no idea what they were. I really want to know more about them.
2. Search Bar is something I did not have the time to explore and would like to sometime later.

## Video Walkthrough

Here's a walkthrough of implemented user stories:

[Video Walkthrough](https://i.imgur.com/vfwX2Nu.mp4)

GIF created with [Recordit](http://www.recordit.co).

## Notes

Describe any challenges encountered while building the app.

Implementing buttons on every single table view cell corresponding to a movie on that cell was really hard. Especially as iOS reuses objects including the buttons which did not help.

## Credits

List an 3rd party libraries, icons, graphics, or other assets you used in your app.

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - networking task library
- [Shoutout to the person on stackoverflow who wrote the code for extracting the prominent colors from an image.](https://stackoverflow.com/a/29266983)

## License

    Copyright [2020] [Nikesh Subedi]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
