#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../config/environment'
require 'ferret'
require 'rubygems'
require 'rmmseg'
require 'rmmseg/ferret'
require 'action_view'

include Ferret
include Ferret::Index
include ActionView::Helpers::SanitizeHelper
include ActionView::Helpers::SanitizeHelper::ClassMethods
#include Ferret::Analysis

# dictionaries needed to be explicitly loaded
RMMSeg::Dictionary.load_dictionaries

analyzer = RMMSeg::Ferret::Analyzer.new { |tokenizer|
  Ferret::Analysis::LowerCaseFilter.new(tokenizer)
}
index_path = "#{RAILS_ROOT}/index1"

puts "index_path is #{index_path}"

field_infos = Ferret::Index::FieldInfos.new(:term_vector => :no)
field_infos.add_field(:id, :index => :untokenized)
field_infos.add_field(:title, :term_vector => :with_positions_offsets,
                        :boost => 10.0)
field_infos.add_field(:body, :term_vector => :with_positions_offsets)


index = Ferret::Index::Index.new(:path => index_path,
                                  :analyzer => analyzer,
                                  :field_infos => field_infos,
                                  :create => true,
                                  :auto_flush => true)

@post = Post.published;
@post.each do |post|
  body = strip_tags(post.body)
  body.gsub!(/\n/, ' ')
  index << {
    :id =>  post.id,
    :title => post.title,
    :body =>  body,
  }
end

puts "Optimizing..."
index.optimize()
index.close()
puts "Finished!"
