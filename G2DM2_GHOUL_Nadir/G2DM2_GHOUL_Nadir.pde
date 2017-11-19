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
///  RESET:          Réinitialise la partie (appelle initJeu())
///  RESTART:        Réinitialise le jeu (appelle setup())
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
/// le niveau du sol, le zoom, la vitesse
///  Importante note: les distances utilisées seront des "mètres", une unitée arbitraire
///    servant à simplifier les calculs, en effet il sera plus simple de calculer comme
///    s'il y avait une pesanteur qui nous tire vers le bas par exemple
PVector repere, echelle, vitesse, position, acceleration;

/// La vitesse initiale du saut et la force de pesanteur
//final float g0 = 9.81, vitesseSaut0 = 98.1;
final float g0 = 2500, vitesseSaut0 = 850, vX0 = 125;

float jumpSpeed;


/// L'unique ordonnée du sol: à parir de celle-ci, on pourra trouver les autres, cela
///   peut rendre possible l'élargissement de l'écran (nous ne sommes plus limité à trois
///   "instances" du sol)
float solX;

////////////////////////////////////////////////////////////////////////////////////////
float cactuses[][], NB_MAX_CACTUSES = 10;
float[][] dimensionsCactus;
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

// Poursuite du curseur
boolean dPoursuite;

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

  cactusImgs = new PImage[2];
  cactusImgs[SIMPLE] = loadImage("cactus1.png");
  cactusImgs[TRIPLE] = loadImage("cactus2.png");

  ///  Chaque élément sera du type w, h, r, Ax, Ay, Bx, By, wR, hR, rR, AxR, AyR, BxR, ByR
  ///    w: La largeur en pixels
  ///    h: La hauteur en pixels
  ///    r: Le "rayon" de l'ellipse, en pixels
  ///   Ax: L'abscice du premier foyer, relatif au centre de l'image, en pixels
  ///   Ay: L'ordonnée du premier foyer, relatif au centre de l'image, en pixels
  ///   Bx: L'abscice du second foyer, relatif au centre de l'image, en pixels
  ///   By: L'ordonnée du second foyer, relatif au centre de l'image, en pixels
  ///
  ///  w, h, r, Ax, Ay, Bx, By sont les valeur vues plus hautes, converties en
  ///      fonction du repere actuel, par conséquent elles doivent être mises
  ///      à jour le plus régulièrement possible
  ///
  /// TODO:  "Encapsuler" les variables globales pour mettre à jour ce genre de
  ///        variable automatiquement
  dimensionsCactus = new float[2][14];

  /// TODO: Permettre de modicier ceci pour gérer la difficultée
  for (int i = 0; i < 2; ++i) {
    dimensionsCactus[i][0] = cactusImgs[i].width;
    dimensionsCactus[i][1] = cactusImgs[i].height;
    /// Le rayon, par définition est la distance AM + MB pour tout
    ///  point M de l'ellipse ayant pour fouers A et B, donc si
    ///  les trois points sont alignés, alors on a AM + MB = AB + 2BM
    ///  par symétrie, on a AB + 2MB = NA + AB + BM, avec N le point
    ///  opposé à M, c'est à dire la symétrie de M par rapport
    ///  au centre de [AB], donc NA + AB + BM = r, or
    ///  NA + AB + BM est égal au plus grands des deux côtés, car
    ///  ce que j'ai dit plus tôt s'applique uniquement dans le cas
    ///  ou N, M, A et B sont alignés, c'est à dire sur la droite (AB).
    /// Nous utiliserons la case numéro 6 pour respecter un certain ordre, ce
    ///  qui sera utile lors de la mise à jour des dernière 7 valeurs, en effer
    ///  comme cela, les cases paires < 6 sont relatives à x, les cases paires
    ///  sont relatives à y et la 6e est x ou y en fonction de la forme
    ///  (portrait/paysage).
    dimensionsCactus[i][6] = max(dimensionsCactus[i][0], dimensionsCactus[i][1]);
    /// Nous connaisons le rayon, la hauteur et la largeur, par conséquent
    ///  ce que nous pouvons dire, c'est que les deux foyers seront alignés
    ///  sur x si l'image est en paysage, sur y si l'image est en portrait,
    ///  et bien sûr sur les deux si l'image est carré, par conséquent on va
    ///  utiliser le centre de l'image comme centre du repère, et A sera la
    ///  symétrie de B oar rapport a O, donc nous aurons un seul calcul a faire
    /// Dans le cas ou l'image est en mode portrait
    if (dimensionsCactus[i][0] > dimensionsCactus[i][1]) {
      /// les ordonnées sont nulles
      dimensionsCactus[i][3] = dimensionsCactus[i][5] = 0;

      /// Maintenant, nous allons faire de même en prenant le cas limite, dans lequel
      ///  M est cette fois sur l'axe médian à (AB), par conséquent, on a:
      ///    -> les deux angles (BAM et ABM) sont égaux
      ///    -> les deux distances AM et BM sont égales, or AM + BM = r, donc
      ///        AB = BM = r / 2
      ///    -> la distance OM est égale à la moitié du petit diamètre
      /// Après quelques calculs que j'éspère correct, j'obtiens
      ///  abs(x) = sqrt(pow(r / 2, 2) - pow(OM, 2))
      ///  => théorème de pythagore
      dimensionsCactus[i][2] = sqrt(pow(dimensionsCactus[i][6] / 2, 2) - pow(dimensionsCactus[i][1] / 2, 2));

      /// Les abscicces sont opposées
      dimensionsCactus[i][2] = -dimensionsCactus[i][4];
    } else if (dimensionsCactus[i][0] < dimensionsCactus[i][1]) {
      /// Pour les explications, voir plus haut, dans le cas w > h
      dimensionsCactus[i][2] = dimensionsCactus[i][4] = 0;
      dimensionsCactus[i][3] = sqrt(pow(dimensionsCactus[i][6] / 2, 2) - pow(dimensionsCactus[i][0] / 2, 2));
      dimensionsCactus[i][5] = -dimensionsCactus[i][3];

      /// Si les dimensions sont les mêmes, il s'agit d'un cercle
    } else {
      dimensionsCactus[i][2] =
        dimensionsCactus[i][3] =
        dimensionsCactus[i][4] =
        dimensionsCactus[i][5] = 0;
    }
  }

  // charge les sons
  // SOUND ERROR: sounds = new SoundFile[3];
  // SOUND ERROR: sounds[JUMP_SOUND] = new SoundFile(this, "saut.mp3");
  // SOUND ERROR: sounds[DEATH_SOUND] = new SoundFile(this, "boom.mp3");
  // SOUND ERROR: sounds[CENT_SOUND] = new SoundFile(this, "cent.mp3");

  acceleration = new PVector(2, g0);


  /// Les variables de débogage
  dSpeedFollowsMouse = false;
  dGravityFollowsMouse = false;
  //// TODO: Show
  dContinuousTrajectory = false;
  dShowCommandBar = false;
  dShowHitBoxes = true;
  dRareteMouse = false;
  dPrediction = true;
  dSlowLanding = false;
  debug = true;

  dPoursuite = true;

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
  repere = new PVector(50, (height * 3 / 4));
  echelle = new PVector(2, -1);

  // La vitesse de défilement sera rattaché au perso
  vitesse = new PVector(vX0, 0);// Il va vers la droite
  position = new PVector(0, 0);// Il définit l'origine

  // La rareté évolue au cours du jeu, elle doit donc être réinitialisée ici
  rarete = 100;

  // initialise le sol
  solX = 0;

  score = 0;

  cactuses = new float[(int) NB_MAX_CACTUSES][2];
  for (float[] i : cactuses) {
    i[TYPE] = i[POS] = -1;
  }

  /// Si on meurt en sautant, alors on n'a pas le temps de mettre à jour cette
  ///  variable, il nous fallais sauter et réaterrir pour la repasser à false
  dJumping = false;

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
  gestionEffets();

  // si le jeu n'est pas terminé
  if (!gameOver) {
    calculeScore();
    testeCollisions();

    /// Nous ne pouvons utiliser mouseMoved, parce que le dinosaure
    ///    bouge et finira par dépasser la souris, et sa trajectoire
    ///    ne serai recalculée qu'en cas de mouvement de celle-ci,
    ///    sans tenir en compte du fait qu'elle bouge en permanence
    ///    de vitesse.x
    poursuite();

    mouvementSol();
    mouvementCactus();
    mouvementDino();
  }
  // sinon
  else {
    textAlign(CENTER);
    textSize(TEXT_SIZE);
    text("G A M E  O V E R", width/2, height/2);
    highScore = max(score, highScore);
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
//  Gere les différents effets, dont:
//    le ralenti et l'accélatation du temps dT
//    le flou et le passage jour/nuit
//
//  TODO: Revérifier cette procédure et au cas échéant la découper
//
////////////////////////////////////////////////////////////////////////////////////////
void gestionEffets() {
  /// En général, les conditions sont organisées pour avoir le moins possible d'indentations,
  ///  quitte à alourdir légèrement le code

  /// Dans la suite, je parler de "bloquer" et de "débloquer", ce qui correspond à un bloquage/débloquage de la fonction
  ///  de ralentissement, à ne pas confondre aved dSlowDown, car il y a de multiples raisons de ralantir, mais quelle
  ///  que soit la raison de le faire, si la fonction est "bloquée", on ne ralentis pas

  /// Trois cas peuvent mener à un ralentissement du temps:
  ///  un ralentissement ordonné par l'utilisateur (dSlowDown)
  ///  un ralentissement ordonné par l'ordinateur (dAutoSlowdown)
  ///  un ralentissement lié à la fin de saut ralentie (slowLanding)
  boolean slowLanding = dJumping && vitesse.y < 0 && dSlowLanding;


  /// Pour les deux premier cas, nous prendrons pour limite dTooMuchSlowDownLimit, sinon
  ///  nous prendrons le tiers de cette limite
  float limit = (dSlowDown || dAutoSlowDown) ? dTooMuchSlowDownLimit : (dTooMuchSlowDownLimit / 3);
  boolean limitReached = dSlowDownRate > limit;


  /// Si nous devons ralentir et que nous ne sommes pas encore "bloqués", nous ralentissons,
  ///  bien sûr après avoir vérifié si nous pouvons toujours le faire, avec limitReached
  boolean slowDown = !dTooMuchSlowDown && (slowLanding  || dSlowDown || dAutoSlowDown);

  /// TODO: Pk 3 et pa 4 ou 5?
  /// TODO: Auto -> 1 ou 1/3?

  /// Le cas ou nous ralentissons, pour l'instant les coeficients sonts les mêmes
  if (slowDown && !limitReached) {
    dSlowDownRate += 1;
    dT *= dSlowDownIncrement;

    /// Si la limite a été atteinte, mais que nous devons ralentir, il faut bloquer
  } else if (slowDown) {
    dTooMuchSlowDown = true;
    ///  Sinon, c'est que nous n'avons pas à ralentir, dans ce cas, on vérifie si nous
    ///    pouvons accélérer, dans ce cas, nous allons accélerer à peu près deux** fois
    ///    plus vite* pour ne pas trop handicaper le jeu, car tant que nous avons besoin
    ///    de temps, nous devrons ralentir (au passage, la limite est plus utile pour
    ///    contrer d'eventuels défauts dans les algorithmes d'aides - par exemple dans
    ///    une hypotétique aide automatique - que pour limiter le joueur, la limite
    ///    pour celui-ci sera donc plus large).

    ///  *ceci est vrai pour la première implémentation, mais en vérité, ce sera légèrement
    ///    moins, lorsqu'il restera un nombre impair d'itérations, j'itèrerai une seule fois,
    ///    sinon, je le ferais deux fois**, à terme, il y aura presque toujours deux** itérations,
    ///    sauf si nous partons d'un nombre impair**, dans ce cas il n'y aura qu'une fois une simple
    ///    itération, car les restes seront décrémentés systématiquement de deux**.

    ///  **ou trois, ou quatres, ou ..., dans ce cas, nous utiliserons autre chose que la parité,
    ///    mais le modulo, - ce qui est le cas même pour la parité
    ///      TODO:Ajout d'une constante ou d'une maniere de changer deux si nécessaire
  } else if (dSlowDownRate > 0) {

    /// TODO: Rendre cette variable plus visible en la rendant globale par exemple
    final int ratioDeceleration = 2;

    /// Ceci est l'implémentation de ce qui a été dit plus tôt
    dT /= (dSlowDownRate % ratioDeceleration == 0 ? pow(dSlowDownIncrement, ratioDeceleration) : dSlowDownIncrement);
    dSlowDownRate -= dSlowDownRate % ratioDeceleration == 0 ? ratioDeceleration : 1;

    /// , et si nous ne pouvons plus accélerer (on doit revenir au point de départ,
    ///    pas plus), alors nous pouvons "débloquer"
  } else {
    dTooMuchSlowDown = false;
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
}

////////////////////////////////////////////////////////////////////////////////////////
//
//  Cette procédure va:
//    - Calculer le score
//    - Jouer le son "cent" tous les 100 points
//
//  Notes:
//    - Pour calculer le score, je me base sur la position réelle du dinosaure, car
//      pour simplifier les calculs, j'ai décider de faire bouger le référentiel avec
//      le dinosaure, ce qui veut dire que la réelle position du dinosaure est relative
//      au sol, qui commence à x=0, et qui bouge en sens inverse par rapport au
//      dinosaure, par conséquent Xdino = Xrel - Xcactus
//                                Xdino = 0    - Xcactus
//    - Le choix de ce calcul était certes attrayant, mais le score défilais trop vite,
//      par conséquent j'ai décidé de réduire ce score en divisant par 20
//      => j'ai choisi 20 un peu au hasard
//
//  TODO: Remplacer 20 par une constante globale
//  TODO: Ajout de differentes methodes de score
//
////////////////////////////////////////////////////////////////////////////////////////
void calculeScore() {

  /// Plus d'informations plus haut
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
//  Teste la collision entre le dino et un cactus
//  Elle prends pour paramètre:
//    p: Un PVector contenant la position à vérifier
//      pour choisir la position du dino, laisser vide
//        ->voir fonctions ci-après
//
//  Notes:
//    - Les positions sont relatives au référentiels, et non à l'écran
//      =>  Cela devrait être un peu plus rapide car les positions ne seront pas
//          systématiquement converties en pixels
//      =>  Chaque dessin sera d'autant plus lent que les positions seront
//          systématiquement converties en pixels
//    - Les cactus ne seront pris en compte que s'ils sont dans la partie "droite" du repère,
//      c'est à dire sin nous ne l'avons pas encore dépassé, par conséquent cela n'aura pas
//      beaucoups d'incidence vu que la vitesse sera toujours positive, et par conséquent
//      c'est en changant l'échelle de signe que l'on pourra le faire aller de droite à gauche
//
////////////////////////////////////////////////////////////////////////////////////////
boolean collision(final PVector p) {
  ///  Nous allons dessiner, donc je redéfinis certains paramères globaux au cas où ils
  ///    auraient été modifiés en dehors de la fonction
  strokeWeight(1);

  ///  Comme je ne peux pas utiliser les dimesions en pixels, alors je convertis en sens inverse,
  ///    Mais uniquemet une fois par appel de fonction, cela reste moins qu'avant.
  for (float[] i : dimensionsCactus) {
    /// Nous mettons à jour les variables que nous allons utiliser,
    ///  on peut voir les dimensions comme étant une liste du type
    ///     [w, h, r, Ax, Ay, Bx, By]
    for (int j = 0; j < 6; ++j) {
      /// Nous prenons la valeur 7 cases avant et nous la converissons,
      ///  selon x pour les cases paires et selon y pour les impaires
      i[j + 7] = (i[j] / ((j % 2 == 0) ? echelle.x : echelle.y));
    }

    /// Si le plus grand diamètre est horisontal, ou vertical
    i[13] = (i[0] > i[1]) ? (i[0] / echelle.x) : (i[1] / echelle.y);
  }


  /// TODO: Réimplémenter en ce servant de http://www.e-lc.org/docs/2007_01_17_00_46_52/

  ///  Pour calculer si une sphère (le presonnage) entre en collision avec une ellipse (le cactus),
  ///    je dois vérifier si (d1 + d2) < rE + 2*rC
  ///    du cactus, avec:
  ///      d1:la distance entre le centre du cercle et le premier foyer de l'ellipse
  ///      d2:la distance entre le centre du cercle et le second foyer de l'ellipse
  ///      rC:le rayon du cercle
  ///      rE:la distance egale à d1 + d2 our tout points de l'ellipse
  ///    L'imprécision sera de l'ordre de abs(tan(alpha) - alpha), avec alpha
  ///      l'angle AMB avec A et B les foyers et C le centre du cercle

  if (dShowHitBoxes) {
    /// Comme dit précédemment, nous calculons la localisation des points uniquement en temps voulu,
    ///  sinon, nous utiliserons systématiquement des positions relatives au référentiel
    ellipse(
      (echelle.x * p.x) + repere.x, 
      (echelle.y * p.y) + repere.y, 
      hitBoxRadius * 2, hitBoxRadius * 2
      );
  }

  ///  Nous pouvons retourner la valeur en cas de choc ou attendre pour afficher toutes les hitbox,
  ///    ou nous pouvons utiliser deux boucles

  /// Une première en cas d'affichage des hitboxes, ...
  if (dShowHitBoxes) {
    for (float[] i : cactuses) {
      int type = (int) i[TYPE];
      if (i[POS] > 0) {
        ellipse(
          (i[POS] * echelle.x) + repere.x, 
          repere.y, 
          dimensionsCactus[type][0], 
          dimensionsCactus[type][1]
          );
      }
    }
  }

  /// ... et une seconde dans tous les cas




  for (float[] i : cactuses) {
    /// TODO: Creer une option por aussi prendre en compte l'autre côté
    int type = (int) i[TYPE];
    if (type > -1) {
      float rE = dimensionsCactus[type][13];
      float rC = hitBoxRadius;

      if (i[POS] > p.x || i[POS] + rC + rE > p.x) {

        float Ax = dimensionsCactus[type][7 + 2] + i[POS];
        float Ay = dimensionsCactus[type][7 + 3];
        float Bx = dimensionsCactus[type][7 + 4] + i[POS];
        float By = dimensionsCactus[type][7 + 5];

        float d1 = sqrt(pow(Ax - p.x, 2) + pow(Ay - p.y, 2));
        float d2 = sqrt(pow(Bx - p.x, 2) + pow(By - p.y, 2));


        if ((d1 + d2) < rE + 2*rC) {
          return true;
        }
      }
    }
  }
  return false;
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Les "wrapper" de la fonction collision
//
////////////////////////////////////////////////////////////////////////////////////////

///  Sans argument, on utilise la position actuelle:
///    Nous passons la position en paramètre,
boolean collision() {
  return collision(position);
}

///  Nous pourrons aussi lui donner des int ou des floats
boolean collision(float x, float y) {
  return collision(new PVector(x, y));
}
boolean collision(int x, int y) {
  return collision(new PVector(x, y));
}

/// Ou encore une liste de positions
boolean collision(int[] p) {
  return collision(new PVector(p[0], p[1]));
}
boolean collision(float[] p) {
  return collision(new PVector(p[0], p[1]));
}


////////////////////////////////////////////////////////////////////////////////////////
//
//  Teste la collision entre le dino et un cactus, cette procédure ne servira que
//    d'interface pour être facilement appelé dans la fonction draw
//
//  Elle ne prend aucun paramètre et ne retourne rien
//
////////////////////////////////////////////////////////////////////////////////////////
void testeCollisions() {
  // Le décalage n'a pas d'importance
  if (collision(position) && !dImmortal) {
    gameOver = true;
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le mouvement du sol et accélère la vitesse horizontale
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
// Ajoute un nouveau cactus
//
////////////////////////////////////////////////////////////////////////////////////////
void ajoutCactus() {
  float[] cactus = cactuses[(int) random(0, cactuses.length)];
  if (cactus[POS] < 0) {
    cactus[TYPE] = (random(0, 50) < 25) ? SIMPLE : TRIPLE;
    cactus[POS] = (int) (width * 1.1 / echelle.x);
  } else {
    for (float[]c : cactuses) {
      if (c[POS] < 0) {
        c[TYPE] = (random(0, 50) < 25) ? SIMPLE : TRIPLE;
        c[POS] = (int) (width * 1.1 / echelle.x);
        return;
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le mouvement des cactus
//
////////////////////////////////////////////////////////////////////////////////////////
void mouvementCactus() {
  /// Rareté: à chaque rafraichissement: 1/rareté chace d'en avoir un nouveau
  //// TODO: Améliorer cela, par exemple en l'auguementant avec le temps
  if (random(0, rarete) < 1) {
    ajoutCactus();
  }
  /// Bouger tous les cactus en même temps
  for (float[]i : cactuses) {
    i[POS] -= (vitesse.x * dT);
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Focntion permettant de retourner la distace horizontale du cactus
//    le plus proche du dinosaure
//
////////////////////////////////////////////////////////////////////////////////////////
float distanceCactus() {
  float d = 1000000, e;
  for (float[]i : cactuses) {
    if (i[POS] > -1) {
      e = i[POS] - (cactusImgs[(int) i[TYPE]].width / 2 * echelle.x);
      if (e > 0 && e < d) {
        d = e;
      }
    }
  }
  return d;
}

////////////////////////////////////////////////////////////////////////////////////////
//
//  Sympatique fonction permettant de savoir si oui ou non le joueur va mourir
//    ne fonctionne pas uniquement si le joueur saute, car elle ne fait que
//    tester pour cela chacunes des positions qu'on lui donne et renvoie vrai
//    dès qu'une position est "dangereuse", par conséquent plus cette dernière
//    est proche du début de la liste, plus la fonction sera rapide
//
//  La fonction prends pour unique paramère une liste de positions, sous la forme d'une
//    matrice de floats, de taille variable
//
// TODO: Ajouter une implémentation (activable ou désactivable) se servant uniquement
//    de la fonction distanceCactus pour donner une approximation du résultat
//
////////////////////////////////////////////////////////////////////////////////////////
boolean mortALHorizon(float[][] positions) {
  int tombeDepuis = 0;
  for (float[] position : positions) {
    /// Si nous trouvons un quelconque y négatif, c'est que nous avons atteint la limite
    ///  du tableau, dans ce cas, aucune positions ne s'est révélé dangereuse
    tombeDepuis = (position[1] < 1) ? (tombeDepuis + 1) : 0;
    if (position[1] < 0) {
      return false;
    } else if (tombeDepuis > tempsDeReaction) {
      return false;
    } else if (collision(position)) {
      return true;
    }
  }
  return false;
}
boolean mortALHorizon() {
  return mortALHorizon(prochainesPositions());
}
////////////////////////////////////////////////////////////////////////////////////////
//
// Affiche des ellipses correspondant à des hitboxes aux positions données
//
////////////////////////////////////////////////////////////////////////////////////////
void afficherHitBoxes(float[][] positions, int step) {
  /// TODO: Inutile de charger des cases mémoires en plus, donc retirer ces variables
  ///        superflues
  float x, y, _x, _y;
  _x = positions[0][0];
  _y = positions[0][1];
  for (int i = 1; i < positions.length; i += step) {
    /// Si nous trouvons un quelconque y négatif, c'est que nous avons atteint la limite
    ///  du tableau, dans ce cas, aucune positions ne s'est révélé dangereuse
    x = positions[i][0];
    y = positions[i][1];
    if (y < 0) {
      return;
    }
    // positions[i] = {x, y}
    //    if (dContinuousTrajectory) {
    line((_x * echelle.x) + repere.x, (_y * echelle.y) + repere.y, 
      (x * echelle.x) + repere.x, (y * echelle.y) + repere.y);
    //  } else {
    ellipse((x * echelle.x) + repere.x, 
      (y * echelle.y) + repere.y, hitBoxRadius * 2, hitBoxRadius * 2);
    //}
    _x = x;
    _y = y;
  }
}
void afficherHitBoxes(float[][] positions) {
  afficherHitBoxes(positions, 1);
}
////////////////////////////////////////////////////////////////////////////////////////
//
//  Retourne un array de prochaines positions, au regard de:
//    p: La position de départ
//    v:  La vitesse de départ
//    a:  L'accélération (suposée constante)
//    t:  Le laps de temps qui s'écoule entre deux frames
//
//  Cette fonction a pour but de simplifier les autres fonctions, en calculant les prochaines
//    positions uniquement une fois par itération
//
//  Notes:
//    - Les valeurs seront toujours, sauf indication contraire, dépendantes du repère
//    - Le dinosaure ne peux pas tomber plus bas que le sol (0), par conséquent pour évier
//      les itérations inutiles, la dernière case sera systématiquement de -1, un peu comme
//      le '\0' à la fin des chaines de caractères en C
//    - Les paramètres n'ont qu'une seule lettre, pour pouvoir les différencier des
//      variables globales associées
//    - Les paramètres sont des objets, donc vous pouvez les remplir avec null pour utiliser
//      les valeurs globales associées, donner une valeur négative à t aura le même effet
//    - La trajectoire ne sera pas exacte pour un bon nombre de facteurs, dont:
//      * Les accélérations qui peuvent changer
//      * dT, qui pourra aussi changer
//
//  TODO: Ajouter une variable globale associée à la taille limite de positions, qui
//    pourra par exemple évoluer en fonction des performances de la machines, en la
//    réduisant out l'auguementant si nécessaire, avec par exemple un PVector de type
//      PVector(min, max, step, value)
//
//  TODO: Choisir entre double et float
//
////////////////////////////////////////////////////////////////////////////////////////
float[][] prochainesPositions(PVector p, PVector v, PVector a, float t) {

  println(p, v, a, t);
  /// Comme dit plus haut: null => defaut
  p = (p == null) ? position.copy()      : p;
  v = (v == null) ? vitesse.copy()       : v;
  a = (a == null) ? acceleration.copy()  : a;
  t = t < 0       ? dT                   : t;

  // Ceci évite les calculs inutiles, en réduisant le nombre de cases à lire
  //  pour la fonction appelante, et en réduisant le nombre de calculs de collisions
  int index = 0, tombeDepuis = 0;


  /// TODO: Rendre cela global, et modifiable au regard des performances de la machine
  final int nombrePoints = 100;


  /// Valeur retournée
  float[][] positions = new float[nombrePoints][2];


  /// Cette limite est la limite à "droite", car en fonction de scale.x, la droite peux devenir la gauche
  ///  Elle correspond au choix à la limite droite (width) ou à la limite gauche (0) en fonction de l'echelle
  float limite = ((echelle.x > 0 ? width : 0) - repere.x) / echelle.x;
  /// Nous allons commencer par savoir si nous sommes à gauche de la limite à droite, en effet franchir la
  ///    limite veux en réalité dire passer de gauche à droite ou inversement de droite à gauche
  boolean aGauche = p.x < limite;


  /// Nous commençons par la position actuelle, et nous allons donc commencer
  ///  à écrire à la position 0 + 1, donc la position 1
  positions[0][0] = p.x;
  positions[0][1] = p.y;
  index = 1;

  ///  Boucler jusqu'à la fin, c'est à dire jusqu'à que nous atteignons le côté droit de l'écran
  ///    quand les points sont trop raprochés, nous devrons les séparer
  ///    pour cela, nous utiliserons les rayons, les cercles ne doivent pas se
  ///    renter dedans
  ///  On commence par incrémenter x, sinin le premier sera juste au dessus
  ///    de la position actuelle
  ///  Note: j'utilise xor, mais je pense que les opérations seraon plus ou moins les memes
  ///    (A ^ B) == (A != B) dans le cas des booleens
  for (p.x += v.x * t; (index < positions.length) && (aGauche ^ (p.x > limite)); p.x += v.x * t) {

    /// Ceci n'est qu'une copie de ce que vous pouvez voir au début de cette fonction
    p.y += v.y * t;
    if (p.y < 0) {
      p.y = 0;
      v.y = 0;
    } else if (p.y > 0) {
      v.y -= acceleration.y * t;
      /// Ceci est calculé quand la postion du sol est mise à jour
      v.x += a.x * t;
    } /// Si y = 0, nous ne faisons rien

    /// Si nous sommes sur le sol pour un certain temps et que nous montons, alors
    ///  nous ne sommes plus sur le sol, et nous sommes tombeDepuis 0
    tombeDepuis = p.y < 1 ? tombeDepuis + 1 : 0;

    /// Dans le cas où nous aurions touchés le sol, il nous faudra éloigner les points
    /*if (tombeDepuis > tempsDeReaction) {
     v.x += 2;
     }*/

    /// Ajout du couple de coordonnées à la liste
    positions[index][0] = p.x;
    positions[index][1] = p.y;

    /// Incrémentation de l'indice
    index++;
  }
  if (index < positions.length) {
    positions[index][0] = -1;
    positions[index][1] = -1;
  }

  return positions;
}

//  Fonction utilisée pour rendre le code plus lisible, en effet quand il n'y aura que
//    deux paramètres, c'est à dire dans l'immense majorité des cas, je pourrais
//    me permettre d'omettre les deux derniers paramètres, les valeur re retour étant
//    des tableaux (pointeurs), le programme ne sera pas alourdi par de nombreuses
//    copies, car les pointeurs sont rapides a transmettre (je pense).
float[][] prochainesPositions(PVector p, PVector v) {
  return prochainesPositions(p, v, null, -1);
}
float[][] prochainesPositions() {
  return prochainesPositions(null, null, null, -1);
}
// Si nous voulons avoir la liste de positions en cas de saut
float[][] prochainesPositions(boolean saut) {
  if (saut) {
    return prochainesPositions(
      new PVector(position.x + tempsDeReaction, position.y), /// Position initiale
      new PVector(vitesse.x, jumpSpeed)/// Vitesse initiale
      );
  }
  return prochainesPositions();
}

////////////////////////////////////////////////////////////////////////////////////////
//
//  Définit si oui ou non le joueur peut sauter et rester vivant
//
//    X, Y: Comme toujours, les positions X et Y seront les positions dans le référentiel,
//          et comme toujours il sera plus rapide de calculer cela en omettant l'affichage
//          des hitboxes, car cela nous permettra de ne pas changer de référentiel, en
//          effet les coordonnées du référentiel vont systématiquement être modifiées
//          pour pouvoir être affiché car elles sont systématiquement stiquées en
//          fonction du référentiel
//
//    showBoxes: Ceci est important, car comme dit précédemment ce sera coûteux de le faire,
//                TODO: lui donner l'utilité qu'il mérite
//
////////////////////////////////////////////////////////////////////////////////////////

boolean peutSauter(float X, float Y, boolean showBoxes) {

  /// Je préfère sauvegarder cette valeur, au cas ou cette variable vienais à changer
  ///  car nous serons obligés de la modifier pour n'afficher qu'une fois les hitboxes
  ///  actuelles
  /// TODO: Gérer les éventuels effets de bords que peuvent avoir cette ligne, car la
  ///    variable est suceptible de changer entre temps, si c'est le cas, par exemple si
  ///    l'utilisateur relache la touche associée, alors le programme la gardera active
  boolean showHitBoxes = dShowHitBoxes;




  /// On prends les prochaines positions à partir de la position X, Y, et d'un
  ///    hypothétique saut et on les donne unes par unes à collision pour voir
  float[][] positions = prochainesPositions(true);



  /// TODO: N'afficher que les points en l'air
  /// TODO: Creer une fonction retournant uniquement les cactus visibles

  /// Si nous sommes au sol, alors nous aurons une prédiction hypotétique
  //fill((position.y < 10 ? #00ff00 : #0000ff), 255);
  /// TODO:Combiner ce facteur avec le facteur collision

  /// TODO: Faire le point sur quelles fonctions peuvent et quelles fonctions ne peuvent pas ecrire

  /// Nous ne voulons pas que les box soit affichées encore et encore
  boolean show = dShowHitBoxes;
  dShowHitBoxes = false;

  boolean vaMourir = mortALHorizon(positions);

  /// Rouge si nous allons toucher, vert sinon
  /// TODO: Est-ce que cela va causer des erreurs?
  fill(vaMourir ? #ff0000 : #00ff00, 64);

  dShowHitBoxes = show;

  if (dShowHitBoxes) {
    afficherHitBoxes(positions);
  }

  return !vaMourir;
}

////////////////////////////////////////////////////////////////////////////////////////
//
// calcule le mouvement du dino, et affiche la trajectoire (rouge ou verte en fonction
//  de la dangerosité du chemin
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
    vitesse.y -= acceleration.y * dT;
  }

  if (dJumping) {
    if (mortALHorizon()) {
      text("DIE", width / 2, height / 2);
    }
  } else {

    /// On calcule toutes les positions en partant du principe
    ///  que nous commencions à sauter maintenant
    float[][] positions = prochainesPositions(true);

    /// On recherche le point le plus haut, et on en déduit xMax,
    ///  abscisse pour laquelle le dino est le plus loin du sol
    float _max = 0, xMax;
    int maxIndex = 0;
    for (int i = 0; i < positions.length; ++i) {
      if (_max < positions[i][1]) {
        _max = positions[i][1];
        maxIndex = i;
      }
    }
    xMax = positions[maxIndex][0];
    ellipse(xMax * echelle.x + repere.x, _max * echelle.y + repere.y, 50, 50);
    afficherHitBoxes(positions);
    if (peutSauter(position.x, position.y, true)) {
      text("JUMP " + distanceCactus() + " " + _max + " " + maxIndex, width / 2, height / 2);
      if (distanceCactus() < xMax) {
        /// J'ai rajouté cette fonction au cas ou les variables/constantes changent
        jump();
      }
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
    image(solImg, x + repere.x, repere.y + 25);
  }

  // Affiche le dino TODO: Faire mieux
  image(dinoImgs[position.y < 10 ? (int) (frameCount * 3 / frameRate) % 2 : gameOver ? DEATH_PIC : JUMP_PIC], 
    (position.x * echelle.x) + repere.x, (position.y * echelle.y) + repere.y);

  for (float[] i : cactuses) {
    if (i[TYPE] > -1 && i[POS] > - repere.x - 50) {
      ///reference.x: ordonnée du 0
      image(cactusImgs[(int) i[TYPE]], (echelle.x * i[POS]) + repere.x, repere.y);
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
  /// TODO: Savoir si c'est une touche après l'autre ou pas
  if ((key == ' ') && gameOver) {
    println("ici");
    initJeu();
  } else if (key == CODED && keyCode == UP) {
    ///  On aurai pu vérifier dJumping, mais elle n'est mise à jour que
    ///    quand on a déjà touché le sol, par conséquent les évitements
    ///    seront plus difficile, vu qu'en plus de prévoire les cactus,
    ///    il faudra aussi prévoire le fait que le saut se déroule aussi sur x,
    ///    et que par conséquent même si je saute avant le cactus, je pourrais le toucher
    if (position.y < 10) {
      ///  Encapsulation: Les variables pourront changer, et la manière de 
      ///    sauter aussi, mais jump() voudra toujours dire jump()
      jump();
      /// TODO: Ajout un booleen pour vérifier en amont la possibilité d'un saut
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
      } else if (command.equals("slowlanding")) {
        dSlowLanding = !dSlowLanding;
      } else if (command.equals("helpmeee")) {
        dHelp = !dHelp;
      } else if (command.equals("viensamoi")) {
        dPoursuite = !dPoursuite;
      } else if (command.equals("reset")) {
        initJeu();
      } else if (command.equals("restart")) {
        setup();
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
      default:
        switch(key) {
        case '+':
          ajoutCactus();
        }
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// - Change l'acceleration gravitationelle pour pouvoir avoir un saut de y mètres
// - redémarre le jeu quand on appuie sur la barre d'espace
//
////////////////////////////////////////////////////////////////////////////////////////
void reglerHauteurSaut(float y) {
  acceleration.y = y * 10;
  y = (y * echelle.y) + repere.y;
  line(0, y, width, y);
}
/// Utilise l'ordonnée de la souris
void reglerHauteurSaut() {
  reglerHauteurSaut((mouseY - repere.y) / echelle.y);
}

void keyReleased() {
  if (key == TAB) {
    /// Son effet n'est que temporaire
    dSlowDown = false;
  }
}

void mouseDragged() {
  reglerHauteurSaut();
}

void mousePressed() {
}

void mouseReleased() {
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
    acceleration.y = 100 * g0 / mouseY;
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

  text("Echelle horizontale           " + echelle.x, x, y);
  y += TEXT_SIZE / 3;

  text("Echelle verticale             " + echelle.y, x, y);
  y += TEXT_SIZE / 3;

  /// Ligne vide
  y += TEXT_SIZE / 3;

  text("Position                      " + position.y, x, y);
  y += TEXT_SIZE / 3;

  text("Vitesse de saut               " + jumpSpeed, x, y);
  y += TEXT_SIZE / 3;

  text("Acceleration gravitationnelle " + acceleration.y, x, y);
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

  text("Aide                          " + (dHelp ? "ON" : "OFF"), x, y);
  y += TEXT_SIZE / 3;

  text("Poursuite                     " + (dPoursuite ? "ON" : "OFF"), x, y);
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

/// x(t) = vx*t
/// y(t) = vy*t - g*t²
////
/// tLim = vx / largeur

/// yIdeal(tLim) = vy*tLim - gIdeal*tLim²
/// yActuel(tLim)= vy*tLim - gActuel*tLim²

/// gIdeal = (vy / tLim) - (yIdeal / tLim²)

/// On vherche à faire des prévisions à la seconde, car à t = 1, t² = t

float difference(final float[][] l, final PVector p) {
  int index = -1;
  for (int i = 0; i < l.length && index < 0; ++i) {
    if (l[i][0] > p.x) {
      index = i;
    }
  }
  float y = (l[index][1] + l[index - 1][1]) / 2;
  return (p.y - y);
}

void poursuite() {
  if (!dPoursuite) {
    jumpSpeed = vitesseSaut0;
    acceleration.y = g0;
    return;
  }
  /// Le dino ne pourra voler que s'il saute
  if (!dJumping) {
    jumpSpeed = 10;
    acceleration.y = 0;
    jump();
  } else {

    /// Calculer d'emblée le point du repère visé par la souris
    PVector target = new PVector(
      (mouseX - repere.x) / echelle.x, 
      (mouseY - repere.y) / echelle.y
      );

    /// Précision de la trajectoire, elle permet d'accélérer considérablement
    ///  l'execution du code, 1/echelle.y => 1 px
    float erreurMaximaleAutorisee = (10 / echelle.y);

    /// Prédire les prochaines positions si l'on fait rien
    float[][] predictions = prochainesPositions();

    ///  Finalement, au lieu de chercher une formule générique
    ///    et par manque de temps, j'ai décidé de modifier
    ///    l'accélération gravitationelle de manière lente,
    ///    et de trouver le point le plus proche de la solution
    ///    en faisant une moyenne de ce que j'ai trouvé, en effet
    ///    si le pas est assez grand et le nombre d'itérations l'est
    ///    aussi, de devrais avoir ~50% des prévisions en dessous de
    ///    la cible, ~50% au dessus, donc en faisant la moyenne de
    ///    tous, j'obtiendrai une valeur correcte (au moin
    ///    approximativement correcte)
    float accelerationSum = 0;

    ///  La moyenne sera toujours recalculée, pour pouvoir arrêter la boucle
    ///    dans le cas où l'erreur est trop faible
    float accelerationMean= 0;

    ///  Nous allons sauvegarder cette vatiable pour pouvoir
    ///    réajuster le pas, et ainsi demander moins d'itérations pour
    ///    le même résultat
    float diff = difference(predictions, target);


    ///  De plus, cette variable est utile pour savoir s'il faut monter ou
    ///    descendre, en effet s'il faut monter, je vais volontirement
    ///    restreindre l'accélération verticale pour qu'elle soit
    ///    positive, même si c'est pour aller trop haut (c'est le
    ///    but d'avoir un petit effet de vague dans le déplacement
    ///    vertical du dinosaure)
    boolean under = diff > 0;

    boolean dinoUnder = position.y < target.y;

    ///  Comme dit plus haut, le nombre d'itérations est important pour
    ///    compenser l'absence d'une formule exacte, et comme les tests
    ///    devrons se faire en fin de boucle, le do..while est privilégié
    int _l = 0;
    do {
      /// A chaque itération, on recalcule la trajectoire
      predictions = prochainesPositions();

      /// Les variables de bases
      diff = difference(predictions, target);
      under = diff > 0;      

      text((under ? "DOWN" : "UP") + (erreurMaximaleAutorisee > abs(diff) ? " " : " non ") + "Négligeable" + abs(diff), width / 2, height / 2);

      boolean depasse = trajectoireExageree(predictions, target);

      if (!depasse) {
        acceleration.y += (under ? -1 : 1) * log(abs(diff) + 1);
      } else {

        ///  Vu que nous ne modifions que l'accélération, il se peut qu'il soit
        ///    imporrible de viser le curseur sans dépasser de l'écran
        ///    dans ce cas, on s'assure au moins d'avoir essayé 
        for (int k = 0; k < 50 && depasse; ++k) {
          acceleration.y += 1;
          predictions = prochainesPositions();
          depasse = trajectoireExageree(predictions, target);
        }
      }

      accelerationSum += acceleration.y;
      /// acceleration.y *= vitesse.y - vPredict > 0 ? -1 : 1;
      /// acceleration.y -= -(y - target.y) * 2 / target.x * target.x;
      /// V(t+1) = V(t) + v - g
      ///-V(t+1) + V(t) + v = g
      /// a = V0 + dT - Vn+1
    } while (_l++ < 50 && (erreurMaximaleAutorisee > abs(diff)));
    acceleration.y = (accelerationSum / 500);
    fill(#ff0000);
    afficherHitBoxes(prochainesPositions());
    fill(64);
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//
//  Fonction "interne", elle permet de savoir si notre trajectoire est exagerée.
//    Précision:  les "final" dans la déclarations sont juste des garde-fous pour
//                m'assurer que les valeurs ne seront pas mosifiées
//
////////////////////////////////////////////////////////////////////////////////////////
boolean trajectoireExageree(final float[][]trajectoire, final PVector target) {
  ///  Petit bout de rustine démonstrant par sa seul présence la
  ///    fragilité de la solution, en effet, nous ne faisons que
  ///    modifier g (acceleration.y), et par conséquent nous ne
  ///    pouvons donc pas executer cette fonction si la souris
  ///    est trop proche du dinosaure, ce qui aurait pour effet
  ///    de chander la gravité pour des valeurs démesurées, voire
  ///    INF.
  ///  Ce booléen servira à savoir si nous dépassons de l'écran, pour
  ///    savoir cela, nous allons calculer la différence entre le
  ///    point maximal autorisé et le plus haut point de la trajectoire,
  ///    en effet nous fairons un sorte de triangle ayant pour hypoténuse
  ///    le segment PdinoPcurseur, et nous utiliserons le théorème de
  ///    thalès pour s'assurer que tout les points de la trajectoire seront
  ///    sous la droite correspondant à l'hypoténuse précedemment définie.
  ///    x/y = X/Y => x = X*y/Y => y = x*Y/X
  ///    Nous devons denc nous assurer que y soit plus petit que ça
  ///  De plus, on ne va pas chercher à savoir ce qui adviendra après avoir
  ///    dépassé le curseur
  ///  Pour finir, je me permet de préciser qu'une trajectoire ne pourra
  ///    d'après mois être que dans un sens, car dans l'autre, dans tout les
  ///    cas, le sol fera son travail
  boolean depasse = false;
  boolean under = difference(trajectoire, target) > 0;

  /// cela permet de voir les bonnes/mavaises
  fill(color(random(255), random(255), random(255)));


  for (float[]i : trajectoire) {
    if (i[0] < target.x) {
      /// Différence des x pour la cible (Target) et pour la prediction (P)
      float dxP = i[0] - position.x;
      float dxT = target.x - position.x;

      float dyP = i[1] - position.y;
      float dyT = target.y - position.y;

      /// Nous allons dans un premier temps calculer cela
      boolean auDessusHyp = dyP > ((dxP * dyT) / dxT);

      /// Pour en déduire cela
      boolean dansTriangle = !under ? auDessusHyp : !auDessusHyp;

      if (!dansTriangle) {
        depasse = true;
      } else {
        /// Nous allons afficher beaucoups de hitBoxes
        ///  donc on les éspace de 19 (1 sur 20 vont être affichées)
        afficherHitBoxes(prochainesPositions(), 20);
      }
    }
  }

  fill(64);

  return depasse;
}
////////////////////////////////////////////////////////////////////////////////////////
//
//  Fonction de saut, elle permet de sauter.
//
////////////////////////////////////////////////////////////////////////////////////////
void jump() {
  ///  TODO: Faire une compsition de vecteurs du type
  ///    vitesse.add(saut);
  dJumping = true;
  vitesse.y = jumpSpeed;
}

////////////////////////////////////////////////////////////////////////////////////////
//
//  Fonction de saut, elle permet de sauter.
//
////////////////////////////////////////////////////////////////////////////////////////
void jump(boolean verification) {
  ///  TODO: Faire une compsition de vecteurs du type
  ///    vitesse.add(saut);
  ///  Fais une vérification simple, en effet si nous ne voulons pas vérifier,
  ///    sauter, sinon s'assurer que noue pouvons
  if (!verification || !dJumping) {
    jump();
  }
}