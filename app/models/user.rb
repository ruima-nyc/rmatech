class User < ActiveRecord::Base
  attr_accessor :password
  attr_protected :admin

  before_save   :encrypt_password

  after_create :update_last_login
  validates_presence_of     :login, :message => "Nickname can't be blank"
#  validates_presence_of     :password, :if => Proc.new { |user| user.passwd != 'qifei'}
  validates_length_of       :email,    :within => 3..100
  validates_format_of       :login, :with => /^[\sA-Za-z0-9-]+$/
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9A-Z]+\.)+[a-zA-Z]{2,})$/
  validates_uniqueness_of   :login, :email, :case_sensitive => false

def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_login(args)
    else
      super
    end
  end

 def to_param
    login
  end

  has_and_belongs_to_many :posts

  def self.authenticate(login, password)
    # hide records with a nil activated_at
    u = find :first, :conditions => ['login = ?', login]

    u && u.authenticated?(password) && u.update_last_login ? u : nil
  end

  def self.encrypt(password, salt)
    #Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    Digest::SHA1.hexdigest(password)
  end

  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.months.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def authenticated?(password)
    passwd == encrypt(password)
  end

  def admin?
    admin
  end

  def update_last_login
    self.update_attribute(:last_login_at, Time.now)
  end


  protected

  # before filters
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.passwd = encrypt(password)
  end

end
