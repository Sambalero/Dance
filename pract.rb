# This program will
#maybe we create the file if it doesn't already exist
# 0. load the practice_sets file into an array of arrays
# 1. display a list of practice sets to choose from
# 2. ask the user which practice set he wants to do
# 4. calculate a recommended practice sequence for this practice session
#    (i.e. prioritize the routines list)
# 5. display the recommended practice sequence to the user
# 5a. each item in the sequence should have a link to a file describing what it is (this could be a text file or a video, or a set of videos in a folde:c)
# 5b. each item in the sequence should have an opportunity for the user to input information (whether the user practiced it, whether the practice was successful, maybe a rating of how successful the practice was, maybe whether the practice was videorecorded)
# 5c. it might be nice to tell the user statistical stuff about the practice history of that routine
#6 enable the user to quit the program
#7 save the user input for the next session
#-----------------------------------------------------------------------------------------------
#File Format
#number of sets = sets.length => used by marshal
#practicesets = array of practice set objects
#  PracticeSet objects
#    set name = set.name
#    number of practice sessions = set.practice_count
#    number of routines = set.routines.length => used by marshal
#    [set of routines] = set.routines[0...routine_count]
#    #Routine objects
#	      name, = set.routines[i].name
#	      link, = set.routines[i].link
#	      priority  = set.routines[i].priority
#	      practice count = set.routines[i].practice_count
#	      success count = set.routines[i].success_count
#	      set practice count at last practice = set.routines[i].last_routines_practice_count
#	      last attempt successful? = set.routines[i].last_success_value
#       score = set.routines[i].score
#-------------------------------------------------------------------
####Todo how do I handle stuff in series?
####Todo track camera usage?
#TODO add priority, time since practiced to widget
#TODO define priorities and add descriptor to widget
#TODO confirm: does add routine update the set routine count?
#TODO define success ranking and add descriptor to widget
#TODO confirm: does add set update the number of sets count?
#
#Keith's suggestions
#	consider getting rapid gui development with qt ruby by pragmatic press
#	may be available fromdemonoid
#	test driven development
#
#check out	popen4 fork for windows?
#look on	stackoverflow
#	for 'spawn process windows ruby
#	get pract fully running on osx, then take commands and wrap in unix class
#	do same with windows
#	do sniff to know which and (string match) - use appropriate object
#

require_relative 'marshaller'
require_relative 'addset'
require_relative 'practiceset'
require_relative 'practiceroutine'
require_relative 'routinetoedit'
require_relative 'editroutine'
require_relative 'addroutine'
require_relative 'howdidyoudo'
require_relative 'deleteroutine'

def is_numeric?(string)
  true if Float(string) rescue false
end

class PracticeSet
  attr_accessor :name, :num_practices, :routines

  def initialize(name, num_practices, routines) #called by marshaller.marshal
    @name = name
    @num_practices = num_practices
    @routines = routines
  end

  def sort_routines_by_score #called by practice and by trainer.main
    @routines.map { |routine| routine.score = routine.calc_score(@num_practices) }
    @routines.sort! { |a, b| a.score <=> b.score }
  end

end

#--------------------------------------------------------------------

class Routine

  attr_accessor :name, :link, :priority, :practice_count, :success_count, :last_routines_practice_count, :last_success_value, :score

  def initialize (options) #called by marshaller.marshal_routine
    @name = options[:name]
    @link = options[:link]
    @priority = options[:priority]
    @practice_count = options[:practice_count]
    @success_count =  options[:success_count]
    @last_routines_practice_count = options[:last_routines_practice_count]
    @last_success_value = options[:last_success_value]
    @score = options[:score]
  end

  def calc_score(num_practices) #called by practiceSet.sort_routines_by_score
    times_since_practiced_factor(num_practices) * difficulty_factor * priority_factor * last_time_factor
  end

  def difficulty_factor #called by calc_score
    @practice_count != 0 ? 0.1+@success_count/@practice_count : 0.1
  end

  def times_since_practiced_factor(num_practices) #called by calc_score
    1/(num_practices - @last_routines_practice_count + 1)
  end

  def priority_factor #called by calc_score
    @priority == 0 ? 1.0 : 1/@priority
  end

  def last_time_factor #called by calc_score
    @last_success_value == 0 ? 0.1 : 1.0
  end

  def index_practice_counts(num_practices) #called by trainer.suggest_routine
    @practice_count += 1
    @last_routines_practice_count = num_practices
  end

  def index_success_counts #called by trainer.suggest_routine
	  @success_count +=1
	  @last_success_value = 1
  end
end

#-----------------------------------------------------------

class Trainer

  include Marshaller
####  include widgets

	def main #called from file
		practice_sets = []
		if File.exist? FILENAME
      practice_sets, practice_set_names = marshal
      choose_set_to_practice(practice_sets, practice_set_names)
  		puts "That's all for now. Goodbye"
  		write_practice_sets practice_sets
    else
      puts "I can't find your source file. Sorry."
		end
	end

  def at_exit(exit_code, practice_sets = [])  #### confirm exit code required
    puts "Goodbye."
    if exit_code == 1
      write_practice_sets practice_sets
    end
    exit
  end

  def choose_set_to_practice(practice_sets, practice_set_names) #called by main and recursed
    chosen_set_name, quit, add_set, delete_set = PracticeSetButtonWidget.run_qt(practice_set_names)
    if quit
      at_exit(0)
    end
#-------------------add set----------------
    if add_set
#      add_set(practice_sets)  #TODO add set, return or unmarshal confirm done
      new_set_name = AddSetWidget.run_qt
      new_routines = []
      new_set = PracticeSet.new(new_set_name, 0, new_routines)

      practice_sets.push(new_set)
      practice_set_names.push(new_set_name)

      choose_set_to_practice(practice_sets, practice_set_names)
    end
#------------------delete set-----------------------
    if delete_set
#      delete_set(practice_sets)   #TODO integrate set to delete into PracticeSetButtonWidget or create another widget
    end
#---------------------------------------------------
    chosen_set_index = practice_set_names.index(chosen_set_name)   #unless csn = nil, then qad instead
    chosen_set = practice_sets[chosen_set_index]  #TODO: added set shows up as nil here...
    chosen_set.sort_routines_by_score
    practice_routines(chosen_set, practice_sets, practice_set_names)  #TODO move recursion to here? (chg to chosen set =, if none recurse
    chosen_set.sort_routines_by_score
  end

  def add_routine(chosen_set, routines_in_process = nil, initial_set_size = nil) #called by practice_routines, choose_set_to_practice
        routine = Routine.new({
          :name => "",
          :link => "",
          :priority => 0,
          :practice_count => 0,
          :success_count => 0,
          :last_routines_practice_count => 0,
          :last_success_value => 0.1,
          :score => 0 })

        name, link, priority, practice_count, success_count, last_success_value = EditRoutineWidget.run_qt(routine)

        routine.name = name
        routine.link = link
        routine.priority = priority
        routine.practice_count = practice_count
        routine.success_count = success_count

        chosen_set.routines.push(routine)
        routines_in_process.push(routine) if routines_in_process != nil

        intitial_set_size += 1 if intitial_set_size != nil
  end

  def delete_routine(routines_in_process, chosen_set, routines_to_delete)
    routines_to_delete.each do |rtd|

      chosen_set.routines.each do |routine|
        chosen_set.routines.delete(routine) if rtd.name == routine.name
      end

      routines_in_process.each do |routine|
        routines_in_process.delete(routine) if rtd.name == routine.name
      end
    end
  end


  def practice_routines(chosen_set, practice_sets, practice_set_names)    #TODO add option to not practice/not view/ not rate a routine
    initial_set_size = chosen_set.routines.length
    routines_in_process = chosen_set.routines.clone
#    chosen_routine = 'something else' #is this line needed?
    quit = false
    #TODO if none, choose set again
    while routines_in_process != [] and !quit
      chosen_routine, add_routine, delete_routine, edit_stats, quit = PracticeRoutineWidget.run_qt(routines_in_process)
#-----------------------add routine----------------
      if add_routine
        add_routine(chosen_set, routines_in_process, initial_set_size)
#-----------------------delete routine----------------
      elsif delete_routine
        routines_to_delete, quit = DeleteRoutineWidget.run_qt(chosen_set.routines)
        if quit         #TODO sometimes quit doesn't...
          puts "quit"
        elsif routines_to_delete == nil
          puts "ERROR: routines_to_delete = nil"
        elsif routines_to_delete == []
          puts "none"
          practice_routines(chosen_set, practice_sets, practice_set_names)
        else
        puts "routines to delete"
          routines_to_delete.each do |routine|
            puts "#{routine.name}"
          end
        delete_routine(routines_in_process, chosen_set, routines_to_delete)
        end
#-------------------------edit routine---------------------
      elsif edit_stats
        routine = RoutineToEditWidget.run_qt(chosen_set.routines)
        routine_index = chosen_set.routines.index(routine)
        rip_routine_index = routines_in_process.index(routine)

        name, link, priority, practice_count, success_count, last_success_value = EditRoutineWidget.run_qt(routine)
  #TODO test that each new name is unique
        routine.name = name
        routine.link = link
        routine.priority = priority
        routine.practice_count = practice_count
        routine.success_count = success_count
        routine.last_success_value = last_success_value

        #put it back in the set...
        chosen_set.routines[routine_index] = routine
        routines_in_process[rip_routine_index] = routine
#--------------------------???-----------------
      elsif chosen_routine == 'none'
puts "chosen = none"
        choose_set_to_practice(practice_sets, practice_set_names)
      elsif quit  #if quit do nothing...
      else
#        practice_routine(chosen_routine)
        performance_rating, quit, launch_file =  HowDidYouDoWidget.run_qt(chosen_routine) #TODO quit
#    fork do
#      exec "exit #{chosen_routine.link}"
#    end
# exec "exit 0"
        if performance_rating != nil #nil = not practiced
          if practice_success?(chosen_routine, performance_rating/2)
            chosen_routine.index_success_counts
          else
            chosen_routine.last_success_value = 0.1
          end
          chosen_routine.index_practice_counts(chosen_set.num_practices)
          routines_in_process.delete(chosen_routine)
        end
      end #265
    end #218

    if routines_in_process.length < initial_set_size
      chosen_set.num_practices +=1
    end #281
    #session count is a better name for set practice count
    #TODO return chosen set, none?
  end

  def practice_success?(routine, response) #called by practice_routines
    response == 5 or (response == 4 and routine.priority < 4)
  end

#fork doesn't work in windows
#routine.link needs to be the file name for the above call
#for windows this might be "cmd /c start pathtofile\filename"
# I want to reset focus to terminal; maybe wait for linked file to close
# open terminal may work, but first the delay

  def practice_routine(routine) #called by practice_routines
    fork do       #maybe this wants to be spawn?
      exec "open #{routine.link}"
    end
  end
end


#-------------------------------------------------------------------

trainer = Trainer.new.main




