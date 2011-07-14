require 'Qt4'

class PracticeSetButton < Qt::Widget   #Not quit; PracticeSetButton

    attr_accessor :row #:name?

  def initialize(row, parent = nil)#(name, link?) (need parent?)
    super()

    @quit = Qt::PushButton.new("#{row}") #do I need @?
    @quit.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))

    connect(quit, SIGNAL('clicked()')) { puts "#{row}"
      $qApp.quit} #{run link, or set value to run link, and quit widget app}
    layout = Qt::VBoxLayout.new()
    layout.addWidget(quit)
    setLayout(layout)
  end

  def quit   #this was needed to move connect to MyWidget class
    @quit
  end
end

class MyWidget < Qt::Widget # PracticeSetButtonLayout

    attr_accessor :button_set #?

  def initialize(button_set, parent = nil) #(practice_sets_ list|hash) (need Parent?)
    super()

    @button_set = button_set #?
    grid = Qt::GridLayout.new()  #I think this is unnecessary, but more robust as the basis for similar widgets
    i = 0
    for row in button_set                #0...practice_sets_hash.length   #for row in button_set
        quit = PracticeSetButton.new(row)     #:practice_sets_hash.key =Quit.new(row)
        grid.addWidget(quit, i, 0)
        i += 1
    end

    layout = Qt::VBoxLayout.new()
# http://doc.qt.nokia.com/latest/qvboxlayout.html
    layout.addLayout(grid)
    setLayout(layout)
  end
  def run_qt

  end
end

app = Qt::Application.new(ARGV)
button_set = ["Kevin's", "Ellen's", "Other"]
widget = MyWidget.new(button_set)#(set, rows, cols)
widget.show()

app.exec()


