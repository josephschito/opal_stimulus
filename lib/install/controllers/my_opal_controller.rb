class MyOpalController < StimulusController
  def connect
    puts "'#{self.class.name}' connected!"
  end
end
