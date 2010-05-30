#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'
require 'ferret'
require 'rubygems'
require 'action_view'

include Ferret
include Ferret::Index
include Ferret::Store
include ActionView::Helpers::SanitizeHelper
include ActionView::Helpers::SanitizeHelper::ClassMethods



index_path = "#{RAILS_ROOT}/index1"
dir = FSDirectory.new(index_path)

index_writer = IndexWriter.new(:dir => dir)
posts = Post.published.all(:conditions => {:publish_at => (Time.now.midnight - 1.day)..Time.now + 1.day})
posts.each do |post|
  doc = Document.new()
  doc[:id] = post.id
  doc[:title] = post.title
  doc[:body] = strip_tags(post.body).gsub!(/\n/, ' ')
  puts "Updating index--- Adding:" + post.title;
  index_writer.add_document(doc)
end
index_writer.commit()
index_writer.close()

