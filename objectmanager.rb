def is_numeric?(string)     #TODO is this still used?
  true if Float(string) rescue false
end

module ObjectManager

#  include Marshaller
#  include Os
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

  def index_session_count(routines_in_process, initial_set_size, chosen_set, practice_sets)     #TODO PM
    if routines_in_process.length < initial_set_size then chosen_set.session_count +=1 end
    at_exit(practice_sets)
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

  def practice_success?(routine, response) #called by practice_routines  #TODO PM
    response == 5 or (response == 4 and routine.priority < 4)
  end

end
