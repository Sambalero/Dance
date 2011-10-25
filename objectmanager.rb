def is_numeric?(string)     #TODO is this still used?
  true if Float(string) rescue false
end

class ObjectManager

  include Marshaller
  include Os
####  include widgets

  def main #called at startup  #TODO   PM
#  test = TestWidget.run_qt("word")
#  puts "test = #{test}"
if identifyOS == "mac"
  os = identifyOS
  puts "Operating System is #{os}"
end
    practice_sets = []
    if File.exist? FILENAME
      practice_sets, practice_set_names = marshal
      choose_set_to_practice(practice_sets, practice_set_names)  #TODO PP
      write_practice_sets practice_sets
    else
      puts "I can't find your source file. Sorry."
    end
  end

  def at_exit(practice_sets = [])  #TODO PM
    puts "Goodbye."
    write_practice_sets practice_sets
    exit
  end

  def choose_set_to_practice(practice_sets, practice_set_names) #called by main and recursed via new_set, add_a_set      #TODO PP
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

  def get_new_routine(new_routine_name = "", new_routine_link = "") # called by get_first_routine, add_routine, self
    name, link, status, priority = AddRoutineWidget.run_qt(new_routine_name, new_routine_link)
puts "status in get_new_routine: #{status}"
    if status == :quit then return "quit" end    #TODO change "" to :
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

  def build_routine(new_routine_name, new_routine_link, priority = 1)   #TODO PM
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

  def build_set(new_set_name, new_routines, practice_sets, practice_set_names) #called by get_first_routine  #TODO PM
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
    set_up_practice_routines(chosen_set, practice_sets, practice_set_names)
  end

  def set_up_practice_routines(chosen_set, practice_sets, practice_set_names)  # called by practice_chosen_set
    initial_set_size = chosen_set.routines.length
    routines_in_process = chosen_set.routines.clone
    practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
  end

  def practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) # called by set_up_practice_routines, self, delete_routines, edit_routine, add_routine
    while routines_in_process != []
      chosen_routine, response = ChooseRoutineToPracticeWidget.run_qt(routines_in_process)
      if response == :quit then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
      if response == :edit_routine then edit_routine(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) end
      if response == :add_routine
        add_routine(chosen_set, practice_sets, practice_set_names, routines_in_process, initial_set_size)
        practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
      end
      if response == :delete_routine
        delete_routine(routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names)
        practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
      end
      if response == :back then choose_set_to_practice(practice_sets, practice_set_names) end
      practice_routine(chosen_routine, routines_in_process, initial_set_size, chosen_set, practice_sets)
    end
    index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets)
  end

  def index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets)     #TODO PM
    if routines_in_process.length < initial_set_size then chosen_set.session_count +=1 end
    at_exit(practice_sets)
  end

  def edit_routine(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) #called by practice_routine
    routine = RoutineToEditWidget.run_qt(chosen_set.routines)
    routine_index = chosen_set.routines.index(routine)
    rip_routine_index = routines_in_process.index(routine)
    name, link, priority, practice_count, success_count, last_success_value, status = EditRoutineWidget.run_qt(routine)
  #TODO test that each new name is unique
  #TODO update values in widget
  #TODO increment success count with last success value change
    if status == :done
      routine.name = name
      routine.link = link
      routine.priority = priority
      routine.practice_count = practice_count
      routine.success_count = success_count
      if last_success_value
       routine.last_success_value = (routine.last_success_value ==  0.1 ? 1 : 0.1)
      end
      chosen_set.routines[routine_index] = routine
      if rip_routine_index != nil
        routines_in_process[rip_routine_index] = routine
      end
      practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
    end
    if status == :back then practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) end
    if status == :quit then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
  end

  def add_routine(chosen_set, practice_sets, practice_set_names, routines_in_process, initial_set_size) #called by practice_routines   #TODO PM
    new_routine = get_new_routine
    if new_routine == "back" then practice_routines(chosen_set, practice_sets, practice_set_names) end
    if new_routine == "quit" then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
    if new_routine.class == Routine
      chosen_set.routines.push(new_routine)
      write_practice_sets practice_sets
      practice_sets, practice_set_names = marshal
      chosen_set = get_new_chosen_set(practice_sets, chosen_set)
      routines_in_process = re_create_routines_in_process(chosen_set, routines_in_process, new_routine)
      initial_set_size += 1
      practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process)
    end
  end

  def re_create_routines_in_process(chosen_set, routines_in_process, new_routine) #called by add_routine     #TODO PM
    new_routines_in_process = chosen_set.routines.clone
    old_routines_in_process_names = []
    routines_in_process.each do |routine|
       old_routines_in_process_names.push(routine.name)
    end
    old_routines_in_process_names.push(new_routine.name)
    new_routines_in_process.each do |routine|
      new_routines_in_process.delete routine if not old_routines_in_process_names.include? routine.name
    end
    return new_routines_in_process
  end

  def get_new_chosen_set(practice_sets, chosen_set)     #TODO PM
    new_chosen_set = ""
    practice_sets.each do |set|
      new_chosen_set = set if set.name == chosen_set.name
    end
    return new_chosen_set
  end

  def delete_routine(routines_in_process, initial_set_size, chosen_set, practice_sets, practice_set_names)
    routines_to_delete, status = DeleteRoutineWidget.run_qt(chosen_set.routines)
    if status == :quit then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
    if status == :back then practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) end
    if routines_to_delete == (nil or []) then practice_routines(chosen_set, practice_sets, practice_set_names, initial_set_size, routines_in_process) end
    #TODO list routines to delete for user and confirm
    delete_routines(routines_in_process, chosen_set, routines_to_delete, initial_set_size)
  end

  def delete_routines(routines_in_process, chosen_set, routines_to_delete, initial_set_size)   # called by delete_routine  #TODO PM
    routines_to_delete.each do |routine_to_delete|

    chosen_set.routines.each do |routine|
      chosen_set.routines.delete(routine) if routine_to_delete.name == routine.name
    end

    routines_in_process.each do |routine|
      routines_in_process.delete(routine) if routine_to_delete.name == routine.name
    end
    initial_set_size -= 1
    end
  end

  def practice_routine(chosen_routine, routines_in_process, initial_set_size, chosen_set, practice_sets)  #called by practice_routines
  #TODO when out of routines, "that's all the routines. do you want to practice another set?"
    performance_rating, status = HowDidYouDoWidget.run_qt(chosen_routine) #TODO if == 5, change priority?   if quit?
puts "status in practice_routine = #{status}"
puts "performance_rating in practice_routine = #{performance_rating}"
    if status == :show
      launch_routine_file(chosen_routine)
      practice_routine(chosen_routine, routines_in_process, initial_set_size, chosen_set, practice_sets)
    end
    if status == :quit then index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets) end
    if status == :pass
      initial_set_size -= 1
      routines_in_process.delete(chosen_routine)
    else #status == next TODO: change next button to OK button
      if practice_success?(chosen_routine, performance_rating)
        chosen_routine.index_success_counts
      else
        chosen_routine.last_success_value = 0.1
      end
      chosen_routine.index_practice_counts(chosen_set.session_count)
      routines_in_process.delete(chosen_routine)
    end
  end

  def practice_success?(routine, response) #called by practice_routines  #TODO PM
    response == 5 or (response == 4 and routine.priority < 4)
  end

end


#-------------------------------------------------------------------

trainer = Trainer.new.main




