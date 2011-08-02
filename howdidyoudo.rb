require 'Qt4'

class HowDidYouDoWidget < Qt::Widget
#called by trainer.suggest_routine
#TODO close demo window with widget exit
    attr_accessor :performance_rating
                                                     #is quit actually returned?
  def self.quit
    @@quit
  end

  def performance_rating
    @@performance_rating
  end

  def routine
    @@routine
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

  def self.pass
    @@pass
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
    @@pass = false

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
    @launch_file_button = Qt::PushButton.new "SHOW ME"
    @launch_file_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    @pass_button = Qt::PushButton.new "PASS"
    @pass_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    @quit_button = Qt::PushButton.new "EXIT PROGRAM"
    @quit_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))

    connect(@quit_button, SIGNAL('clicked()')) {@@quit = true
      $qApp.quit}
    connect(@launch_file_button, SIGNAL('clicked()')) {launch_routine_file}
    connect(@pass_button, SIGNAL('clicked()')) {@@pass = true #pass is not used, nor does it have an accessor
      $qApp.quit}
    connect(@next_button, SIGNAL('clicked()')) {@@next = true #next is not used, nor does it have an accessor
      $qApp.quit}
    connect(@slider, SIGNAL('valueChanged(int)'), @lcd, SLOT('display(int)'))
    connect(@slider, SIGNAL('valueChanged(int)')) {@@performance_rating = @slider.value}

    grid.addWidget(@lcd, 0, 0, 1, 2)
    grid.addWidget(@slider, 1, 0, 1, 2)
    grid.addWidget(@next_button, 2, 0)
    grid.addWidget(@quit_button, 3, 1)
    grid.addWidget(@launch_file_button, 2, 1)
    grid.addWidget(@pass_button, 3, 0)
    setLayout(grid)

  end

  def launch_routine_file #called by init_ui
    if /text/ =~ routine.link
     #show message
    else
      fork do       #maybe this wants to be spawn?
      exec "open #{routine.link}"
      end
    end
  end


  def self.run_qt(routine)
    app = Qt::Application.new ARGV
    @@routine = routine
    performance_rating = HowDidYouDoWidget.new #need a better name
    app.exec
    return performance_rating.performance_rating, quit, pass
  end
end
