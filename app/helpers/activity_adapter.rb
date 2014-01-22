module ActivityAdapter

  @@collection_size = 25

  def self.all
    PublicActivity::Activity.limit(@@collection_size)
  end

end