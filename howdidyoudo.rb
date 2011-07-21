require 'Qt4'

class HowDidYouDoWidget < Qt::Widget
#called by trainer.suggest_routine
#TODO close demo window with widget focus
    attr_accessor :performance_rating

  def self.quit
    @@quit
  end

  def performance_rating
    @@performance_rating
  end

  def value()
    @slider.value
  end

  def slider
    @slider
  end

  def lcd
    @lcd
  end

  def initialize()
    super()
    setWindowTitle "HOW DID YOU DO?"
    resize 200, 300
    move 100, 300
    init_ui()
    show
  end

  def init_ui()

    @@performance_rating = nil   #if I initialize this to nil, I can use that value as not practiced.
    @@quit = false

    grid = Qt::GridLayout.new()

    @lcd = Qt::LCDNumber.new(2)
    @lcd.setSegmentStyle(Qt::LCDNumber::Filled)
    @lcd.setPalette(Qt::Palette.new(Qt::Color.new(250, 250, 200)))
    @lcd.setAutoFillBackground(true)
    @slider = Qt::Slider.new(Qt::Horizontal, self)
    @slider.setRange(0, 10)
    @slider.setValue(0)
    @next_button = Qt::PushButton.new "NEXT"
    @next_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    @quit_button = Qt::PushButton.new "EXIT PROGRAM"
    @quit_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))

    connect(@quit_button, SIGNAL('clicked()')) {@@quit = true
      $qApp.quit}
    connect(@next_button, SIGNAL('clicked()')) {@@next = true #next is not used, nor does it have an accessor
      $qApp.quit}
    connect(@slider, SIGNAL('valueChanged(int)'), @lcd, SLOT('display(int)'))
    connect(@slider, SIGNAL('valueChanged(int)')) {@@performance_rating = @slider.value}

    grid.addWidget(@lcd, 0, 0, 1, 2)
    grid.addWidget(@slider, 1, 0, 1, 2)
    grid.addWidget(@next_button, 2, 0)
    grid.addWidget(@quit_button, 2, 1)
    setLayout(grid)

  end

  def self.run_qt
    app = Qt::Application.new ARGV
    performance_rating = HowDidYouDoWidget.new #need a better name
    app.exec
    return performance_rating.performance_rating, quit
  end
end
