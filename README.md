# Illusions

## General
This exhibit shows three types of illusions, according to a value in its config, that show some kind of visual, and allow changing parameters with sliders.

The tree types of illusions shown are:
- **Dots:** Shows three dots over a turning circle pattern. By focusing on the center, the dots appear to disappear. The size of the dots and speed of turning can be changed to see how the illusion changes accordingly.
- **Sphere:** Shows a sphere drawn by several dots (and not the entire sphere) moving, giving the feeling of a sphere turning. However, it can appear turning to both ways. The number of dots and speed of turning can be changed to see how the illusion chnages accordingly. A stop button allows to breifly stopping the animation, showing the effect fades completely on stop.
- **Bio-Motion**: Arrow buttons can be used to switch between different characters anaimations comprised of dots only. The dots number and the speed of the animation can be changed to see when of a character movement appears. A stop button allows to breifly stopping the animation, showing the effect fades completely on stop.

The ehibit supports Hebrew, English and Arabic and allows to change languages with buttons.
It is designed to work with a computer connected to a screen and a mouse.

## Installation & Run
The exhibit runs using haxeflixel and the Haxe language  on linux.
To be able to compile the linux version, Haxe, and then haxeflixel must be installed.

First, install haxe with:

```
sudo add-apt-repository ppa:haxe/releases -y
sudo apt-get update
sudo apt-get install haxe -y
```

Then, install haxeflixel with these commands:

```
haxelib install lime
haxelib run lime setup
haxelib install openfl
haxelib run openfl setup
haxelib install flixel
haxelib run flixel setup
```

Finally, you can build a linux binary by running this command from the root of the project directory:

```
lime test linux
```

Then, just run the linux binaries that are created under the export directory.
You can then simply copy them to the target machine or save them for future use, there's no need to install haxe on machines running them.

## Config
The exhibit supports a vast array of configurations using a config json file located in assets/data/config.json.
Thre's also a version for French, Spanish and English languages used in Paris, located in assets/data/config-paris-french-spanish-english.json.

Following is a complete description of all options.

### maxLogFiles, maxRowsPerLogFile

These specify the rolling behaviour of the log.
maxRowsPerLogFile is the rows number for each log file, causing it to roll to the next numbered log file (i.e. from illusions_log_1.txt to illusions_log_2.txt).
maxRowsPerLogFile specifies the max number of files, after which it goes back to the oldest and overwrites it. See more details in log section.

Specifies the default language loaded on startup (he/en/ar).
Note that the prefix to put here should be identical to the prefix defined in the language array (see details below).

### infoX, infoY, stopButtonWidth, stopButtonHeigh, stopButtonX, stopButtonY

These are all graphical properties to set the position of the info and stop buttons, and the width and height of the stop button (as the art is larger than the active button part).
These should not change unless the exhibit art changes.
X and Y are positive to the right and from top to bottom respectively.

### firstLanguageX, languageY, languageSpacing

These set the positions of the language buttons.
firstLanguageX is the x of the first button, languageY is the y of all buttons, and languageSpacing is the space between each language x.
The languages themselves are set in the languages part, see below.
X and Y are positive to the right and from top to bottom respectively.

### idleSecondsAllowed

The number of seconds until the exhibit restarts the sliders into their starting positions and updates the illusion accordingly.

### handCursorOffsetX, handCursorOffsetY

The offset between the top left position of the cursor graphics to where it should respond to the click, in both X and Y.
This allows the click to correspond to a hand graphic that doesn't point on the top left corner necessarily.
This should not be changed unless the cursor art is changed.
X and Y are positive to the right and from top to bottom respectively.

### languages

This represents the array of all languages supported by the system.
Each language object provides the id (a number), to be used as the startLnaguageId (see below), an rtl key specifying 1 if language is right-to-left or 0 otherwise,
and all the graphics filenames for spritesheets of texted buttons and screens (background and info): buttonSpritesheet is the spritesheet for the language button states, stopSpritesheet is the spritesheet for the stop button states, backgroundImage and infoImage are the background and info graphics with text embedded respectively, and infoSpritesheet is the spritesheet for all info button states.

Here's an example language object defintiion:

```
{
    "id": 1,
    "rtl": 1,
    "buttonSpritesheet": "arabicSpritesheet",
    "stopSpritesheet": "stopArabic",
    "backgroundImage": "backgroundArabic",
    "infoSpritesheet": "infoSpritesheet",
    "infoImage": "arabicInfo"
}
```

### startLanguageId

Specifies the language id (as defind in the languages array) for which the exhibit starts with.

### illusionName

Specifies which illusion should be run. Can be either dots, sphere or biomotion (see general section for details).

### sliders

Defines an array of sliders positions and dimensions: the top left corner (keys x and y) and the width and height.
X and Y are positive to the right and from top to bottom respectively.

Here's an example slider object definition:

```
{
    "x": 1426,
    "y": 369,
    "width": 100,
    "height": 377
}
```

### illusions

This array specifies a config for each illusion supported (i.e. dots, sphere or biomotion).
Each illusion object has some set properties, and also an exxtra configuration part, specific to that illusion.
We will now cover both the set properties, and then the extra configuration for each illusion.

#### set properties

Each illusion object specifies its name (which must match the illusionName property for the exhibit to work, see above),
and slider values.

The sliders value is an array of slider objects, specifying, for each slider, the min and max of the number they represent (i.e. min and max speed, min and max of size etc. to be passed to the exhibit on selection), the diff between values (which sets the number of arches as well) and the start and limit values.
The start value is the value the exhibit starts with and resets to, and the limit value is a special value marked with a yellow line (selected values are marked red).

Here's an example slider value for the speed of the dots illusion (note that speed can be negative, to spin the circle to the other direction):

```
{
    "min": -5,
    "max": 40,
    "diff": 1,
    "start": 20,
    "limit": 20
}
```

#### dotsConfig

The dots config section specifies the x, y, width and height of the background, so it can be drawn properly.
It also defines the cross size drawn in the middle of the background to help focusing.
Finally, it allows setting the speed and dot size that are used when stopping using the button. Naturally speed should be 0 and size should be something noticable.

Here's an example dots config section:

```
"dotsConfig": {
    "x": 720,
    "y": 580,
    "width": 900,
    "height": 900,

    "stopSpeed": 0,
    "stopDotSize": 15,

    "crossSize": 40
}
```

#### sphereConfig

The sphere config section specifies the x, y, width and height of the sphere to draw dots in, and the dotSize for the size of each dot.
It also allows setting the speed and the number of dots used when stopping using the button. Naturally speed should be 0 and dots number should be something noitcable.

Here's an example sphere config section:

```
"sphereConfig": {
    "x": 720,
    "y": 580,
    "width": 900,
    "height": 900,

    "dotSize": 7,

    "stopSpeed": 0,
    "stopDotsNum": 100
}
```

#### bioMotionConfig

The bioMotion config section specifies the dot size to use for character animation, as well as the stop speed and stop dots number onc ethe stop button is used. Natuarlly speed should be 0 and dots number should be something noticable.

In addition, various button sizes and positions are specified: prevButtonX, prevButtonY and nextButtonX, nextButtonY for the positions of the top left of the right and left buttons that change the animation, nextButtonWidth, nextButtonHeight and prevButtonWidth, prevButtonHeight to specify the active area of the buttons, and nextButtonSpritesheet and prevButtonSpritesheet to specify the file names of the button states.

dotsOffsetX and dotsOffsetY are used to set the offset of the characte ranimation top left corner from the top left corner of the screen. This is used to preoprly locate the animation in the correct position in the screen.

Finally, animationFileNames lists all the file names that define the animations (all located in assets/data/animation), without their .txt prefix, and startAnimationIndex specifies the start index (0-based) of the animation that is defaulted to when exhibit is started or resetted.

Here's an example bioMotion config section:

```
"bioMotionConfig": {
    "dotSize": 7,

    "stopSpeed": 1,
    "stopDotsNum": 4,

    "dotsOffsetX": 170,
    "dotsOffsetY": 120,

    "prevButtonX": 620,
    "prevButtonY": 870,

    "nextButtonX": 720,
    "nextButtonY": 870,

    "nextButtonSpritesheet": "rightSpritesheet",
    "prevButtonSpritesheet": "leftSpritesheet",

    "nextButtonWidth" : 26,
    "nextButtonHeight": 50,

    "prevButtonWidth" : 26,
    "prevButtonHeight": 50,

    "animationFileNames": ["cartwheel", "dog_turn", "dog_walk", "jump", "placekick", "run7-5", "walk5"],
    "startAnimationIndex": 2
}
```

## Log
The exhibit supports a rotating log named illusions_log_N.log (with N being a number from 1 to max file names (see log section for details) in the root directory, that logs the following events:
* START_ILLUSION (the exhibit stop button was pressed)
* STOP_ILLUSION (the exhibit stop button was released)
* INFO_SHOW (the exhibit info button was clicked to show the info)
* INFO_HIDE (the exhibit info button was clicked to hide the info)
* LANGUAGE_CHANGED,F,T (lngaugaed changed from language id F to language id T, see config languages section to know understand what are the language id of each langauge)
* SLIDER_CHANGE_slider1 or SLIDER_CHANGE_slider2,F,T (slider was changed from value F to value T, if slider1 is used then it's the left slider, otherwise it's the right one)

Each log row starts with a timestamp in the format of year-month-day hours:minutes:seconds (year is 4-digit, rest is 2-digit) following a comma, then the event as described above.

## Keyboard Interface

You can use the Escape key to quit the exhibit.