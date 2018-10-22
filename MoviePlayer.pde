import processing.video.*;

MoviePlayer[] moviePlayer;

class MoviePlayer {
  
  Movie movie;
  PImage frame;
  boolean firstRun = true;
  boolean ready = false;
  boolean resizeStage = false;
  PVector pos = new PVector(0,0);
  PVector scale = new PVector(0,0);
  PVector upperLeft = new PVector(0,0);
  PVector lowerRight = new PVector(0,0);
  
  MoviePlayer(String fileName, PApplet pApplet) {
    movie = new Movie(pApplet, fileName);
    /*
    frameRate()  Sets the target frame rate
    speed()  Sets the relative playback speed
    duration()  Returns length of movie in seconds
    time()  Returns location of playback head in units of seconds
    jump()  Jumps to a specific location
    available()  Returns "true" when a new movie frame is available to read.
    play()  Plays movie one time and stops at the last frame
    loop()  Plays a movie continuously, restarting it when it's over.
    noLoop()  Stops the movie from looping
    pause()  Pauses the movie
    stop()  Stops the movie
    read()  Reads the current frame
    volume() Sets the volume
    */
    movie.loop();
    movie.volume(0);
    frame = createImage(movie.width, movie.height, RGB);
  }
  
  void frameForward() {
    movie.pause();
    movie.jump(movie.time() + (1.0/movie.frameRate));
    refreshFrame();
  }
  
  void frameBack() {
    movie.pause();
    movie.jump(movie.time() - (1.0/movie.frameRate));
    refreshFrame();
  }
  
  void refreshFrame() {
    movie.read();
    if (lowerRight.x == 0 && lowerRight.y == 0) lowerRight = new PVector(movie.width, movie.height);
    frame = movie.get((int) upperLeft.x, (int) upperLeft.y, (int) lowerRight.x, (int) lowerRight.y); 
  }
  
}

void setupMoviePlayer(String fileName) {
  moviePlayer = new MoviePlayer[1];
  moviePlayer[0] = new MoviePlayer(fileName, this);
  println("Loaded " + moviePlayer.length + " movie.");
}

void setupMoviePlayer(String[] fileName) {
  moviePlayer = new MoviePlayer[fileName.length];
  for (int i=0; i<fileName.length; i++) {
    moviePlayer[i] = new MoviePlayer(fileName[i], this);
  }
  println("Loaded " + moviePlayer.length + " movies.");
}

void drawMoviePlayer() {
  for (int i=0; i<moviePlayer.length; i++) {    
    if (moviePlayer[i].ready) {
      if (moviePlayer[i].resizeStage) {
        surface.setSize(moviePlayer[i].movie.width, moviePlayer[i].movie.height);
      }
      moviePlayer[i].ready = false;
    }
    if (moviePlayer[i].movie.available()) {
      if (moviePlayer[i].scale.x == 0  && moviePlayer[i].scale.y == 0) {
        image(moviePlayer[i].frame, moviePlayer[i].pos.x, moviePlayer[i].pos.y);
      } else {
        image(moviePlayer[i].frame, moviePlayer[i].pos.x, moviePlayer[i].pos.y, moviePlayer[i].scale.x, moviePlayer[i].scale.y);
      }
    }  
  }
}

void movieEvent(Movie m) {
  m.read();
  for (int i=0; i<moviePlayer.length; i++) {
    if (moviePlayer[i].movie.available()) {
      if (moviePlayer[i].firstRun) {
        moviePlayer[i].ready = true;
        moviePlayer[i].firstRun = false;
      }
      if (moviePlayer[i].lowerRight.x == 0 && moviePlayer[i].lowerRight.y == 0) moviePlayer[i].lowerRight = new PVector(moviePlayer[i].movie.width, moviePlayer[i].movie.height);
      moviePlayer[i].frame = moviePlayer[i].movie.get((int) moviePlayer[i].upperLeft.x, (int) moviePlayer[i].upperLeft.y, (int) moviePlayer[i].lowerRight.x, (int) moviePlayer[i].lowerRight.y); 
    } 
  }
}