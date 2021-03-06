class User < ActiveRecord::Base
  #after_create :set_actable
  # Enable API authentication
  acts_as_token_authenticatable 
  
  ## RELATIONS
  has_many :positions
  has_many :user_problems
  has_many :user_histories
  has_many :sessions
  has_many :transactions

  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/


  # Include default devise modules. Others available are:
  # :lockable, :timeoutable

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :omniauthable, :validatable

  validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update

  def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user

    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
      email = auth.info.email if email_is_verified
      user = User.where(:email => email).first if email

      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          name: auth.extra.raw_info.name,
          #username: auth.info.nickname || auth.uid,
          email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
          password: Devise.friendly_token[0,20]
        )
        user.skip_confirmation!
        user.save!
      end
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end

  ## STATIC VALUES
  # To add a new role, include it on the list.
  ROLES = %W[admin_user passenger jitney]
  
  ## ACT ASS SUPERCLASS
  actable
  ## INSTANCE METHODS
  ROLES.each do |role_name|
    define_method "#{role_name}?".to_sym do
      self.role?.present? && (self.role?.eql? role_name)
    end
  end
  
  def role?
    self.actable_type.underscore
  end

  def set_actable
    binding.pry
    #passenger = Passenger.create(automatic_map: true)
    @user = User.last
    @user.account_type = 2
    @user.actable_type = "Passenger"
    @user.save
    super.sign_in(@user, :bypass => true)
    redirect_to "/profile/#{@user.id}", notice: 'Your profile was successfully updated.'
  end

end 