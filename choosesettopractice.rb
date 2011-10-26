require 'Qt4'

class ChooseSetToPracticeWidget < Qt::Widget
#called by trainer.practice_routines

    attr_accessor :chosen_set, :option, :practice_set_names # attr. acc req for this last. why?
  def self.option
    @@option
  end

  def chosen_set
  @@chosen_set
  end

  def self.practice_set_names
  @@practice_set_names
  end

  def practice_set_button
  @practice_set_button
  end

  def initialize()
    super()
    setWindowTitle "CHOOSE A SET"
    resize 200, 180
    move 100, 300
    show
  end


  def init_ui()

    @@option = :practice
    @@chosen_set = nil

    grid = Qt::GridLayout.new()

    i = 0
    for name in practice_set_names
      init_button(name)
      grid.addWidget(@practice_set_button, i, 0)
      i += 1
    end

    quit_button = Qt::PushButton.new 'Exit Program'
    add_set_button = Qt::PushButton.new 'Add New Set'
    delete_set_button = Qt::PushButton.new 'Delete Set'
    connect(quit_button, SIGNAL('clicked()')) {@@option = :quit
      $qApp.quit}
    connect(add_set_button, SIGNAL('clicked()')) {@@option = :add_set
      $qApp.quit}
    connect(delete_set_button, SIGNAL('clicked()')) {@@option = :delete_set
      $qApp.quit}
      grid.addWidget(quit_button, i, 0)
      grid.addWidget(add_set_button, i+1, 0)
      grid.addWidget(delete_set_button, i+2, 0)
    setLayout(grid)
  end

  def init_button(name)
    @practice_set_button = Qt::PushButton.new name, self
    @practice_set_button.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    connect(@practice_set_button, SIGNAL('clicked()')) {@@chosen_set = name
      $qApp.quit}
  end

  def self.run_qt(practice_set_names)  #called by ...
    app = Qt::Application.new ARGV
    choose_set = ChooseSetToPracticeWidget.new
    choose_set.practice_set_names = practice_set_names
    choose_set.init_ui
    app.exec
    return choose_set.chosen_set, option #chosen set is class variable. choose_set. required?
  end
end

