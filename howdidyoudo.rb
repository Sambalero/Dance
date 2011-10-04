require 'Qt4'

class HowDidYouDoWidget < Qt::Widget
#called by trainer.suggest_routine
#TODO close demo window with widget exit
    attr_accessor :performance_rating, :next_routine
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

    @@performance_rating = 0
    @@quit = false
    @@pass = false
    @@next_routine = false

    rankingsText =
"      5: Perfect, first time!
      4: Perfect, after several tries
      3: Good enough for now
      2: Need more practice
      1: Need lots more practice"
#text
    @message = Qt::Label.new(self)
    @message.setText rankingsText
    @message.adjustSize
#lcd
    @lcd = Qt::LCDNumber.new(2)
    @lcd.setSegmentStyle(Qt::LCDNumber::Filled)
    @lcd.setPalette(Qt::Palette.new(Qt::Color.new(250, 250, 200)))
    @lcd.setAutoFillBackground(true)
#slider
    @slider = Qt::Slider.new(Qt::Horizontal, self)
    @slider.setRange(0, 5)
    @slider.setValue(0)
#buttons
    @next_routine_button = Qt::PushButton.new "NEXT"
    @next_routine_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    @launch_file_button = Qt::PushButton.new "SHOW ME"
    @launch_file_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    @pass_button = Qt::PushButton.new "PASS"
    @pass_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    @quit_button = Qt::PushButton.new "EXIT PROGRAM"
    @quit_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
#connections
    connect(@quit_button, SIGNAL('clicked()')) {@@quit = true
      $qApp.quit}
    connect(@launch_file_button, SIGNAL('clicked()')) {launch_routine_file}
    connect(@pass_button, SIGNAL('clicked()')) {@@pass = true
      $qApp.quit}
    connect(@next_routine_button, SIGNAL('clicked()')) {
      $qApp.quit}
    connect(@slider, SIGNAL('valueChanged(int)'), @lcd, SLOT('display(int)'))
    connect(@slider, SIGNAL('valueChanged(int)')) {@@performance_rating = @slider.value}
#layout
    grid = Qt::GridLayout.new()
    grid.addWidget(@lcd, 0, 0, 2, 2)
    grid.addWidget(@slider, 2, 0, 1, 2)
    grid.addWidget(@message, 3, 0, 1, 2)
    grid.addWidget(@next_routine_button, 4, 0)
    grid.addWidget(@launch_file_button, 4, 1)
    grid.addWidget(@quit_button, 5, 1)
    grid.addWidget(@pass_button, 5, 0)
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
