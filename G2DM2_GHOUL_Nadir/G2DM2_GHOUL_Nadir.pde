//
// importation de la librairie son
//
//SOUNDBUGimport processing.sound.*;

////////////////////////////////////////////////////////////////////////////////////////
//
// les variables associées aux ressources
//
////////////////////////////////////////////////////////////////////////////////////////
// Les images:
/// - solImg servira à l'affichage du sol, elle sera répétée pour pouvoir prendre tout l'écran
/// - dinoImgs est une liste d'images, les deux premieres cases seront pour la marche et les deux
///    dernieres serviront au saut, pour éviter de me tromper entre la 2 et la 3, je vais
///    utiliser les constantes JUMP_PIC et DEATH_PIC pour me référer à ces dernières
/// - cactusImgs est une liste de deux images, et comme pour dinoImgs, j'utiliserai les 
///    constantes SIMPLE et TRIPLE pour eviter de me tromper
PImage solImg, dinoImgs[], cactusImgs[];

// les sons
/// De même, j'utilise un tableau pour faire référence aux sons, avec les constantes:
///  JUMP_SOUND, DEATH_SOUND, TODO: add more
//SOUNDBUGSoundFile sons[]; 


// la police de caractères
PFont myFont;

// Les constantes associées aux indices
/// Les constantes associées au dinosaure (les deux premieres cases n'ont pas besoin de noms
final int JUMP_PIC = 2, DEATH_PIC = 3;
/// Les constantes associées aux cactuses (à leurs images)
final int SIMPLE = 0, TRIPLE = 1;
/// Les indices des sons
final int JUMP_SOUND = 0, DEATH_SOUND = 1;

////////////////////////////////////////////////////////////////////////////////////////
//
// les variables associées aux sprites
//
////////////////////////////////////////////////////////////////////////////////////////
// le niveau du sol, le zoom, la vitesse
PVector referentiel, echelle, vitesse;


/// L'unique ordonnée du sol: à parir de celle-ci, on pourra trouver les autres, cela
///   peut rendre possible l'élargissement de l'écran (nous ne sommes plus limité à trois
///   "instances" du sol)
float solX;

////////////////////////////////////////////////////////////////////////////////////////
//
// les paramètres généraux
//
////////////////////////////////////////////////////////////////////////////////////////
// est-ce que c'est fini ?
boolean gameOver;

// 50 milisecondes
float dT = 50 * 0.001;

/// Les variables de débogage
boolean dSpeedFollowsMouse;

////////////////////////////////////////////////////////////////////////////////////////
//
// Initialisation générale
//
////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  // choisit la taille de la fenêtre
  size(1200, 500);

  // On modifie le frameRate pour respecter dT initial => vitesses réelles
  frameRate(1 / dT);/// XXX Maybe it's 1/dT

  // crée la fonte
  myFont = createFont("joystix.ttf", 32);
  textFont(myFont);
  textAlign(CENTER, CENTER);
  fill(64);

  // charge les images
  imageMode(CENTER);
  solImg = loadImage("sol.png");

  dinoImgs = new PImage[4];
  dinoImgs[0] = loadImage("dinoMarche1.png");
  dinoImgs[1] = loadImage("dinoMarche2.png");
  dinoImgs[JUMP_PIC] = loadImage("dinoSaut.png");
  dinoImgs[DEATH_PIC] = loadImage("dinoMort.png");

  // charge les sons
  //SOUNDBUGsonCent = new SoundFile(this, "cent.mp3");

  /// Les variables de débogage
  dSpeedFollowsMouse = false;

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
  referentiel = new PVector(50, (height * 3 / 4));
  echelle = new PVector(2, -1);
  
  // La vitesse de défilement sera rattaché au perso
  vitesse = new PVector(40, 0);// Il va vers la droite
  

  // initialise le sol
  solX = 0;
  
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
  
  debugTools();

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
// Outils de débogages
//
////////////////////////////////////////////////////////////////////////////////////////
void debugTools() {
  if(dSpeedFollowsMouse) {
    vitesse.x = mouseX;
  }
}
////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le mouvement du sol
//
////////////////////////////////////////////////////////////////////////////////////////
void mouvementSol() {
  ///  Faire défiler le sol, en tenant en compte du fait que la vitesse est une vitesse
  ///    instantanée, et que par conséquent le déplacement se fera en tenant en compte 
  ///    le temps écoulé depuis le dernier affichage: v -> dx/dt => dx ~= v*dt
  ///  De plus, cette variable ne sera qu'un décalage sur [0, 600], car au moment
  ///    d'afficher le sol, elle servira à décider où afficher la première, et les
  ///    autres ne feront que suivre.
  solX = ((solX - (vitesse.x * dT)) % 600);
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
  // Affiche le sol, TODO: Add a constant for the 600
  for(float x = solX * echelle.x % 600; x < width + 600; x += 600) {
    image(solImg, x, referentiel.y + 25);
    ellipse(x, height / 2, 10, 10);
  }
  
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
  } else {/// Cheat codes
    /// Spécificitées de l'ASCII: les minuscules sont à 32 près des majuscules
    ///  Le ou unaire '|' permet de convertir majuscule->minuscule et minuscule->minuscule
    ///  comme vu en amphi et en TD
    if(char(key | 32) == 'm') {/// TODO: Afficher ceci
      dSpeedFollowsMouse = !dSpeedFollowsMouse;
    }
  }
}