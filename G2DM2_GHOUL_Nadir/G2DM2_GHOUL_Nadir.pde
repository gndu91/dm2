//
// importation de la librairie son
//
import processing.sound.*;

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
///  JUMP_SOUND, DEATH_SOUND, CENT_SOUND, ... TODO: add more
SoundFile sounds[]; 


// la police de caractères
PFont myFont;

// Les constantes associées aux indices
/// Les constantes associées au dinosaure (les deux premieres cases n'ont pas besoin de noms
final int JUMP_PIC = 2, DEATH_PIC = 3;
/// Les constantes associées aux cactuses (à leurs images)
final int SIMPLE = 0, TRIPLE = 1;
/// Les indices des sons
final int JUMP_SOUND = 0, DEATH_SOUND = 1, CENT_SOUND = 2;

////////////////////////////////////////////////////////////////////////////////////////
//
// les variables associées aux sprites
//
////////////////////////////////////////////////////////////////////////////////////////
// le niveau du sol, le zoom, la vitesse
PVector referentiel, echelle, vitesse, position, acceleration;

/// La vitesse initiale du saut et la force de pesanteur
//final float g0 = 9.81, vitesseSaut0 = 98.1;
final float g0 = 2500, vitesseSaut0 = 850, vX0 = 125;

float jumpSpeed, g;


/// L'unique ordonnée du sol: à parir de celle-ci, on pourra trouver les autres, cela
///   peut rendre possible l'élargissement de l'écran (nous ne sommes plus limité à trois
///   "instances" du sol)
float solX;

////////////////////////////////////////////////////////////////////////////////////////
float cactuses[][], NB_MAX_CACTUSES = 10;
final int TYPE = 0, POS = 1;
float rarete;

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
boolean dSpeedSquared;// Y evolue en fonction de x
boolean dGravityFollowsMouse;
boolean dShowCommandBar;
boolean dShowHitBoxes;
boolean dRareteMouse;
boolean dPrediction;
boolean dImmortal;
boolean debug;

String command;

float hitBoxRadius;

///Le texte
final int TEXT_SIZE = 32, TEXT_COLOR = 64;

/// Le score
float score, highScore, palier;

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
  myFont = createFont("joystix.ttf", TEXT_SIZE);
  textFont(myFont);
  textAlign(CENTER, CENTER);
  fill(TEXT_COLOR);

  // charge les images
  solImg = loadImage("sol.png");

  dinoImgs = new PImage[4];
  dinoImgs[0] = loadImage("dinoMarche1.png");
  dinoImgs[1] = loadImage("dinoMarche2.png");
  dinoImgs[JUMP_PIC] = loadImage("dinoSaut.png");
  dinoImgs[DEATH_PIC] = loadImage("dinoMort.png");

  cactusImgs = new PImage[4];
  cactusImgs[SIMPLE] = loadImage("cactus1.png");
  cactusImgs[TRIPLE] = loadImage("cactus2.png");

  // charge les sons
  sounds = new SoundFile[3];
  sounds[JUMP_SOUND] = new SoundFile(this, "saut.mp3");
  sounds[DEATH_SOUND] = new SoundFile(this, "boom.mp3");
  sounds[CENT_SOUND] = new SoundFile(this, "cent.mp3");
  
  acceleration = new PVector(2, g);


  /// Les variables de débogage
  dSpeedFollowsMouse = false;
  dGravityFollowsMouse = false;
  dShowCommandBar = false;
  dShowHitBoxes = true;
  dRareteMouse = false;
  dPrediction = true;
  debug = false;

  hitBoxRadius = 5;

  dImmortal = false;
  command = "";

  /// La vitesse initiale de saut: 
  jumpSpeed = vitesseSaut0;
  g = g0;

  cactuses = new float[(int) NB_MAX_CACTUSES][2];
  for (float[] i : cactuses) {
    i[TYPE] = i[POS] = -1;
  }

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
  vitesse = new PVector(vX0, 0);// Il va vers la droite
  position = new PVector(0, 0);// Il définit l'origine

  // La rareté évolue au cours du jeu, elle doit donc être réinitialisée ici
  rarete = 100;

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


  if (score % 1000 > 750) {
    if (score % 1000 > 800) {
      filter(INVERT);
    }
    if (abs(score % 1000 - 800) < 50) {
      filter(BLUR, 1 - (abs(score % 1000 - 800) / 50));
    }
  }

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
    textSize(TEXT_SIZE);
    text("G A M E  O V E R", width/2, height/2);
  }
  if (dShowCommandBar) {
    textAlign(BOTTOM, LEFT);
    textSize(TEXT_SIZE);
    fill(TEXT_COLOR, 255);
    text("Command: " + command, 0, height);
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le score et joue un son tous les 100 
//
////////////////////////////////////////////////////////////////////////////////////////
void calculeScore() {
  /// TODO: Ajout de differentes methodes de score
  score = -solX / (20 * echelle.x);
  // Cette manière de voir les paliers s'était imposée d'elle-même car le jeu parfois
  /// "Sautait" des paliers (le score est flottant), donc il aurait fallu que j'en fasse
  /// un teste incluant un intervalle, mais ce faisant, le son sera déclenché
  /// plus qu'une fois
  if (score > palier) {
    palier += 100;
    sounds[CENT_SOUND].play();
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// teste la collision entre le dino et un cactus
//
////////////////////////////////////////////////////////////////////////////////////////
void testeCollisions() {
  float X = (echelle.x * position.x) + referentiel.x;
  float Y = (echelle.y * position.y) + referentiel.y;
  if (dShowHitBoxes) {
    ellipse(X, Y, hitBoxRadius * 2, hitBoxRadius * 2);
  }
  for (float[] i : cactuses) {
    if (i[TYPE] > -1 && (i[POS] + 50 > referentiel.x)) {
      // Le décalage n'a pas d'importance
      float x = (echelle.x * i[POS]) + referentiel.x;
      float y = referentiel.y;
      float h = dinoImgs[(int) i[TYPE]].height;
      float w = dinoImgs[(int) i[TYPE]].width;
      if (dShowHitBoxes) {
        ellipse(x, y, h, w);
      }
      if (!dImmortal) {
        // if(0);
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Outils de débogages
//
////////////////////////////////////////////////////////////////////////////////////////
void debugTools() {
  // TODO: Add pages
  
  if(!debug) {
    return;
  }

  if (dSpeedFollowsMouse) {
    vitesse.x = mouseX;
  } else if (dGravityFollowsMouse) {
    jumpSpeed = 100 * vitesseSaut0 / mouseX;
    g = 100 * g0 / mouseY;
    /// TODO: Create a global 32
  }
  if (dSpeedSquared) {
    vitesse.y = vitesse.x;
  }
  if (dRareteMouse) {
    rarete = mouseY;
  }

  float y = TEXT_SIZE / 3, x = 0;

  textAlign(TOP, LEFT);
  textSize(TEXT_SIZE / 3);
  fill(TEXT_COLOR, 255);

  text("Position                      " + position.y, x, y);
  y += TEXT_SIZE / 3;

  text("Vitesse de saut               " + jumpSpeed, x, y);
  y += TEXT_SIZE / 3;

  text("Acceleration gravitationnelle " + g, x, y);
  y += TEXT_SIZE / 3;

  text("Vitessed de défilement        " + vitesse.x, x, y);
  y += TEXT_SIZE / 3;

  y += TEXT_SIZE / 3;

  text("Affichage des hit boxes       " + (dShowHitBoxes ? "ON" : "OFF"), x, y);
  y += TEXT_SIZE / 3;

  text("Rayon des hitt boxes          " + hitBoxRadius, x, y);
  y += TEXT_SIZE / 3;

  text("Vous êtes                     " + (dImmortal ? "invincible" : "mortel"), x, y);
  y += TEXT_SIZE / 3;




  /// Colonne du milieu
  x = (width / 2) - 250;
  y = TEXT_SIZE / 3;
  textAlign(TOP, CENTER);

  for (float[] i : cactuses) {
    text("Cactus " + (i[TYPE] == SIMPLE ? "SIMPLE" : i[TYPE] == TRIPLE ? "TRIPLE" : "??????") + " " + i[POS], x, y);
    y += TEXT_SIZE / 3;
  }

  text("Rareté des cactus             " + rarete, x, y);
  y += TEXT_SIZE / 3;
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
  solX -= (vitesse.x * dT);
  vitesse.x += acceleration.x * dT;
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le mouvement des cactus
//
////////////////////////////////////////////////////////////////////////////////////////
void mouvementCactus() {
  if (random(0, rarete) < 1) {
    float[] cactus = cactuses[(int) random(0, cactuses.length)];
    if (cactus[POS] < 0) {
      cactus[TYPE] = random(0, 50) < 25 ? SIMPLE : TRIPLE;
      cactus[POS] = (int) (width * 1.1 / echelle.x);
    }
  }
  for (float[]i : cactuses) {
    i[POS] -= (vitesse.x * dT);
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le mouvement du dino
//
////////////////////////////////////////////////////////////////////////////////////////
void mouvementDino() {
  /// La base: on incrémente la vitesse
  position.y += vitesse.y * dT;
  if (position.y < 0) {
    position.y = 0;
    vitesse.y = 0;
  } else if (position.y > 0) {
    vitesse.y -= g * dT;
  }

  float yPredicted = position.y, vPredicted = vitesse.y, vXPredicted = vitesse.x;
  /// Prédit les prochains emplacements
  for (float x = position.x; x < width / echelle.x; x += vitesse.x * dT) {
    yPredicted += vPredicted * dT;
    if (yPredicted < 0) {
      yPredicted = 0;
      vPredicted = 0;
    } else if (yPredicted > 0) {
      vPredicted -= g * dT;
    }
    ellipse((x * echelle.x) + referentiel.x, 
            (yPredicted * echelle.y) + referentiel.y,
            hitBoxRadius * 2, hitBoxRadius * 2);
    /// Equation de la trajectoire
  }
  if (position.y < 10) {
    fill(#00ff00, 127);
    yPredicted = position.y;
    vPredicted = jumpSpeed;
    vXPredicted = vitesse.x;
    /// Prédit les prochains emplacements
    for (float x = position.x; x < width / echelle.x; x += vitesse.x * dT) {
      yPredicted += vPredicted * dT;
      if (yPredicted < 0) {
        yPredicted = 0;
        vPredicted = 0;
      } else if (yPredicted > 0) {
        vPredicted -= g * dT;
      }
      vXPredicted += acceleration.x * dT;
      ellipse((x * echelle.x) + referentiel.x, 
        (yPredicted * echelle.y) + referentiel.y, hitBoxRadius * 2, hitBoxRadius * 2);
      /// Equation de la trajectoire
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// gère l'affichage du score en ajoutant des zéros au besoin 
//
////////////////////////////////////////////////////////////////////////////////////////
void afficheScore() {
  // Nous utiliserons la couleur de texte définie comme une variable pour:
  /// Eviter les effets de bords liés à l'utilisation de fill pour d'autres but (dessin d'un rond rouge par exemple), ce qui aura un impact sur la couleur du texte
  /// Pouvoir à terme avoir la possibilité de la modifier
  // J'utilise 127 pour pouvoir réécrire par dessus le texte à afficher "en gras"
  fill(TEXT_COLOR, 127);

  // De m\u00eame que pour la ligne précédente, si une autre fonction modifie l'alignement du texte, il ne sera pas comme nous le souhaitons
  textAlign(RIGHT, TOP);

  // Le score était à mon gout un peu trop gros
  textSize(TEXT_SIZE / 2);

  /// TODO: HC xxxxxx est un peu moin opaque

  // J'utilise une variable pour que le message soit affiché en un seul bloc,
  /// sans bidouiller pour que chacun des blocs de texte se suivent
  String string = "HC ";

  // Une boucle pour rajouter le bon nombre de 0 (s'il y a moin de 0 "0",
  /// la boucle de se lance pas), puis un ajout du score, les int() servent
  /// à afficher la valeur entiere des variables qui sont en float pour
  /// plus de précision.
  for (int i = 0; i < 6 - str(int(highScore)).length(); ++i)string += "0";
  string += int(highScore);

  // Un espace entre les mors
  string += " ";

  for (int i = 0; i < max(0, 6 - str(int(score)).length()); ++i)string += "0";
  string += int(score);

  // La présentation du texte est celle de Google Chrome
  text(string, width, 0);
  // Nous affichons le score en "gras" en trouvant le premier espace (en excluant le premier),
  /// et en réécrivant par dessus
  text(string.substring(string.indexOf(" ", 3) + 1), width, 0);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// affiche les éléments mobiles du jeu
//
////////////////////////////////////////////////////////////////////////////////////////
void afficheSprites() {
  // Affiche le sol, TODO: Add a constant for the 600
  /// Je suis suceptible d'accidentellement changer cette variable autre part
  imageMode(CENTER);
  /// La position de la premiere dépend de l'echelle, mais les autres ne seront que
  ///  des répétitions, avec un decalage fixe
  for (float x = solX * echelle.x % 600; x < width + 600; x += 600) {
    image(solImg, x + referentiel.x, referentiel.y + 25);
  }

  // Affiche le dino TODO: Faire mieux
  image(dinoImgs[position.y < 10 ? (int) (frameCount * vitesse.x / 1000) % 2 : gameOver ? DEATH_PIC : JUMP_PIC], 
    (position.x * echelle.x) + referentiel.x, (position.y * echelle.y) + referentiel.y);

  for (float[] i : cactuses) {
    if (i[TYPE] > -1 && i[POS] > - referentiel.x - 50) {
      ///reference.x: ordonnée du 0
      ///50 -> pour le cacher avant 
      /*if(i[POS] < 0) {
       println("Blurring " + -i[POS]);
       cactusImgs[(int) i[TYPE]].filter(BLUR, (-i[POS]) / 50);
       }*/
      image(cactusImgs[(int) i[TYPE]], (echelle.x * i[POS]) + referentiel.x, referentiel.y);
      /*cactusImgs[(int) i[TYPE]].filter(BLUR, (i[POS]) / 50);*/
    }
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
  } else if (key == CODED && keyCode == UP) {
    if (position.y < 10) {
      vitesse.y = jumpSpeed;
      sounds[JUMP_SOUND].play();
    }
  } else if (dShowCommandBar && key != '²') {
    char k = (char) (key | 32);
    if (k >= 'a' && k <= 'z') {
      command += k;
    } else if(key == BACKSPACE) {
      command = command.substring(0, max(0, command.length() - 1));
    } else if(key == DELETE) {
      command = "";String a;
    } else if(key == ENTER) {
      if(command.equals("gravityball")) {
      } else if(command.equals("immortal") || command.equals("invincible")) {
        dImmortal = !dImmortal;
      } else if(command.equals("debug")) {
        debug = !debug;
      }
    }
  } else if (key == '²') {
    dShowCommandBar = !dShowCommandBar;
  } else if (debug) {/// Cheat codes
    /// Spécificitées de l'ASCII: les minuscules sont à 32 près des majuscules
    ///  Le ou unaire '|' permet de convertir majuscule->minuscule et minuscule->minuscule
    ///  comme vu en amphi et en TD

    switch(key | 32) {/// TODO: Afficher ceci
    case 'm':
      dSpeedFollowsMouse = !dSpeedFollowsMouse;
      break;
    case 'g':
      dGravityFollowsMouse = !dGravityFollowsMouse;
      break;
    case 's':
      dSpeedSquared = !dSpeedSquared;
      break;
    case 'r':
      dRareteMouse = !dRareteMouse;
      break;
    case 'p':
      dPrediction = !dPrediction;
      break;
    }
  }
}

void mouseDragged() {
}

void mousePressed() {
}

void mouseReleased() {
}
