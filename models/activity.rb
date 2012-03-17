class Activity
  include DataMapper::Resource

  property :id, Serial, :required => true
  property :message, String, :required => true
end
