# On charge notre bibliothèque bien - aimée
require 'gosu'

# Définition du module ZOrder : celui à pour but de rassembler toutes les profondeurs des 
# différents objets de notre jeu. Ainsi le fond aura une profondeur de 0, les étoiles de 1, le 
# vaisseau du joueur de 2 et l'User Interface (le score) de 3. Plus la profondeur est grande, 
# plus le dessin sera dessiné sur les autres dessins de profondeur plus petite.
module ZOrder
  Background, Stars, Player, UI = *0..3
end

# Classe représentant une étoile pour notre jeu.
class Star
  attr_reader :x, :y
  
  # Initialisation d'une étoile
  # On remarquera que sa couleur est aléatoire. De plus l'étoile utilise plusieurs images pour 
  # faire son animation (comme pour les dessins animés). Elle démarre aléatoire sur une des 
  # positions de son animation à une position également aléatoire.
  def initialize(animation)
    @animation = animation
    @color = Gosu::Color.new(0xff000000)
    @color.red = rand(255 - 40) + 40
    @color.green = rand(255 - 40) + 40
    @color.blue = rand(255 - 40) + 40
    @x = rand * 640
    @y = rand * 480
  end
  
  # Fonction pour dessiner notre étoile en function de son étape d'animation.
  def draw
    img = @animation[Gosu::milliseconds / 100 % @animation.size];
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
        ZOrder::Stars, 1, 1, @color, :additive)
  end
end

# Classe pour les objets incarnant le joueur à l'écran. Pour ce jeu, il s'agit d'un vaisseau 
# spatial souffrant d'inertie.
class Player

  # Fonction d'initialisation :
  # 1 - chargement de l'image et du son propre aux instances de cette classe.
  # 2 - initialisation des variables
  def initialize(window)
     # @image = Gosu::Image.new(window, "media/Starfighter.bmp", false)
    @beep = Gosu::Sample.new(window, "musics/GetRuby2.wav")
    @x = @y = @vel_x = @vel_y = @angle = 0.0
  end
  
  # Fonction de télé - transportation du joueur : déplace le joueur aux coordonnées passées en
  # paramètres.
  def warp(x, y)
    @x, @y = x, y
  end
  
  # Fonction pour tourner à gauche en diminuant l'angle du vaisseau.
  # Le vaisseau peut donc tourner sur lui-même sans avoir besoin de vitesse pour le faire.
  def turn_left
    @angle -= 4.5
  end
  
  # Fonction pour tourner à droite en augmentant l'angle du vaisseau.
  # Le vaisseau peut donc tourner sur lui-même sans avoir besoin de vitesse pour le faire.
  def turn_right
    @angle += 4.5
  end
  
  # Fonction pour faire accélérer le vaisseau selon son angle.
  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end
  
  # Fonction faisant bouger le vaisseau. Chaque mouvement décélère le vaisseau.
  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 640
    @y %= 480
    
    @vel_x *= 0.95
    @vel_y *= 0.95
  end
  
  # Fonction pour ramasser les étoiles disséminées dans la fenêtre. Pour cela on parcourt toutes 
  # les étoiles et on détecte si une étoile entre en collision avec nous. La détection de collision 
  # se fait en regardant si la distance entre le centre de l'étoile et le centre du vaisseau est 
  #inférieur à 35 pixels. On joue un son si on est en contact avec une étoile et on augmente le 
  # score de 10.
  def collect_stars(stars)
    stars.reject! do |star|
      dist_x = @x - star.x
      dist_y = @y - star.y
      dist = Math.sqrt(dist_x * dist_x + dist_y * dist_y)
      if dist < 35 then
        yield 10
        @beep.play
        true
      else
        false
      end
    end
  end

  # Fonction pour dessiner notre vaisseau selon son angle.
 #  def draw
 #    @image.draw_rot(@x, @y, ZOrder::Player, @angle)
 #  end
end

# Classe pour la fenêtre du jeu. Elle va initialisé notre jeu en définissant un joueur et un 
# tableau pour les étoiles. Ensuite, elle affichera son score et réagir aux touches pressés sur le 
# clavier.
class GameWindow < Gosu::Window

  # Initialisation du jeu :
  # 1 - chargement des images et de la police de caractère
  # 2 - initialisation des variables globales (le score, le titre de la fenêtre, les paramètres 
  # d'affichages)
  # 3 - création des éléments de base du jeu (un joueur et les étoiles)
  # Note : le chargement des différentes animations de l'étoile se fait à l'aide d'un load_tiles.
  def initialize
    super(640, 480, false, 20)
    self.caption = "the game"
    
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
     @background_sprite = Gosu::Image.new(self, 'images/background.png', true)
    @star_anim = Gosu::Image::load_tiles(self, "images/ruby.png", 25, 25, false)
    
    @player = Player.new(self)
    @player.warp(320, 240)
    @stars = Array.new
    @score = 0
  end
  
  # Fonction principale du jeu : elle gère la " vie " du jeu :
  # 1 - Réaction aux touches pressées (envoie d'un message à l'objet player)
  # 2 - Génération d'étoiles
  def update
    if button_down? Gosu::Button::KbLeft or button_down? Gosu::Button::GpLeft then
      @player.turn_left
    end
    if button_down? Gosu::Button::KbRight or button_down? Gosu::Button::GpRight then
      @player.turn_right
    end
    if button_down? Gosu::Button::KbUp or button_down? Gosu::Button::GpButton0 then
      @player.accelerate
    end
    @player.move
    @player.collect_stars(@stars) { |gain| @score += gain }
    
    if rand(100) < 4 and @stars.size < 25 then
      @stars.push(Star.new(@star_anim))
    end
  end
  
  # Fonction pour réagir aux boutons presses puis relâchés. Typiquement, le bouton pour sortir 
  # du jeu.
  def button_down(id)
    if id == Gosu::Button::KbEscape
      close
    end
  end
  
  # Fonction de dessin. Elle est appelée après update et est chargée d'afficher le monde du jeu.
  # Son action consiste à dessiner le score, l'arrière-plan puis le joueur et enfin toutes les 
  # étoiles.
  def draw
    @font.draw("Score: #{@score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @background_image.draw(0, 0, ZOrder::Background)
    @player.draw
    @stars.each { |star| star.draw }
  end
end

GameWindow.new.show