class PracticeSet
  attr_accessor :name, :session_count, :routines

  def initialize(name, session_count, routines) #called by marshaller.marshal
    @name = name
    @session_count = session_count
    @routines = routines
  end

  def sort_routines_by_score #called by practice and by trainer.main
    @routines.map { |routine| routine.score = routine.calc_score(@session_count) }
    @routines.sort! { |a, b| a.score <=> b.score }
  end

end

#--------------------------------------------------------------------

class Routine

  attr_accessor :name, :link, :priority, :practice_count, :success_count, :last_routines_practice_count, :last_success_value, :last_date_practiced, :score

  def initialize (options) #called by marshaller.marshal_routine
    @name = options[:name]
    @link = options[:link]
    @priority = options[:priority]
    @practice_count = options[:practice_count]
    @success_count =  options[:success_count]
    @last_routines_practice_count = options[:last_routines_practice_count]
    @last_success_value = options[:last_success_value]
    @last_date_practiced = options[:last_date_practiced]
    @score = options[:score]
  end

  def calc_score(session_count) #called by practiceSet.sort_routines_by_score
    times_since_practiced_factor(session_count) * difficulty_factor * last_time_factor + @priority
  end

  def difficulty_factor #called by calc_score
    @practice_count != 0 ? 0.1+@success_count/@practice_count : 0.1
  end

  def times_since_practiced_factor(session_count) #called by calc_score
    1/(session_count - @last_routines_practice_count + 1)
  end

  def last_time_factor #called by calc_score
    @last_success_value == 0 ? 0.1 : 1.0
  end

  def index_practice_counts(session_count) #called by trainer.suggest_routine
    @practice_count += 1
    @last_routines_practice_count = session_count
  end

  def index_success_counts #called by trainer.suggest_routine
	  @success_count +=1
	  @last_success_value = 1
  end
end
