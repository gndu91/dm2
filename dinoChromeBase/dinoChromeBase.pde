//
// importation de la librairie son
//
////SOUNDERRORimport processing.sound.*;

////////////////////////////////////////////////////////////////////////////////////////
//
// les variables associées aux ressources
//
////////////////////////////////////////////////////////////////////////////////////////
// les images
PImage solImg;
PImage[] dinoImgs;/// 4 images, deux pour la marche, une pour le saut et une pour la mort
final int MORT = 2;
final int SAUT = 3;/// Pour éviter de se tromper entre les deux dernieres valeurs
PImage[] cactusImgs;// Les cactus

// La taille du tableau est contenu dans celui_ci, mais pour l'auguementer au fur et à mesure, je préfère utiliser un flottant
final int NB_CAC_INIT = 10;
float NB_CAC;
int current_cac = 0;
/// TODO: Auguementer la taille
int[][] cactuses;
// Type de cactus
final int SIMPLE = 0, 
  TRIPLE = 1;
// "Structure"
final int POSITION = 0, 
  TYPE = 1;


// les sons
////SOUNDERRORSoundFile sonCent, sonMort, sonSaut; 

// la police de caractères
PFont myFont;

////////////////////////////////////////////////////////////////////////////////////////
// Debug options
String cache;
boolean showCommandBar;
boolean showTrajectories;
/// La taille du hud, une échelle réglable
float hudSize, hudSizeStep;

/// Pour passer les paliers sans problèmes
int immortal;/// 3 etats: -1 (non découvert), 0(off), 1(on)

/// Il sert à se déplacer comme dans un menu
int debugIndex;


/// TODO: Show a menu in order to modify the gravity
/// TODO: Slow down the game before entering in the menu
/// TODO: Store the current speedX in a different value
/// TODO: Store the dT in order to speed things down / up
/// TODO: Add a slow down effect when hiding the character
/// TODO: Slow down the scene when we detect that the dino will die

////////////////////////////////////////////////////////////////////////////////////////
//
// les variables associées aux sprites
//
////////////////////////////////////////////////////////////////////////////////////////
// le niveau du sol
int baseY;
// la vitesse de défilement horizontale
final float dX = 10;
// Ce n'est pas une vitesse car dt est grand

// la vitesse verticale du dinosaure
float dY;
// DEBUG

// sa position
float positionDino;

final int DINO_X = 50;

float score;
float highScore;
float step;
// Variable qui vaudra (floor(score / 100) + 1) * 100
// Chaque fois, on testera cette valeur pour savoir si on a passé 100

// les coordonnées du sol
float sol1x, sol2x, sol3x;

////////////////////////////////////////////////////////////////////////////////////////
//
// Gestion de la physique
//
////////////////////////////////////////////////////////////////////////////////////////
float detente, hauteur;
float dY0 = 10;
float g = 9.81;


////////////////////////////////////////////////////////////////////////////////////////
//
// les paramètres généraux
//
////////////////////////////////////////////////////////////////////////////////////////
// est-ce que c'est fini ?
boolean gameOver;


final int TEXT_SIZE = 32;
final color TEXT_COLOR = 64;

final int METHOD_1 = 1;// Le score dépend de la vitesse
final int METHOD_0 = 0;// Le score ne dépend que de la frame actuelle
// TODO:final int METHOD_2 = 2;// Le score dépends du temps

int scoringMethod = METHOD_0;
final float scoringWeight = 0.1;

////////////////////////////////////////////////////////////////////////////////////////
//
// Initialisation générale
//
////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  // choisit la taille de la fenêtre
  size(1200, 500);
  frameRate(50);
  detente = (dY0 * dX * frameRate * frameRate) / (g);
  hauteur = (frameRate * frameRate / g) * (dY0 * dY);


  // crée la fonte
  myFont = createFont("joystix.ttf", TEXT_SIZE);
  textFont(myFont);
  textAlign(CENTER, CENTER);
  fill(64);

  // charge les images
  imageMode(CENTER);
  solImg = loadImage("sol.png");


  // Initialistation des valeurs. Comme vous pouvez le voir,
  /// je ferai toujours référence aux cases 2 et 3 en utilisant les constantes SAUT et MORT, pour éviter la confusion
  dinoImgs = new PImage[4];
  dinoImgs[0] = loadImage("dinoMarche1.png");
  dinoImgs[1] = loadImage("dinoMarche2.png");
  dinoImgs[SAUT] = loadImage("dinoSaut.png");
  dinoImgs[MORT] = loadImage("dinoMort.png");

  // Initialisation des cactus
  cactusImgs = new PImage[2];
  cactusImgs[SIMPLE] = loadImage("cactus1.png");
  cactusImgs[TRIPLE] = loadImage("cactus2.png");
  // charge les sons
  ////SOUNDERRORsonCent = new SoundFile(this, "cent.mp3");sonSaut = new SoundFile(this, "saut.mp3");sonMort = new SoundFile(this, "boom.mp3");

  initJeu();
  gameOver = true;

  cache = "";

  hudSize = 1;
  hudSizeStep = 0.1;

  showCommandBar = false;
  showTrajectories = false;

  // Non découvert
  immortal = -1;
  debugIndex = -1;


  // Cette variable sera valable pour toute la sesssion (au moin)
  highScore = 0;// TODO: Store it into a file
}


////////////////////////////////////////////////////////////////////////////////////////
//
// Gestion des cactus
//
////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////
//
// Initialisation des variables pour une nouvelle partie
//
////////////////////////////////////////////////////////////////////////////////////////
void initJeu() {
  // la hauteur du sol
  baseY = height * 3 / 4;

  // initialise le sol
  sol1x = 300;
  sol2x = 900;
  sol3x = 1500;

  // initialisations générales
  gameOver = false;

  // Initialisation des valeurs=
  positionDino = 0;
  dY = 0;
  step = 100;

  score = 0;

  NB_CAC = NB_CAC_INIT;
  current_cac = 0;
  cactuses = new int[2][NB_CAC_INIT];
  for (int[] cac : cactuses) {
    cac[POSITION] = cac[TYPE] = -1;
  }
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
  afficheDebugMenu();
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
    textSize(TEXT_SIZE);
    fill(TEXT_COLOR);
    text("G A M E  O V E R", width/2, height/2);
    // XXX: Quand mettre à jour le HC?
    if (score > highScore) {
      highScore = score;
    }
    score = 0;
  }
  // filter(BLUR, float(frameCount));

  if (showTrajectories) {
    /// TODO: This
  }
  if (showCommandBar) {
    textAlign(LEFT, BOTTOM);
    textSize(TEXT_SIZE);
    fill(TEXT_COLOR);
    text("command:" + cache, 0, height);
  }


  // println("Détente", detente, frameRate, "position", positionDino);
  // fill(255, 255, 255);
  // ellipse(DINO_X + detente, baseY, 10, 10);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le score et joue un son tous les 100 
//
////////////////////////////////////////////////////////////////////////////////////////
void calculeScore() {
  if (scoringMethod == METHOD_0) {
    score += scoringWeight;// vitesseX
  } else if (scoringMethod == METHOD_1) {
    score += dX * scoringWeight;
  }

  // Cette manière de voir les paliers s'était imposée d'elle-même car le jeu parfois
  /// "Sautait" des paliers (le score est flottant), donc il aurait fallu que j'e fasse
  /// un teste incluant un intervalle, mais ce faisant, le son sera déclenché 
  /// plus qu'une fois
  if (score > step) {
    step += 100;
    ////SOUNDERRORsonCent.play();
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// teste la collision entre le dino et un cactus
//
////////////////////////////////////////////////////////////////////////////////////////
void testeCollisions() {
  /// Si le mode n'a pa été découvert ou qu'il est désactivé
  if (immortal < 1) {
    for (int[] cac : cactuses) {
      if (cac[POSITION]>0) {
        int x = cac[POSITION], y = baseY, w = cactusImgs[cac[TYPE]].width, h = cactusImgs[cac[TYPE]].height;
        if ((abs(x - DINO_X) < (w/ 2)) && (abs(y - baseY + positionDino) < (h / 2))) {
          ////SOUNDERRORsonMort.play();
          gameOver = true;
        }
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le mouvement du sol
//
////////////////////////////////////////////////////////////////////////////////////////
void mouvementSol() {
  // fait défiler le sol
  sol1x -= dX;
  sol2x -= dX;
  sol3x -= dX;

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
  for (int[] cac : cactuses) {
    if (cac[POSITION] > -1)
      cac[POSITION] -= dX;
  }
  if (cactuses[current_cac][POSITION] < 0) {
    cactuses[current_cac][TYPE] = random(0, 100) < 50 ? SIMPLE : TRIPLE;
    cactuses[current_cac][POSITION] = (int) random(width, 2 * width);
    current_cac++;
    current_cac %= cactuses.length;
  } else println("Prochain cactus:", cactuses[current_cac][POSITION]);

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  //TOTO: Laisser un espace suffisant pour nous laisser sauter
  ///TODO: Ne pas supprimer les cactus
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le mouvement du dino
//
////////////////////////////////////////////////////////////////////////////////////////
void mouvementDino() {
  // Nous décrémentons avant le test, pour ne pas avoir de frames trop basse
  positionDino += dY;

  // Important: le référentiel choisi est défini de maniere à
  /// simplifier les calcules balistiques
  //// (axe y orienté vers le haut et x vers la droite)

  if (positionDino <= 0) {
    // Si le dinosaure touche le sol, on ne le fais pas descendre plus
    positionDino = 0;
  } else {
    // Ce n'est pas 1 seconde qui s'est écoulé, mais dt
    // Cela peux entre autres nous permettre de modifier
    /// la vitesse de défilement du jeu en fonftion du temps
    dY -= (g / frameRate);
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// gère l'affichage du score en ajoutant des zéros
//
////////////////////////////////////////////////////////////////////////////////////////
void afficheScore() {
  // Nous utiliserons la couleur de texte définie comme une variable pour:
  /// Eviter les effets de bords liés à l'utilisation de fill pour d'autres but (dessin d'un rond rouge par exemple), ce qui aura un impact sur la couleur du texte
  /// Pouvoir à terme avoir la possibilité de la modifier
  // J'utilise 127 pour pouvoir réécrire par dessus le texte à afficher "en gras"
  fill(TEXT_COLOR, 127);

  // De même que pour la ligne précédente, si une autre fonction modifie l'alignement du texte, il ne sera pas comme nous le souhaitons
  textAlign(RIGHT, TOP);

  // Le score était à mon gout un peu trop gros
  textSize(TEXT_SIZE * hudSize / 2);

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
// gère l'affichage du debug menu
//
////////////////////////////////////////////////////////////////////////////////////////
void afficheDebugMenu() {
  if (showCommandBar) {
    fill(TEXT_COLOR * hudSize, 127);
    textAlign(LEFT, TOP);
    textSize(TEXT_SIZE / 2);
    // Pour calculer l'abscicce du texte
    int index = 0;

    text("HUD Size: " + hudSize + (debugIndex == index ? " <" : ""), 0, index * TEXT_SIZE / 2);
    index++;

    if (immortal > -1) {
      text("Immortal: " + (immortal == 0? "OFF": " ON") + (debugIndex == index ? " <" : ""), 0, index * TEXT_SIZE / 2);
      index++;
    }
    
    
    
  }
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

  // affiche le dinosaure
  /// Si le jeu est fini: le dino est mort
  /// Sinon: s'il est au sol, ses pas dépendent du tems (fréquence: 5Hz)
  /// Sinon: il saute
  if (gameOver) image(dinoImgs[MORT], DINO_X, baseY - positionDino);
  else if (positionDino == 0) {
    // image(dinoImgs[int(millis() / 200) % 2], DINO_X, baseY);frameCount
    image(dinoImgs[(frameCount / 10) % 2], DINO_X, baseY);
  } else image(dinoImgs[SAUT], DINO_X, baseY - positionDino);

  // affiche les cactus: Chaque cactus est représenté sur une sorte de ruban
  // le ruban défini leurs positions, si elle est positive, on les dessine
  // sinon, on ne les prends pas en compte
  for (int[] cac : cactuses) {
    if (cac[POSITION] > 0) {
      image(cactusImgs[cac[TYPE]], cac[POSITION], baseY);
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
  ///  J'ai essayé le switch, mait le code était illisible, avec des switch-if-switch imbriqués, et l'indentation(même automatique) était approximative
  /// C'est peut-être moin efficace, mais cela a le mérite de scinder les conditions de maniere moin floues
  if (key == ' ' && gameOver) {
    initJeu();
  } else if (key == CODED && keyCode == UP) {
    // trop frustrant d'être a 1mm près
    if (positionDino < 10) {
      ////SOUNDERRORsonSaut.play();
      dY = dY0;
    }
  } else if (key == '²') {
    showCommandBar = !showCommandBar; /// TODO: notifications de changements de variables
    /// TODO: Changement de profiles
  } else if (!showCommandBar) {
    // Ne rien faire, juste empêcher les instructions plus bas si le menu est caché
  } else if (key == DELETE) {
    cache = "";
  } else if (key == ENTER) {
    if (cache.equals("immortal")) {
      immortal = (immortal < 1) ? 1 : 0;
    } else if (cache.equals("menu")) {
      // 0 -> -1 -> 0 -> ...
      // 1 -> -2 -> 1 -> ...
      // 2 -> -3 -> 2 -> ...
      debugIndex = -1 - debugIndex;
    }
  } else if (key == BACKSPACE) {
    /// Retire le dernier caractère de la chaine de caractere (si elle est vide, ne copie pas -1 caracteres)
    cache = cache.substring(0, max((cache.length() - 1), 0));
  } else if (key >= 'a' && key <= 'z') {
    cache += key;
  } else if (key >= 'A' && key <= 'Z') {
    /// Caractéristique de ASCII ('a' + 32 = 'A')
    cache += char(key & ~32);
  } else if ((key == '+') || (key == '-')) {
    if (cache.equals("gui")) {
      hudSize += (key=='+' ? 1 : -1) * hudSizeStep;
      if (hudSize < hudSizeStep) {
        hudSize = hudSizeStep;
      }
    }
  } else if ((key > '0') && (key < '9')) {/// 2 4 6 8
    debugIndex += ((key == '8' && debugIndex > 0) ? -1 : ((key == '2') ? 1 : 0));
  }// TODO pause the game
  println("Cache11", cache, key);
}