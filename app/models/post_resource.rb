  class PostResource < ActiveResource::Base
    self.site = "http://rmatech.com/"
    #self.site = "http://localhost:3000/"
    self.element_name = "post"
  end
