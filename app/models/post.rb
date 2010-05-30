require 'digest/sha1'
require 'searcher'

class Post < ActiveRecord::Base
  extend Searcher
  
  validates_format_of :url, :with => /^((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
  
  acts_as_commentable
  
  cattr_reader :per_page
  @@per_page = 32

  named_scope :published, :conditions => ["status = 1 or status = 2"]
  named_scope :unpublished, :conditions => ["status = ?", 0]

  
  validates_presence_of :title
  validates_presence_of :url

  belongs_to :feed

  belongs_to :creator, :class_name => "User",:foreign_key => "creator_id"
  has_and_belongs_to_many :tags

  has_and_belongs_to_many :users


  before_create :create_uid

  def source
    if self.feed
      self.feed.title
    elsif self.creator
      "<a href=\"/#{self.creator.login}\" class=\"user\">#{self.creator.login}</a>"
    else
      "游客"
    end
  end

  def publish(timestamp)
    update_attribute('status',1)
    update_attribute('publish_at',Time.now) if timestamp
  end

  def unpublish
    update_attribute('status',0)
  end

  def dispose
    update_attributes(:status => 99,:body => '')
  end


  def tags=(tag_ids)
       tag_ids.each {|id|
        tag = Tag.find(id)
        self.tags << tag if tag
#         puts "Tagging #{@post.title} as #{tag.name}!"
      }
  end

  def create_uid
    self.uid = Digest::SHA1.hexdigest("#{self.feed_id}-#{self.title}")
  end
end
