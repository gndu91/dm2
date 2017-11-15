//
// importation de la librairie son
//
import processing.sound.*;

////////////////////////////////////////////////////////////////////////////////////////
//
// les variables associées aux ressources
//
////////////////////////////////////////////////////////////////////////////////////////
// les images
PImage solImg;

// les sons
SoundFile sonCent; 

// la police de caractères
PFont myFont;

////////////////////////////////////////////////////////////////////////////////////////
//
// les variables associées aux sprites
//
////////////////////////////////////////////////////////////////////////////////////////
// le niveau du sol
int baseY;
// la vitesse de défilement horizontale
float vitesseX;

// les coordonnées du sol
float sol1x, sol2x, sol3x;

////////////////////////////////////////////////////////////////////////////////////////
//
// les paramètres généraux
//
////////////////////////////////////////////////////////////////////////////////////////
// est-ce que c'est fini ?
boolean gameOver;

////////////////////////////////////////////////////////////////////////////////////////
//
// Initialisation générale
//
////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  // choisit la taille de la fenêtre
  size(1200, 500);

  // crée la fonte
  myFont = createFont("joystix.ttf", 32);
  textFont(myFont);
  textAlign(CENTER, CENTER);
  fill(64);

  // charge les images
  imageMode(CENTER);
  solImg = loadImage("sol.png");

  // charge les sons
  sonCent = new SoundFile(this, "cent.mp3");

  initJeu();
  gameOver = true;
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Initialisation des variables pour une nouvelle partie
//
////////////////////////////////////////////////////////////////////////////////////////
void initJeu() {
  // la hauteur du sol
  baseY = height * 3 / 4;
  // la vitesse de défilement
  vitesseX = 8;

  // initialise le sol
  sol1x = 300;
  sol2x = 900;
  sol3x = 1500;
  
  // initialisations générales
  gameOver = false;
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Boucle de rendu
//
////////////////////////////////////////////////////////////////////////////////////////
void draw() {
  background(255);

  // met à jour l'affichage
  afficheScore();
  afficheSprites();

  // si le jeu n'est pas terminé
  if (!gameOver) {
    calculeScore();
    testeCollisions();
    mouvementSol();
    mouvementCactus();
    mouvementDino();
  }
  // sinon
  else {
    textAlign(CENTER);
    text("G A M E  O V E R", width/2, height/2);
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le score et joue un son tous les 100 
//
////////////////////////////////////////////////////////////////////////////////////////
void calculeScore() {
}

////////////////////////////////////////////////////////////////////////////////////////
//
// teste la collision entre le dino et un cactus
//
////////////////////////////////////////////////////////////////////////////////////////
void testeCollisions() {
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le mouvement du sol
//
////////////////////////////////////////////////////////////////////////////////////////
void mouvementSol() {
  // fait défiler le sol
  sol1x -= vitesseX;
  sol2x -= vitesseX;
  sol3x -= vitesseX;

  // le sol réapparaît à droite quand il a disparu à gauche
  if (sol1x < -300)
    sol1x += 1800;
  if (sol2x < -300)
    sol2x += 1800;
  if (sol3x < -300)
    sol3x += 1800;
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le mouvement des cactus
//
////////////////////////////////////////////////////////////////////////////////////////
void mouvementCactus() {
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le mouvement du dino
//
////////////////////////////////////////////////////////////////////////////////////////
void mouvementDino() {
}

////////////////////////////////////////////////////////////////////////////////////////
//
// gère l'affichage du score en ajoutant des zéros au besoin 
//
////////////////////////////////////////////////////////////////////////////////////////
void afficheScore() {
}

////////////////////////////////////////////////////////////////////////////////////////
//
// affiche les éléments mobiles du jeu
//
////////////////////////////////////////////////////////////////////////////////////////
void afficheSprites() {
  // affiche le sol
  image(solImg, sol1x, baseY + 25);
  image(solImg, sol2x, baseY + 25);
  image(solImg, sol3x, baseY + 25);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// - fait sauter le dino quand on appuie sur la flèche du haut
// - redémarre le jeu quand on appuie sur la barre d'espace
//
////////////////////////////////////////////////////////////////////////////////////////
void keyPressed() {
  if ((key == ' ') && gameOver) {
    println("ici");
    initJeu();
  }
}