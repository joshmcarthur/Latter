class Activity
  include DataMapper::Resource

  property :id, Serial, :required => true
  property :message, String, :required => true
  property :created_at, DateTime, :default => lambda { |record, property| Time.now }
end
