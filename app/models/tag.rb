class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts
  
  validates_uniqueness_of   :name, :case_sensitive => false
  def to_param
    my_title = ""
    name.gsub(/([a-zA-Z0-9])+|[\xe4-\xe9][\x80-\xbf][\x80-\xbf]/i) {|s| my_title += s }
    my_title ? my_title: ''
  end

  def rand_posts
    Post.published.find(:all,:limit => 5,:order => "rand()",:include =>  [:tags],:conditions => ["tags.id = ?",self.id] )
  end

end
