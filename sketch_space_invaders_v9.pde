// Bibliotecas de som
import processing.sound.*;
int lastPlayTime = 0;
int playInterval = 800; // 0.8 segundo em milissegundos

// Variáveis para imagens
PImage playerImg;
PImage enemyImg;
PImage bossImg;
PImage backgroundImg;
PImage introBackgroundImg;
PImage companyLogoImg;

// Variáveis para efeitos sonoros
SoundFile musicSound;
SoundFile shootSound;
SoundFile explosionSound;
SoundFile hitSound;
SoundFile gameOverSound;

// Variáveis do jogador
float playerX;
float playerY;
float playerSpeed = 5;
int playerSize = 30;

// Variáveis dos tiros
ArrayList<PVector> shots;
float shotSpeed = 7;
int shotSize = 5;  

// Variáveis dos inimigos
ArrayList<PVector> enemies;
ArrayList<Boolean> enemyDirections;
int enemyRows = 4;
int enemyCols = 8;
int enemySize = 30;
float enemySpeed = 1;
float enemyDrop = 20;
int enemySpacing = 40;
boolean moveDown = false;
int enemyShotRate = 60;
ArrayList<PVector> enemyShots;
float enemyShotSpeed = 4;

// Variáveis das barreiras
ArrayList<PVector> barriers;
ArrayList<Integer> barrierHealth;
int barrierWidth = 60;
int barrierHeight = 30;
int barrierHealthMax = 10;

// Variáveis do chefão
PVector boss;
float bossWidth = 80;
float bossHeight = 40;
int bossHealth = 0;
int bossHealthMax = 100;
float bossSpeed = 2;
int bossShotRate = 30;
boolean bossActive = false;
ArrayList<BossShot> bossShots;
float bossShotSpeed = 5;
int bossShotCount = 3; // Número de tiros simultâneos

// Variáveis do jogo
boolean gameOver = false;
boolean gameStarted = false;
int score = 0;

// score list
ArrayList<Integer> scoreHistory = new ArrayList<Integer>();
int lives = 3;
int wave = 1;

// Variáveis para a tela de intro
int blinkInterval = 500; // Intervalo de piscar em ms
int lastBlinkTime = 0;
boolean showStartText = true;

boolean showLogo = true;
int logoDisplayTime = 3000; // 3 segundos
int logoStartTime;

boolean showCredits = false;

// Variáveis para tela de história
boolean showStory = false;
String storyText = "ANO 2142 - A TERRA ESTÁ SOB ATAQUE!\n\n" +
                   "Uma frota alienígena implacável chegou ao nosso sistema solar.\n" +
                   "Como último piloto da resistência humana, sua missão é\n" +
                   "destruir todas as naves inimigas antes que elas exterminem\n" +
                   "a vida em nosso planeta.\n\n" +
                   "Use as setas para mover e ESPAÇO para atirar.\n" +
                   "Sobreviva o máximo que puder e proteja a Terra!";

// Variáveis para tela de highscores
boolean showHighScores = false;
ArrayList<String> playerInitials = new ArrayList<String>();
ArrayList<Integer> highScores = new ArrayList<Integer>();
boolean enteringInitials = false;
String currentInitials = "";
int charIndex = 0;


class BossShot {
  PVector position;
  PVector velocity;
  
  BossShot(float x, float y, float vx, float vy) {
    position = new PVector(x, y);
    velocity = new PVector(vx, vy);
  }
  
  void update() {
    position.add(velocity);
  }
}

void setup() {
  size(600, 800);
  
  // Carrega as imagens
  playerImg = loadImage("player.png");
  enemyImg = loadImage("enemy.png");
  bossImg = loadImage("boss.png");
  backgroundImg = loadImage("background.jpg");
  introBackgroundImg = loadImage("intro_bg.png");
  introBackgroundImg.resize(width, height);
  companyLogoImg = loadImage("logo.png");
  companyLogoImg.resize(300, 300);
  
  // Carrega os efeitos sonoros
  musicSound = new SoundFile(this, "fastinvader1.wav");
  shootSound = new SoundFile(this, "shoot.wav");
  explosionSound = new SoundFile(this, "explosion.wav");
  hitSound = new SoundFile(this, "explosion.wav");
  gameOverSound = new SoundFile(this, "gameover.wav");
  
  musicSound.amp(0.3);
  shootSound.amp(0.5); // 50% do volume
  explosionSound.amp(0.7);
  hitSound.amp(0.6);
  gameOverSound.amp(0.8);
  
  // Define o tempo inicial da logo
  logoStartTime = millis();
  
  // Redimensiona as imagens se necessário
  playerImg.resize(playerSize, playerSize/2);
  enemyImg.resize(enemySize, enemySize);
  bossImg.resize((int)bossWidth, (int)bossHeight);
  backgroundImg.resize(width, height);
  
  // Inicializa jogador
  playerX = width/2;
  playerY = height - 50;
  
  // Inicializa listas de tiros
  shots = new ArrayList<PVector>();
  enemyShots = new ArrayList<PVector>();
  bossShots = new ArrayList<BossShot>();
  
  // Inicializa inimigos
  resetEnemies();
  
  // Inicializa barreiras
  resetBarriers();
  
  // Inicializa chefão
  boss = new PVector(width/2, 100);
}

void resetBarriers() {
  barriers = new ArrayList<PVector>();
  barrierHealth = new ArrayList<Integer>();
  
  // Cria 4 barreiras igualmente espaçadas
  for (int i = 0; i < 4; i++) {
    float x = width/5 * (i+1);
    float y = height - 150;
    barriers.add(new PVector(x, y));
    barrierHealth.add(barrierHealthMax);
  }
}

void resetEnemies() {
  enemies = new ArrayList<PVector>();
  enemyDirections = new ArrayList<Boolean>();
  
  for (int i = 0; i < enemyRows; i++) {
    for (int j = 0; j < enemyCols; j++) {
      float x = 100 + j * enemySpacing;
      float y = 50 + i * enemySpacing;
      enemies.add(new PVector(x, y));
      enemyDirections.add(true);
    }
  }
}

void spawnBoss() {
  bossActive = true;
  bossHealth = bossHealthMax;
  boss.x = width/2;
  boss.y = 100;
}

void drawIntroScreen() {
  // Desenha o background da intro
  imageMode(CORNER);
  image(introBackgroundImg, 0, 0, width, height);
  
  // Atualiza o piscar do texto
  int currentTime = millis();
  if (currentTime - lastBlinkTime > blinkInterval) {
    showStartText = !showStartText;
    lastBlinkTime = currentTime;
  }
  
  // Desenha o texto piscando
  if (showStartText) {
    fill(255);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("START GAME", width/2, height/2 - 30);
    textSize(24);
    text("Press SPACE", width/2, height/2 + 20);
    text("Press C for Credits", width/2, height/2 + 60);
    text("Press H for High Scores", width/2, height/2 + 100);
  }
}

void draw() {
  if (showLogo) {
    drawLogoScreen();
    
    // Verifica se já passou o tempo de exibição da logo
    if (millis() - logoStartTime > logoDisplayTime) {
      showLogo = false;
    }
    return;
  }
  
  // Tela de créditos
  if (showCredits) {
    drawCreditsScreen();
    return;
  }
  
   if (showHighScores) {
    drawHighScoresScreen();
    return;
  }
  
  if (showStory) {
    drawStoryScreen();
    return;
  }
  
  if (enteringInitials) {
    drawInitialsEntry();
    return;
  }
  
  // Tela de introdução do jogo
  if (!gameStarted) {
    drawIntroScreen();
    return;
  }
  
  background(0);
  // Limpa a tela completamente desenhando o fundo primeiro
  image(backgroundImg, 300, 400, width, height);
  
  int currentTime = millis();
  if (currentTime - lastPlayTime > playInterval) {
    musicSound.play();
    lastPlayTime = currentTime;
  }
  
  // Desenha todos os elementos do jogo
  if (!gameOver) {
    drawPlayer();
    movePlayer();
    
    drawShots();
    moveShots();
    
    if (!bossActive) {
      drawEnemies();
      moveEnemies();
    }
    
    drawBarriers();
    
    if (bossActive) {
      drawBoss();
      moveBoss();
      bossShoot();
    }
    
    checkCollisions();
    checkBarrierCollisions();
    checkBossCollisions();
    
    if (!bossActive) {
      enemyShoot();
    }
    
    drawEnemyShots();
    moveEnemyShots();
    
    drawBossShots();
    moveBossShots();
    
    checkPlayerHit();
    checkGameOver();
    
    if (bossActive) {
      drawBossHealth();
    }
  } else {
    // Desenha elementos da tela de game over
    fill(255);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("GAME OVER", width/2, height/4);
    textSize(24);
    text("Score: " + score, width/2, height/4 + 40);
    text("Wave: " + wave, width/2, height/4 + 70);
    text("Press R to restart", width/2, height/4 + 110);
    text("Press ESC for intro", width/2, height/4 + 140);
  }
  
  // Mostra informações do jogo (sobrepostas)
  fill(255);
  textSize(16);
  textAlign(LEFT);
  text("Score: " + score, 20, 20);
  text("Lives: " + lives, 20, 40);
  text("Wave: " + wave, 20, 60);
}

void drawLogoScreen() {
  background(0);

  image(companyLogoImg, 150 , 200);
  
  fill(255);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("Loading...", width/2, height - 50);
}

void drawBoss() {
  imageMode(CENTER);
  image(bossImg, boss.x, boss.y);
}

void drawBossHealth() {
  // Barra de vida do chefão
  float healthBarWidth = 200;
  float healthPercentage = (float)bossHealth / bossHealthMax;
  
  fill(255, 0, 0);
  rectMode(CORNER);
  rect(width/2 - healthBarWidth/2, 30, healthBarWidth, 10);
  
  fill(0, 255, 0);
  rect(width/2 - healthBarWidth/2, 30, healthBarWidth * healthPercentage, 10);
  
  // Texto da vida
  fill(255);
  textSize(14);
  textAlign(CENTER, CENTER);
  text("BOSS: " + bossHealth + "/" + bossHealthMax, width/2, 35);
}

void moveBoss() {
  // Movimentação lateral do chefão
  boss.x += bossSpeed;
  
  // Inverte direção quando chega nas bordas
  if (boss.x > width - bossWidth/2 || boss.x < bossWidth/2) {
    bossSpeed *= -1;
    boss.y += 20; // Desce um pouco quando muda de direção
    
    // Limita a descida do chefão
    if (boss.y > height/3) {
      boss.y = height/3;
    }
  }
}

void bossShoot() {
  if (frameCount % bossShotRate == 0) {
    // Dispara múltiplos tiros em leque
    for (int i = 0; i < bossShotCount; i++) {
      float angle = map(i, 0, bossShotCount-1, -PI/4, PI/4);
      float vx = sin(angle) * bossShotSpeed;
      float vy = cos(angle) * bossShotSpeed;
      bossShots.add(new BossShot(boss.x, boss.y + bossHeight/2, vx, vy));
    }
  }
}

void drawBossShots() {
  fill(255, 50, 50);
  for (BossShot shot : bossShots) {
    ellipse(shot.position.x, shot.position.y, shotSize * 1.5, shotSize * 1.5);
  }
}  

void moveBossShots() {
  for (int i = bossShots.size() - 1; i >= 0; i--) {
    BossShot shot = bossShots.get(i);
    shot.update();
    
    if (shot.position.y > height || shot.position.x < 0 || shot.position.x > width) {
      bossShots.remove(i);
    }
  }
}

void checkBossCollisions() {
  // Verifica colisão entre tiros do jogador e chefão
  for (int i = shots.size() - 1; i >= 0; i--) {
    PVector shot = shots.get(i);
    
    if (bossActive && 
        abs(shot.x - boss.x) < (bossWidth/2 + shotSize/2) && 
        abs(shot.y - boss.y) < (bossHeight/2 + shotSize/2)) {
      shots.remove(i);
      bossHealth--;
      explosionSound.play();
      
      if (bossHealth <= 0) {
        bossActive = false;
        score += 200; // Pontuação maior por derrotar o chefão
        wave++;
        resetEnemies();
        resetBarriers();
      }
    }
  }
}

void drawBarriers() {
  for (int i = 0; i < barriers.size(); i++) {
    PVector barrier = barriers.get(i);
    int health = barrierHealth.get(i);
    
    if (health > 0) {
      int green = (int)map(health, 0, barrierHealthMax, 0, 255);
      int red = 255 - green;
      fill(red, green, 0);
      
      rectMode(CENTER);
      rect(barrier.x, barrier.y, barrierWidth, barrierHeight);
      
      fill(255);
      textSize(12);
      textAlign(CENTER, CENTER);
      text(health, barrier.x, barrier.y);
    }
  }
}

void checkBarrierCollisions() {
  // Verifica colisão entre tiros do jogador e barreiras
  for (int i = shots.size() - 1; i >= 0; i--) {
    PVector shot = shots.get(i);
    
    for (int j = 0; j < barriers.size(); j++) {
      PVector barrier = barriers.get(j);
      int health = barrierHealth.get(j);
      
      if (health > 0 && 
          abs(shot.x - barrier.x) < (barrierWidth/2 + shotSize/2) && 
          abs(shot.y - barrier.y) < (barrierHeight/2 + shotSize/2)) {
        shots.remove(i);
        barrierHealth.set(j, health - 1);
        break;
      }
    }
  }
  
  // Verifica colisão entre tiros inimigos e barreiras
  for (int i = enemyShots.size() - 1; i >= 0; i--) {
    PVector shot = enemyShots.get(i);
    
    for (int j = 0; j < barriers.size(); j++) {
      PVector barrier = barriers.get(j);
      int health = barrierHealth.get(j);
      
      if (health > 0 && 
          abs(shot.x - barrier.x) < (barrierWidth/2 + shotSize/2) && 
          abs(shot.y - barrier.y) < (barrierHeight/2 + shotSize/2)) {
        enemyShots.remove(i);
        barrierHealth.set(j, health - 1);
        break;
      }
    }
  }
  
  // Verifica colisão entre tiros do chefão e barreiras
  for (int i = bossShots.size() - 1; i >= 0; i--) {
    BossShot shot = bossShots.get(i);
    
    for (int j = 0; j < barriers.size(); j++) {
      PVector barrier = barriers.get(j);
      int health = barrierHealth.get(j);
      
      if (health > 0 && 
          abs(shot.position.x - barrier.x) < (barrierWidth/2 + shotSize * 1.5/2) && 
          abs(shot.position.y - barrier.y) < (barrierHeight/2 + shotSize * 1.5/2)) {
        bossShots.remove(i);
        barrierHealth.set(j, health - 2); // Tiros do chefão causam mais dano
        break;
      }
    }
  }
}

void drawPlayer() {
  imageMode(CENTER);
  image(playerImg, playerX, playerY);
}

void movePlayer() {
  if (keyPressed) {
    if (keyCode == LEFT && playerX > playerSize/2) {
      playerX -= playerSpeed;
    }
    if (keyCode == RIGHT && playerX < width - playerSize/2) {
      playerX += playerSpeed;
    }
  }
}

void keyPressed() {
  if (enteringInitials) {
    if (keyCode == UP) {
      // Incrementa a letra atual
      if (currentInitials.length() > charIndex) {
        char c = currentInitials.charAt(charIndex);
        if (c < 'Z') c++;
        else c = 'A';
        currentInitials = currentInitials.substring(0, charIndex) + c + currentInitials.substring(charIndex+1);
      }
    } else if (keyCode == DOWN) {
      // Decrementa a letra atual
      if (currentInitials.length() > charIndex) {
        char c = currentInitials.charAt(charIndex);
        if (c > 'A') c--;
        else c = 'Z';
        currentInitials = currentInitials.substring(0, charIndex) + c + currentInitials.substring(charIndex+1);
      }
    } else if (keyCode == RIGHT) {
      // Move para a próxima letra
      charIndex = min(charIndex + 1, 2);
    } else if (keyCode == LEFT) {
      // Move para a letra anterior
      charIndex = max(charIndex - 1, 0);
    } else if (keyCode == ENTER) {
      // Confirma as iniciais
      playerInitials.add(currentInitials);
      highScores.add(score);
      
      // Ordena as listas em ordem decrescente de score
      sortHighScores();
      
      enteringInitials = false;
      gameOver = true;
    }
    return;
  }
  
   if (showCredits || showHighScores) {
    if (key == ESC) {
      showCredits = false;
      showHighScores = false;
      key = 0; // Previne comportamento padrão do ESC
    }
    return;
  }
  
  if (showStory) {
    if (key == ' ') {
      showStory = false;
      gameStarted = true;
    }
    return;
  }
  
  if (!gameStarted) {
    if (key == ' ') {
      showStory = true;
    } else if (key == 'c' || key == 'C') {
      showCredits = true;
    } else if (key == 'h' || key == 'H') {
      showHighScores = true;
    }
    return;
  }
  
  if (key == ' ' && !gameOver) {
    shots.add(new PVector(playerX, playerY - playerSize/2));
    shootSound.play();
  }
  
  if (gameOver) {
    if (key == 'r' || key == 'R') {
      restartGame();
    } else if (key == ESC) {
      // Volta para a tela de introdução
      gameOver = false;
      gameStarted = false;
      showStory = false;
      key = 0; // Previne comportamento padrão do ESC
      gameOver = false;
      lives = 3;
      score = 0;
      wave = 1;
      shots.clear();
      enemyShots.clear();
      bossShots.clear();
      resetEnemies();
      resetBarriers();
      bossActive = false;
      playerX = width/2;
      playerY = height - 50;
    }
  }
}

void drawShots() {
  fill(255, 255, 0);
  for (PVector shot : shots) {
    ellipse(shot.x, shot.y, shotSize, shotSize);
  }
}

void moveShots() {
  for (int i = shots.size() - 1; i >= 0; i--) {
    PVector shot = shots.get(i);
    shot.y -= shotSpeed;
    
    if (shot.y < 0) {
      shots.remove(i);
    }
  }
}

void drawEnemies() {
  imageMode(CENTER);
  for (PVector enemy : enemies) {
    image(enemyImg, enemy.x, enemy.y);
  }
}

void moveEnemies() {
  boolean changeDirection = false;
  
  for (int i = 0; i < enemies.size(); i++) {
    PVector enemy = enemies.get(i);
    
    if (moveDown) {
      enemy.y += enemyDrop;
      enemyDirections.set(i, !enemyDirections.get(i));
    } else {
      if (enemyDirections.get(i)) {
        enemy.x += enemySpeed;
        if (enemy.x > width - enemySize/2) {
          changeDirection = true;
        }
      } else {
        enemy.x -= enemySpeed;
        if (enemy.x < enemySize/2) {
          changeDirection = true;
        }
      }
    }
  }
  
  if (changeDirection && !moveDown) {
    moveDown = true;
  } else {
    moveDown = false;
  }
}

void enemyShoot() {
  if (frameCount % enemyShotRate == 0 && enemies.size() > 0) {
    int randomIndex = (int)random(enemies.size());
    PVector shooter = enemies.get(randomIndex);
    enemyShots.add(new PVector(shooter.x, shooter.y + enemySize/2));
  }
}

void drawEnemyShots() {
  fill(255, 0, 255);
  for (PVector shot : enemyShots) {
    rect(shot.x, shot.y, shotSize, shotSize);
  }
}

void moveEnemyShots() {
  for (int i = enemyShots.size() - 1; i >= 0; i--) {
    PVector shot = enemyShots.get(i);
    shot.y += enemyShotSpeed;
    
    if (shot.y > height) {
      enemyShots.remove(i);
    }
  }
}

void checkCollisions() {
  for (int i = shots.size() - 1; i >= 0; i--) {
    PVector shot = shots.get(i);
    
    for (int j = enemies.size() - 1; j >= 0; j--) {
      PVector enemy = enemies.get(j);
      
      if (dist(shot.x, shot.y, enemy.x, enemy.y) < (enemySize + shotSize)/2) {
        shots.remove(i);
        enemies.remove(j);
        score += 10;
        explosionSound.play();
        break;
      }
    }
  }
  
  // Verifica se todos os inimigos foram destruídos para spawnar o chefão
  if (enemies.size() == 0 && !bossActive) {
    spawnBoss();
  }
}

void checkPlayerHit() {
  // Verifica colisão com tiros inimigos
  for (int i = enemyShots.size() - 1; i >= 0; i--) {
    PVector shot = enemyShots.get(i);
    
    if (dist(shot.x, shot.y, playerX, playerY) < (playerSize + shotSize)/2) {
      enemyShots.remove(i);
      lives--;
      hitSound.play();
      
      if (lives <= 0) {
        gameOverSound.play();
        enteringInitials = true;
        currentInitials = "AAA"; // Iniciais padrão
        charIndex = 0;
      }
    }
  }
  
  // Verifica colisão com tiros do chefão
  for (int i = bossShots.size() - 1; i >= 0; i--) {
    BossShot shot = bossShots.get(i);
    
    if (dist(shot.position.x, shot.position.y, playerX, playerY) < (playerSize + shotSize)/2) {
      bossShots.remove(i);
      lives--;
      
      if (lives <= 0) {
        enteringInitials = true;
        currentInitials = "AAA";
        charIndex = 0;
      }
    }
  }
  
  // Verifica colisão com inimigos
  for (PVector enemy : enemies) {
    if (dist(enemy.x, enemy.y, playerX, playerY) < (enemySize + playerSize)/2) {
      enteringInitials = true;
      currentInitials = "AAA";
      charIndex = 0;
    }
  }
  
  // Verifica colisão com chefão
  if (bossActive && 
      abs(playerX - boss.x) < (bossWidth/2 + playerSize/2) && 
      abs(playerY - boss.y) < (bossHeight/2 + playerSize/2)) {
    enteringInitials = true;
    currentInitials = "AAA";
    charIndex = 0;
  }
}

void checkGameOver() {
  for (PVector enemy : enemies) {
    if (enemy.y > height - 100) {
      gameOver = true;
    }
  }
}

void drawCreditsScreen() {
  background(0);
  
  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("CREDITS", width/2, 100);
  
  textSize(24);
  text("Developers:", width/2, 160);
  
  // Lista de desenvolvedores - substitua pelos nomes reais
  text("Elizeu Leoncio Ferreira Junior", width/2, 200);
  text("Laryssa Rayanne Souza Martins", width/2, 230);
  text("Rafael Ferreira dos Anjos", width/2, 260);
  text("Matheus de Oliveira Lins Mendes Simes", width/2, 290);
  
  textSize(20);
  text("Press ESC to return", width/2, height - 50);
}

void restartGame() {
  gameOver = false;
  lives = 3;
  score = 0;
  wave = 1;
  shots.clear();
  enemyShots.clear();
  bossShots.clear();
  resetEnemies();
  resetBarriers();
  bossActive = false;
  playerX = width/2;
  playerY = height - 50;
  gameStarted = true; // Começa o jogo diretamente
}

void drawStoryScreen() {
  // Fundo (pode ser preto ou usar a imagem de intro)
  background(0);
  
  // Configurações do texto
  textSize(20);
  textAlign(CENTER, CENTER);
  fill(255, 255, 0); // Texto amarelo
  
  // Divide o texto em linhas e desenha centralizado
  String[] lines = storyText.split("\n");
  float startY = height/4;
  
  for (int i = 0; i < lines.length; i++) {
    text(lines[i], width/2, startY + i * 30);
  }
  
  // Instrução para continuar
  fill(255);
  textSize(18);
  text("Pressione ESPAÇO para começar", width/2, height - 50);
}

void drawHighScoresScreen() {
  background(0);
  
  fill(255, 255, 0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("HIGH SCORES", width/2, 80);
  
  textSize(24);
  fill(255);
  
  // Desenha os 10 melhores scores
  for (int i = 0; i < min(highScores.size(), 10); i++) {
    String scoreText = nf(i+1, 2) + ". " + playerInitials.get(i) + " - " + highScores.get(i);
    text(scoreText, width/2, 150 + i * 30);
  }
  
  fill(200);
  textSize(18);
  text("Press ESC to return", width/2, height - 50);
}

void drawInitialsEntry() {
  background(0);
  
  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("GAME OVER", width/2, height/4);
  textSize(24);
  text("Score: " + score, width/2, height/4 + 40);
  text("Wave: " + wave, width/2, height/4 + 70);
  
  textSize(28);
  text("Enter your initials:", width/2, height/2);
  
  // Mostra as iniciais sendo digitadas
  textSize(36);
  fill(255, 255, 0);
  text(currentInitials, width/2, height/2 + 50);
  
  // Mostra instruções
  fill(200);
  textSize(16);
  text("Use UP/DOWN to change letter, ENTER to confirm", width/2, height - 100);
}

void sortHighScores() {
  // Cria uma lista de índices ordenados por score
  ArrayList<Integer> indices = new ArrayList<Integer>();
  for (int i = 0; i < highScores.size(); i++) {
    indices.add(i);
  }
  
  // Ordena os índices com base nos scores (ordem decrescente)
  for (int i = 0; i < indices.size() - 1; i++) {
    for (int j = i + 1; j < indices.size(); j++) {
      if (highScores.get(indices.get(i)) < highScores.get(indices.get(j))) {
        int temp = indices.get(i);
        indices.set(i, indices.get(j));
        indices.set(j, temp);
      }
    }
  }
  
  // Cria listas temporárias ordenadas
  ArrayList<String> sortedInitials = new ArrayList<String>();
  ArrayList<Integer> sortedScores = new ArrayList<Integer>();
  
  for (int i = 0; i < indices.size(); i++) {
    sortedInitials.add(playerInitials.get(indices.get(i)));
    sortedScores.add(highScores.get(indices.get(i)));
  }
  
  // Substitui as listas originais
  playerInitials = sortedInitials;
  highScores = sortedScores;
}
