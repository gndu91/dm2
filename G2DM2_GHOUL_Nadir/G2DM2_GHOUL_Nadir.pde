//
// importation de la librairie son
//
// SOUND ERROR: import processing.sound.*;

/// TODO: rendre dJumping plus "large", pour parmettre un saut avans d'avoir touché le sol

////////////////////////////////////////////////////////////////////////////////////////
/// RESUME DES COMMANDES DE DEBUG: Dans le jeu, vous avez la possibilité d'activer/de
///    désactiver des commandes de debug, en appuyant sur '²', une commande apparaitra
///    en fin de page, (note: elle ne prends que des lettres, et laisse passer tout le
///    reste, comme la barre d'espace par exemple)
///
///  Note: les commandes sont insensibles à la cases, donc "DeBug" <=> "debug" <=> "DEBUG"
///
///
///  DEBUG:      Affiche/cache le menu de débug, et permet par la même occasion d'activer ou
///                  désactiver les racourcis clavier. ATTENTION: Lorsque la barre de commande est
///                  affichée, il est impossible d'utiliser les racourcis, les lettres étant captés
///                  par la ligne de commande, il vous faut donc pour cela appuyer sur '²'. 
///          
///                  Les raccourcis sont:
///                    g:L'accélération gravitationelle et la vitesse vertivale suivront
///                      respectivelent l'ordonnée et l'abscicce de la souris
///                    m:La vitesse de défilement horisontale suivra l'absice de la souris
///                    r:Regle la rareté des cactus, plu elle est haute, plus il y en aura
///                      TODO: pour l'instant, y=0 fais crasher le programme
///                    +:Ajoute un cactus à droite
///
///  IMMORTAL:       Alias de INVINCIBLE
///                  
///  INVINCIBLE:     Le dinosaure est désormais invincible, rien ne peux le tuer, ni les
///                  cactus, ni les météorites, il est immortel
///                  
///  HELPMEEE:       Le dinosaure deviens autonome
///                  TODO:Limiter le nombre d'aides 
///
///  SLOWLANDING:    Le temps ralentira à chaque aterissage, utile si les cactus sont trop
///                  sérrés a votre goût
///
///  VIENSAMOI:      Le dinosaure suivra votre souris, par conséquent toutes les variables globales
///                  seront soceptibes d'être modifiées
///                  TODO: BackUps
///
////////////////////////////////////////////////////////////////////////////////////////
///  TAB:      Ralentir le temps
///  ENTER:    
///  UP:       Permet de sauter, une fois en l'air, on ne peut pas sauter encore
///            TODO: Creer une fonction de double saut
///
////////////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////////////
/// On considere que l'utilisateur ne peut pas sauter de manière instantanée, mais
///  uniquement après ce nombre de mètres
final int tempsDeReaction = 3;

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
// SOUND ERROR: SoundFile sounds[]; 

/// TODO: Pilote automatique
// TODO: Antigravity

// TODO: AutoSlowDown

// TODO: La trajectoir peut avoir quelques erreurs dans kle cas scale.x < 0
// TODO: scale.x < 0
// TODO: scale.y > 0

// TODO: Afficher les trais limites dans les trajectoires apparentes

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
float dT = 0.05;

/// Les variables de débogage
boolean dSpeedFollowsMouse;
boolean dSpeedSquared;// Y evolue en fonction de x
boolean dGravityFollowsMouse;
boolean dShowCommandBar;
boolean dShowHitBoxes;
boolean dRareteMouse;
boolean dPrediction;
boolean dImmortal;

boolean dJumping;
boolean dSlowLanding;


/// Pour ralentir le temps de manière progressive
boolean dAutoSlowDown;
boolean dSlowDown;
int dSlowDownRate;
float dSlowDownIncrement;
boolean dTooMuchSlowDown;
float dTooMuchSlowDownLimit;

/// Ralentis le temps quand je m'approche trop des cactus
boolean dHelp;

/// Cette variable sert a decider si nous tracons des lignes ou des lignes
boolean dContinuousTrajectory;

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
  // SOUND ERROR: sounds = new SoundFile[3];
  // SOUND ERROR: sounds[JUMP_SOUND] = new SoundFile(this, "saut.mp3");
  // SOUND ERROR: sounds[DEATH_SOUND] = new SoundFile(this, "boom.mp3");
  // SOUND ERROR: sounds[CENT_SOUND] = new SoundFile(this, "cent.mp3");

  acceleration = new PVector(2, g);


  /// Les variables de débogage
  dSpeedFollowsMouse = false;
  dGravityFollowsMouse = false;
  //// TODO: Show
  dContinuousTrajectory = false;
  dShowCommandBar = false;
  dShowHitBoxes = true;
  dRareteMouse = false;
  dPrediction = true;
  dJumping = false;
  dSlowLanding = true;
  debug = true;
  
  dHelp = true;

  dSlowDown = false;
  dAutoSlowDown = false;
  dSlowDownRate = 0;
  dSlowDownIncrement = 0.9;
  /// Si nous ralentissons trop, alors accelerer jusqu'à avoir une vitesse normale
  dTooMuchSlowDown = false;
  dTooMuchSlowDownLimit = 50;

  hitBoxRadius = 5;

  dImmortal = false;
  command = "";

  /// La vitesse initiale de saut: 
  jumpSpeed = vitesseSaut0;
  g = g0;

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

  cactuses = new float[(int) NB_MAX_CACTUSES][2];
  for (float[] i : cactuses) {
    i[TYPE] = i[POS] = -1;
  }

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

  
  boolean slowLanding = dJumping && vitesse.y < 0 && dSlowLanding;
  
  /// Trois cas peuvent mener à un ralentissement du temps:
  ///  un ralentissement ordonné par l'utilisateur (dSlowDown)
  ///  un ralentissement ordonné par l'ordinateur (dAutoSlowdown)
  ///  un ralentissement lié à la fin de saut ralentie (slowLanding)
  /// Pour les deux premier cas, nous prendrons pour limite dTooMuchSlowDownLimit, sinon 
  ///  nous prendrons le tiers de cette limite
  /// TODO: Pk 3 et pa 4 ou 5?
  if(!dTooMuchSlowDown && (slowLanding  || dSlowDown || dAutoSlowDown)) {
    if (dSlowDownRate < (dTooMuchSlowDownLimit)) {
    
  }
  if(!dTooMuchSlowDown && ()) {
      dSlowDownRate += 1;
      dT *= dSlowDownIncrement;
    } else {
      dTooMuchSlowDown = true;
    }
  } else {
    if (dSlowDownRate > 0) {
      if(dSlowDownRate > 1) {
        dSlowDownRate -= 2;
        dT /= dSlowDownIncrement * dSlowDownIncrement;
      } else {
        dSlowDownRate -= 1;
        dT /= dSlowDownIncrement;
      }
    } else {
      dTooMuchSlowDown = false;
    }
  }

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
    // SOUND ERROR: sounds[CENT_SOUND].play();
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// teste la collision entre le dino et un cactus
//
////////////////////////////////////////////////////////////////////////////////////////
boolean collision(float X, float Y) {/// Position du dino
  strokeWeight(1);

  X = (echelle.x * X) + referentiel.x;
  Y = (echelle.y * Y) + referentiel.y;
  if (dShowHitBoxes) {
    ellipse(X, Y, hitBoxRadius * 2, hitBoxRadius * 2);
  }

  float y = referentiel.y;
  /// Nous pouvons retourner la valeur en cas de choc ou attendre pour afficher toutes les hitbox
  ///   boolean value;

  /// TODO: Peut-être remplacé par des contantes;
  float h = dinoImgs[0].height;
  float w = dinoImgs[0].width;
  float r = sqrt(pow(h / 2, 2) + pow(w / 2, 2));

  for (float[] i : cactuses) {
    /// TODO: Tester si cela est un bon test
    if (i[TYPE] > -1 && (i[POS] + 50 > referentiel.x)) {
      float x = (echelle.x * i[POS]) + referentiel.x;
      if (dShowHitBoxes) {
        /// TODO: Afficher le cercle dans une autre couleur
        ellipse(x, y, h, w);
      }
      if (sqrt(pow(x - X, 2) + pow(y - Y, 2)) < (hitBoxRadius + r)) {
        return true;
      }
    }
  }
  return false;
}

////////////////////////////////////////////////////////////////////////////////////////
void testeCollisions() {
  boolean mustSlowDown = false;
  // Le décalage n'a pas d'importance
  if (!dImmortal) {
    if (collision(position.x, position.y)) {
      gameOver = true;
    }
  }
  dAutoSlowDown = mustSlowDown;
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Outils de débogages
//
////////////////////////////////////////////////////////////////////////////////////////
void debugTools() {
  // TODO: Add pages

  if (!debug) {
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

  text("Vitessed verticale            " + vitesse.y, x, y);
  y += TEXT_SIZE / 3;

  /// Ligne vide
  y += TEXT_SIZE / 3;

  text("Temps entre deux frames       " + dT, x, y);
  y += TEXT_SIZE / 3;

  /// Ligne vide
  y += TEXT_SIZE / 3;

  text("Affichage des hit boxes       " + (dShowHitBoxes ? "ON" : "OFF"), x, y);
  y += TEXT_SIZE / 3;

  text("Rayon des hit boxes           " + hitBoxRadius, x, y);
  y += TEXT_SIZE / 3;

  text("Vous êtes                     " + (dImmortal ? "invincible" : "mortel"), x, y);
  y += TEXT_SIZE / 3;

  /// Ligne vide
  y += TEXT_SIZE / 3;

  text("Saut en cours                 " + (dJumping ? "OUI" : "NON"), x, y);
  y += TEXT_SIZE / 3;

  text("Atterissage lent              " + (dSlowLanding ? "ON" : "OFF"), x, y);
  y += TEXT_SIZE / 3;
  
  text("Ralentissement actuel         " + dSlowDownRate, x, y);
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
    dJumping = false;
  } else if (position.y > 0) {
    vitesse.y -= g * dT;
  }

  // On fera des dessins plus bas
  strokeWeight(1);

  /// Prédit les prochains emplacements,  pour cela, nous devrons connaitre les conditions initiales
  ///  sans pour autant modifier les variables, et pour faire des lignes, il faut deux points
  float x, y, _x, _y, vX, vY;

  // Si nous sommes en plein saut, alors prendre la vitesse verticale actuelle, sinon prendre la vitesse de saut
  vY = position.y < 1 ? jumpSpeed : vitesse.y; /// TODO: Ajout d'une constante pour toutes les incertitudes

  /// XXX Nous devrons donc éviter de modifier la maniere dont la vitesse change
  //    de plus, les changements de dT pourront avoir un impact sur la justesse de
  //    la trajectoire ainsi calculée
  // Nous prenons les conditions initiales sur x, y et 
  vX = vitesse.x;
  x = _x = position.x;
  y = _y = position.y;

  /// TODO: Changer la couleur en rouge si nous touchons un cactus, pour cela:
  ///    faire une boucle pour chaque cactus visible
  ///    pour chaque cactus: calculer y(x) = (yPredicted) if y < end

  /// TODO: N'afficher que les points en l'air

  /// TODO: Pilote automatique

  /// TODO: Creer une fonction retournant uniquement les cactus visibles

  /// Si nous sommes au sol, alors nous aurons une prédiction hypotétique
  //fill((position.y < 10 ? #00ff00 : #0000ff), 255);
  /// TODO:Combiner ce facteur avec le facteur collision

  /// TODO: Changer l'algo, ne pas afficher en temps réel, mais stocker dans un array

  float[][] positions = new float[1000][2];
  println(positions.length + " positions");
  // Ceci évite les calculs inutiles
  int index = 0, tombeDepuis = 0;
  /// On considere que l'utilisateur ne 
  final int tempsDeReaction = 3;

  ///  Boucler jusqu'à la fin, c'est à dire jusqu'à que nous atteignons le sol
  ///    quand les points sont trop raprochés, nous devrons les séparer
  ///    pour cela, nous utiliserons les rayons, les cercles ne doivent pas se
  ///    renter dedans
  ///  On commence par incrémenter x, sinin le premier sera juste au dessus
  ///    de la position actuelle
  for (x += vitesse.x * dT; x < width / echelle.x && (index < positions.length); x += vitesse.x * dT) {

    /// Ceci n'est qu'une copie de ce que vous pouvez voir au début de cette fonction
    y += vY * dT;
    if (y < 0) {
      y = 0;
      vY = 0;
    } else if (y > 0) {
      vY -= g * dT;
      /// Ceci est calculé quand la postion du sol est mise à jour
      vX += acceleration.x * dT;
    } 
    if(tombeDepuis > tempsDeReaction) {
      vX *= 2;
    }
    
    /// Ajout du couple de coordonnées à la liste
    positions[index][0] = x;
    positions[index][1] = y;
    
    
    println(tombeDepuis);
    tombeDepuis = y < 1 ? tombeDepuis + 1 : 0;

    index++;
  }

  boolean willCollide = false;
  tombeDepuis = 0;
  /// Nous ne voulons pas que les box soit affichées encore et encore
  boolean show = dShowHitBoxes;
  dShowHitBoxes = false;

  /// Si nous savons que cela ne va pas psser, nous n'avos pas à recalculer
  // On itere de 0 à len - 2 car on va utiliser i + 1
  for (int i = 0; i < index && !willCollide && tombeDepuis < tempsDeReaction; ++i) {
    // positions[i] = {x, y}
    tombeDepuis = positions[i][1] < 1 ? tombeDepuis + 1 : 0;
    willCollide = collision(positions[i][0], positions[i][1]);
  }

  dShowHitBoxes = show;

  /// Rouge si nous allons toucher, vert sinon
  fill(willCollide ? #ff0000 : #00ff00, 64);
  println("Will" + (willCollide ? " " : " not ") + "collide");
  // TODO: Réparer les effets de bords causés par cette ligne

  // On itere de 0 à len - 2 car on va utiliser i + 1
  for (int i = 0; i + 1 < index; ++i) {
    // positions[i] = {x, y}
    /// TODO: Inutile de charger des cases en plus
    x = positions[i][0];
    y = positions[i][1];
    _x = positions[i + 1][0];
    _y = positions[i + 1][1];
//    if (dContinuousTrajectory) {
      line((_x * echelle.x) + referentiel.x, (_y * echelle.y) + referentiel.y, 
        (x * echelle.x) + referentiel.x, (y * echelle.y) + referentiel.y);
  //  } else {
      ellipse((x * echelle.x) + referentiel.x, 
        (y * echelle.y) + referentiel.y, hitBoxRadius * 2, hitBoxRadius * 2);
    //}
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
  image(dinoImgs[position.y < 10 ? (int) (frameCount * 3 / frameRate) % 2 : gameOver ? DEATH_PIC : JUMP_PIC], 
    (position.x * echelle.x) + referentiel.x, (position.y * echelle.y) + referentiel.y);

  for (float[] i : cactuses) {
    if (i[TYPE] > -1 && i[POS] > - referentiel.x - 50) {
      ///reference.x: ordonnée du 0
      image(cactusImgs[(int) i[TYPE]], (echelle.x * i[POS]) + referentiel.x, referentiel.y);
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
      dJumping = true;
      // SOUND ERROR: sounds[JUMP_SOUND].play();
    }
  } else if (dShowCommandBar && key != '²') {
    char k = (char) (key | 32);
    if (k >= 'a' && k <= 'z') {
      command += k;
    } else if (key == BACKSPACE) {
      command = command.substring(0, max(0, command.length() - 1));
    } else if (key == DELETE) {
      command = "";
    } else if (key == ENTER) {
      if (command.equals("gravityball")) {
      } else if (command.equals("immortal") || command.equals("invincible")) {
        dImmortal = !dImmortal;
      } else if (command.equals("debug")) {
        debug = !debug;
      }
    }
  } else if (key == '²') {
    dShowCommandBar = !dShowCommandBar;
  } else if (debug) {/// Cheat codes
    /// Spécificitées de l'ASCII: les minuscules sont à 32 près des majuscules
    ///  Le ou unaire '|' permet de convertir majuscule->minuscule et minuscule->minuscule
    ///  comme vu en amphi et en TD
    if (key == TAB) {
      dSlowDown = true;
    } else {
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
}

void keyReleased() {
  if (key == TAB) {
    /// Son effet n'est que temporaire
    dSlowDown = false;
  }
}

void mouseDragged() {
}

void mousePressed() {
}

void mouseReleased() {
}
