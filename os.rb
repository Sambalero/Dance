
module Os


  def identifyOS #called by trainer.main
    os = RUBY_PLATFORM
    if /mingw/ =~ os then os = "windows" end
    if /darwin/ =~ os then os = "mac" end
    return os
  end

  def launch_routine_file(routine) #called by trainer.practice_routine
puts "routine.link: #{routine.link}"
if File.exist? routine.link
  puts "File exists"
elsif  (routine.link =~ (URI::DEFAULT_PARSER.regexp[:ABS_URI]))
  puts "This is a URI."
else
  puts "Not recognized as file or link"
end

    if File.exist? routine.link or (routine.link =~ (URI::DEFAULT_PARSER.regexp[:ABS_URI]))
      if identifyOS == "mac" then pid = spawn "open #{routine.link}" end
      if identifyOS == "windows" then pid = spawn "start #{routine.link}" end
      Process.detach(pid)

    else
        MessageBoxWidget.run_qt(routine.link)
    end
  end
end

