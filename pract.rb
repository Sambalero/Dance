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
#	      last time practiced  = set.routines[i].last_date_practiced
#       score = set.routines[i].score
#-------------------------------------------------------------------
####Todo how do I handle stuff in series?
####Todo track camera usage?

################TODO*****IN PROCESS*****TODO#################   test, addroutine
#TODO make sure exits save properly
#TODO develop text option in place of link for show routine
#TODO can widget buttons change color or something when clicked?   Also, activate input boxes when button clicked (add routine, add set)
#TODO confirm: does add routine update the set routine count?
#TODO clean up variable scope in widgets
#TODO reorder method definitions
#TODO set up for second column in chooseroutine, better window positioning
#Keith's suggestions
# split trainer between object management and training
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

#add note: git test
#Use the URI module distributed with Ruby: ---need require 'uri'  ?
#   (determine if is url)
#require 'uri'
#
#unless (url =~ URI::regexp).nil?
#    # Correct URL
#end
#
#File need require 'file'?
#A File is an abstraction of any file object accessible by the program and is closely associated with class IO File includes the methods of module FileTest as class methods, allowing you to write (for example) File.exist?("foo").
#
#exist?(file_name) → true or false
#exists?(file_name) → true or false
#Return true if the named file exists.

require_relative 'marshaller'
require_relative 'addset'
require_relative 'choosesettopractice'
require_relative 'chooseroutinetopractice'
require_relative 'routinetoedit'
require_relative 'editroutine'
require_relative 'addroutine'
require_relative 'howdidyoudo'
require_relative 'deleteroutine'
require_relative 'settodelete'
require_relative 'messagebox'
#require_relative 'testWidget'
require 'time'
$FILEPATH = '~/prog/pract/practfiles/'

def is_numeric?(string)
  true if Float(string) rescue false
end

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

#-----------------------------------------------------------

class Trainer

  include Marshaller
####  include widgets

  def main #called at startup
#  test = TestWidget.run_qt("word")
#  puts "test = #{test}"
    practice_sets = []
    if File.exist? FILENAME
      practice_sets, practice_set_names = marshal
      choose_set_to_practice(practice_sets, practice_set_names)
      puts "That's all for now. Goodbye" #delete this once all quits are working right
      write_practice_sets practice_sets
    else
      puts "I can't find your source file. Sorry."
    end
  end

  def at_exit(practice_sets = [])
    puts "Goodbye."
    write_practice_sets practice_sets
    exit
  end

  def choose_set_to_practice(practice_sets, practice_set_names) #called by main and recursed via new_set, add_a_set
    quit = false
    chosen_set_name, quit, add_set, delete_set = ChooseSetToPracticeWidget.run_qt(practice_set_names)
    if add_set then quit = new_set(practice_sets, practice_set_names) end
    if delete_set then quit = delete_a_set(practice_sets, practice_set_names) end
    if quit then at_exit(practice_sets) end
    practice_chosen_set(practice_sets, practice_set_names, chosen_set_name)
  end

  def new_set(practice_sets, practice_set_names) #called by choose_set_to_practice
    quit = false
    text, back, quit = AddSetWidget.run_qt
    if back then choose_set_to_practice(practice_sets, practice_set_names) end
    if quit then at_exit(practice_sets) end
    if !valid_name(text) then new_set(practice_sets, practice_set_names) end
      new_set_name = text
      quit = get_first_routine(new_set_name, practice_sets, practice_set_names)
    return quit
  end

  def valid_name(name) #called by new_set, get_new_routine
    if (name != nil and !name.empty?) then return true end
    MessageBoxWidget.run_qt("Please enter a name.")
    return false
  end

  def get_first_routine(new_set_name, practice_sets, practice_set_names) #called by new_set
    message = "Your set needs at least one routine in it"
    MessageBoxWidget.run_qt(message)
    new_routine = get_new_routine
    if new_routine == "back" then choose_set_to_practice(practice_sets, practice_set_names) end
    if new_routine == "quit" then return true end
    if new_routine.class == Routine
      new_routines = []
      new_routines.push(new_routine)
      build_set(new_set_name, new_routines, practice_sets, practice_set_names)
    end
    return false
  end

  def get_new_routine(new_routine_name = "", new_routine_link = "", priority = 1)# called by add_a_set, add_routine   TODO delete priority from param list?
    name, link, status, priority = AddRoutineWidget.run_qt(new_routine_name, new_routine_link, priority)
puts "status in get_new_routine: #{status}"
puts "status in get_new_routine: #{status}"
    if status == :quit then return "quit" end
    if status == :back then return "back" end
    if valid_name(name) and valid_link(link)
      routine = build_routine(name, link, priority)
    elsif valid_name(name)
      routine = get_new_routine(name)
      if routine == "back" then return "back" end
      if routine == "quit" then return "quit" end
    elsif valid_link(link)
      routine = get_new_routine("", link)
      if routine == "back" then return "back" end
      if routine == "quit" then return "quit" end
    else
      routine = get_new_routine
    end
    return routine
  end

  def valid_link(link) #called by get_new_routine
    if (link != nil and !link.empty?) then return true end
    MessageBoxWidget.run_qt("Please enter something in the link field.")
    return false
  end

  def build_routine(new_routine_name = "", new_routine_link = "", priority = 1)  #?""
    routine = Routine.new({
      :name => new_routine_name,
      :link => new_routine_link,
      :priority => priority,
      :practice_count => 0,
      :success_count => 0,
      :last_routines_practice_count => 0,
      :last_success_value => 0.1,
      :last_date_practiced => Time.now,
      :score => 0 })
  end

  def build_set(new_set_name, new_routines, practice_sets, practice_set_names)
      new_set = PracticeSet.new(new_set_name, 0, new_routines)
      practice_sets.push(new_set)
      practice_set_names.push(new_set_name)
      write_practice_sets(practice_sets)
      practice_sets, practice_set_names = marshal
      choose_set_to_practice(practice_sets, practice_set_names)
  end

  def delete_a_set(practice_sets, practice_set_names)
    set_to_delete, quit, back = SetToDeleteWidget.run_qt(practice_set_names)
    if quit then return quit end
    if (set_to_delete == nil or back) then choose_set_to_practice(practice_sets, practice_set_names) end
    practice_sets.each do |set|
      practice_sets.delete(set) if set.name == set_to_delete
    end
    practice_set_names.delete(set_to_delete)
    choose_set_to_practice(practice_sets, practice_set_names)
  end

  def practice_chosen_set(practice_sets, practice_set_names, chosen_set_name)
    chosen_set_index = practice_set_names.index(chosen_set_name)
    chosen_set = practice_sets[chosen_set_index]
    chosen_set.sort_routines_by_score
    practice_routines(chosen_set, practice_sets, practice_set_names)
  end

  def practice_routines(chosen_set, practice_sets, practice_set_names) # called by choose_set_to_practice, self
    initial_set_size = chosen_set.routines.length
    routines_in_process = chosen_set.routines.clone
    while routines_in_process != []
      chosen_routine, add_routine, delete_routine, edit_stats, quit = ChooseRoutineToPracticeWidget.run_qt(routines_in_process)
      if quit then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
      if edit_stats then edit_routine(chosen_set, routines_in_process) end
      if add_routine
        add_routine(chosen_set, practice_sets, practice_set_names, routines_in_process, initial_set_size)
puts "in practice routines / add routine"        #is quit being returned here?
        practice_routines(chosen_set, practice_sets, practice_set_names)
      end
      if delete_routine then delete_routine(routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names) end
      practice_routine(chosen_routine, routines_in_process, chosen_set)
    end
    index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets)
  end

  def index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets)
puts "index_session_count"
    if routines_in_process.length < initial_set_size then chosen_set.session_count +=1 end
    at_exit(practice_sets)
  end

  def edit_routine(chosen_set, routines_in_process)
        routine = RoutineToEditWidget.run_qt(chosen_set.routines)
        routine_index = chosen_set.routines.index(routine)
        rip_routine_index = routines_in_process.index(routine)

        name, link, priority, practice_count, success_count, last_success_value, back, done, quit = EditRoutineWidget.run_qt(routine)
  #TODO test that each new name is unique
        if done
          routine.name = name
          routine.link = link
          routine.priority = priority
          routine.practice_count = practice_count
          routine.success_count = success_count
          if last_success_value
           routine.last_success_value = (routine.last_success_value ==  0.1 ? 1 : 0.1)
          end
          #TODO# #TODO# #TODO# #TODO# #TODO# #TODO# #TODO# #TODO# #TODO#
   #TODO change last success value to a button in widget
          #put it back in the set...
          chosen_set.routines[routine_index] = routine
          routines_in_process[rip_routine_index] = routine
        elsif back # do nothing - handled later
        elsif quit # do nothing - handled later
        else
          puts "Error in EditRoutine"
        end
  end

  def add_routine(chosen_set, practice_sets, practice_set_names, routines_in_process, initial_set_size) #called by practice_routine
    new_routine = get_new_routine
puts "new_routine in add_routine = #{new_routine}"
    if new_routine == "back" then practice_routines(chosen_set, practice_sets, practice_set_names) end
    if new_routine == "quit" then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end  #########???????
    if new_routine.class == Routine
      chosen_set.routines.push(new_routine)
      write_practice_sets practice_sets   ###########????????????
      practice_sets, practice_set_names = marshal
      routines_in_process.push(new_routine)
      initial_set_size += 1
    end
  end

  def delete_routine(routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names)
        routines_to_delete, quit = DeleteRoutineWidget.run_qt(chosen_set.routines)
        if quit then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
        if routines_to_delete == (nil or []) then practice_routines(chosen_set, practice_sets, practice_set_names) end
        delete_routines(routines_in_process, chosen_set, routines_to_delete)
        end

  def delete_routines(routines_in_process, chosen_set, routines_to_delete)
    routines_to_delete.each do |rtd|

      chosen_set.routines.each do |routine|
        chosen_set.routines.delete(routine) if rtd.name == routine.name
      end

      routines_in_process.each do |routine|
        routines_in_process.delete(routine) if rtd.name == routine.name
      end
    end
  end

  def practice_routine(chosen_routine, routines_in_process, chosen_set)   #TODO when out of routines, "that's all the routines. do you want to practice another set?"
         performance_rating, quit, pass = HowDidYouDoWidget.run_qt(chosen_routine) #TODO if == 5, change priority?   if quit?

        if (pass or performance_rating == 0)
          routines_in_process.delete(chosen_routine)

        else
          if practice_success?(chosen_routine, performance_rating)
            chosen_routine.index_success_counts
          else
            chosen_routine.last_success_value = 0.1
          end
          chosen_routine.index_practice_counts(chosen_set.session_count)
          routines_in_process.delete(chosen_routine)
        end
  end

#  def practice_routines(chosen_set, practice_sets, practice_set_names) # called by choose_set_to_practice #TODO do what if routine can't be shown, if next doesn't exist
#    initial_set_size = chosen_set.routines.length
#    routines_in_process = chosen_set.routines.clone
#    quit = false
#    #TODO if none, choose set again
#    while routines_in_process != [] and !quit
#puts "line 344"
#      chosen_routine, add_routine, delete_routine, edit_stats, quit = ChooseRoutineToPracticeWidget.run_qt(routines_in_process)
##-----------------------add routine----------------
#      if add_routine
#        add_routine(chosen_set, routines_in_process, initial_set_size)
##-----------------------delete routine----------------
#      elsif delete_routine
#        routines_to_delete, quit = DeleteRoutineWidget.run_qt(chosen_set.routines)
#        if quit         #TODO sometimes quit doesn't?
#          puts "quit"
#        elsif routines_to_delete == nil
#          puts "ERROR: routines_to_delete = nil"
#        elsif routines_to_delete == []
#          puts "none"
#          practice_routines(chosen_set, practice_sets, practice_set_names)
#        else
#        puts "routines to delete"
#          routines_to_delete.each do |routine|
#            puts "#{routine.name}"
#          end
#        delete_routine(routines_in_process, chosen_set, routines_to_delete)
#        end
##-------------------------edit routine---------------------
#      elsif edit_stats
#        routine = RoutineToEditWidget.run_qt(chosen_set.routines)
#        routine_index = chosen_set.routines.index(routine)
#        rip_routine_index = routines_in_process.index(routine)
#
#        name, link, priority, practice_count, success_count, last_success_value, back, done, quit = EditRoutineWidget.run_qt(routine)
#  #TODO test that each new name is unique
#        if done
#          routine.name = name
#          routine.link = link
#          routine.priority = priority
#          routine.practice_count = practice_count
#          routine.success_count = success_count
#          if last_success_value
#           routine.last_success_value = (routine.last_success_value ==  0.1 ? 1 : 0.1)
#          end
#          #TODO# #TODO# #TODO# #TODO# #TODO# #TODO# #TODO# #TODO# #TODO#
#   #TODO change last success value to a button in widget
#          #put it back in the set...
#          chosen_set.routines[routine_index] = routine
#          routines_in_process[rip_routine_index] = routine
#        elsif back # do nothing - handled later
#        elsif quit # do nothing - handled later
#        else
#          puts "Error in EditRoutine"
#        end
##--------------------------???-----------------
#      elsif chosen_routine == 'none'
#        choose_set_to_practice(practice_sets, practice_set_names)
#      elsif quit  #if quit do nothing...
#      else
#         performance_rating, quit, pass = HowDidYouDoWidget.run_qt(chosen_routine) #TODO if == 5, change priority?
#
#        if (pass or performance_rating == 0)
#          routines_in_process.delete(chosen_routine)
#
#        else
#          if practice_success?(chosen_routine, performance_rating)
#            chosen_routine.index_success_counts
#          else
#            chosen_routine.last_success_value = 0.1
#          end
#          chosen_routine.index_practice_counts(chosen_set.session_count)
#          routines_in_process.delete(chosen_routine)
#        end
#
#      end
#    end
#
#    if routines_in_process.length < initial_set_size
#      chosen_set.session_count +=1
#    end
#    #TODO return chosen set, none?
#  end

#  def add_routine(chosen_set, routines_in_process = nil, initial_set_size = nil) #called by practice_routines, choose_set_to_practice
#     name, link, back, quit,  priority, done = AddRoutineWidget.run_qt   #TODO can we combine with the add routine stuff above?
#        if done
#          build_routine(name, link, priority)
#        elsif quit #????
#        elsif back #do nothing
#        else
#          puts "Error in AddRoutine, EditRoutine"
#        end
#
#        chosen_set.routines.push(routine)
#        routines_in_process.push(routine) if routines_in_process != nil
#
#        initial_set_size += 1 if initial_set_size != nil
#  end




  def practice_success?(routine, response) #called by practice_routines
    response == 5 or (response == 4 and routine.priority < 4)
  end

#fork doesn't work in windows
#routine.link needs to be the file name for the above call
#for windows this might be "cmd /c start pathtofile\filename"
# I want to reset focus to terminal; maybe wait for linked file to close
# open terminal may work, but first the delay

end


#-------------------------------------------------------------------

trainer = Trainer.new.main




