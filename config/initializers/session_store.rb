# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_swordfish_session',
  :secret      => '54107516b2ed4a6d7d7679752ea47237ca5c0137d5f773c664f7d25d3410482027c1994ed4ac8190c86338d7a750b6fdc5322027557115be7146200e672c90a4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
