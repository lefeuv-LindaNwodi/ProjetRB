class Ruby
  attr_reader :x, :y
WindowWidth = 1024
attr_reader :type
  def initialize(type)
    @type = type
    @image = if type == :ruby_up
#On a deux sortes de ruby : les noirs et les classics. 
               Gosu::Image.new('images/ruby2.png')
             elsif type == :ruby_down
               Gosu::Image.new('images/ruby.png')
             end
# La vitesse de deplacement des ruby est variable 
    @velocity = Gosu::random(0.8, 3.3)

    #On s'assure que les ruby restent bien dans la fenêtre
    @x = rand * (WindowWidth - @image.width)
    # Les ruby apparraissent aléatoirement dans la fenêtre
    @y = rand * (768 - @image.width)  
  end

  def update
    @y += @velocity
  end

  def draw
    @image.draw(@x, @y, 1)
  end

end