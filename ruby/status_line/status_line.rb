# Class to display a single status line that updates on top of it's self
# Items are shown in the order they are added
#
# Example:
#   sl = StatusLine.new
#   sl.counter(:files)
#   sl.string(:current)
#   sl.elapsed
#   
#   sl.start do |status|
#     loop do
#       # do some stuff
#  
#       status.increment(:files)
#       status.update(:current, 'some-string')
#       status.show
#     end
#   end
class StatusLine
  def initialize
    @data = {}
  end

  # Start block for the status line, this will down show the 
  # before the start and at the end as as well as output a 
  # newline so we can have clean output afterwards
  def start(&block)
    @start_time = Time.now
    show
    yield self
    show
    clear
  end
  
  # Add a generic item to the status line.  The passed in block
  # controlls how the item is updated/incremented
  # 
  # The block will be given in the value of the item,
  # plus any additional params passed to the update function.
  def add(name, default, format, &block)
    @data[name] = {
      :order => @data.size + 1,
      :format => format,
      :value => default,
      :update_callback => block
    }
  end
  
  # Add an elapsed counter to the status line
  def elapsed
    add(:elapsed, '00:00:00', '%s') { |v,elapsed|
      sprintf('%02i:%02i:%02i', 
        elapsed / 3600, # hours, 
        elapsed / 60 % 60, #minutes, 
        elapsed % 60 #seconds
      )
    }
  end
  
  # Add a simple counter item to the status line
  def counter(name, default=0, size=5)
    add(name, default, "%#{size}d") { |v| v+= 1 }
  end
  
  # Add a simple string item to the status line
  def string(name, default='', format='%s')
    add(name, default, format) { |v,a| a }
  end
  
  # Increment the named item, will work on any item but
  # doesn't pass any additional params to the items update 
  # block
  def increment(name)
    update(name)
  end
  
  # Update the named item passing any additional params to the update block
  def update(name, *params)
    return false unless @data.has_key? name
    
    @data[name][:value] = @data[name][:update_callback].call(@data[name][:value], *params)
  end
  
  # Output the status line to STDOUT
  def show
    data, format = [], []
    
    update(:elapsed, (Time.now - @start_time).to_i)
    
    sorted = @data.sort { |a,b| a[1][:order]<=>b[1][:order] }
    sorted.each do |item|
      format << "#{item[0].to_s.capitalize}: #{item[1][:format]}"
      data << item[1][:value] 
    end
    
    $stdout.printf(format.join(' | ') + "\r", *data)
    $stdout.flush
  end
  
  # Add a newline to the STDOUT, this clears the line for normal outptu
  def clear
    $stdout.print "\n"
    $stdout.flush
  end
end