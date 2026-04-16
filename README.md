# Taiko No Tatsujin Bot
## Introduction
As a programmer, one likes to play video games to calm down after a long day of forgetting your semicolons on C++. In my
case, I like to play Taiko no Tatsujin but, alas I am not the best at it.
So what do i do? I create a solution that takes 10 times as long to make as to just learn the game!


## How it works
Some may think that this can be accomplished with a object detection model and an if statement. While that can be done,
it is extremely slow and inefficient.
### The Solution?
PROBES

after an initial calibration step that uses a YOLO model to detect the "drum window", it uses 3 pixel level probes to
detect drums and drum types. This is much faster than a YOLO model.