#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../config/environment'
require 'drb/drb'
require 'ferret'
require 'singleton'
require 'rubygems'
require 'rmmseg'
require 'rmmseg/ferret'



INDEX_URI="druby://localhost:8788"

class ServerSearcher

  include Ferret
  include Ferret::Index
  include Ferret::Store
  include Ferret::Search
  include Ferret::Analysis
  include Singleton


  include DRb::DRbUndumped

  def initialize()
    index_path = "#{RAILS_ROOT}/index1"
    dir = FSDirectory.new(index_path)

    reader = IndexReader.new(dir)
    @searcher = Searcher.new(reader)

    # dictionaries needed to be explicitly loaded
    RMMSeg::Dictionary.load_dictionaries

    analyzer = RMMSeg::Ferret::Analyzer.new { |tokenizer|
      Ferret::Analysis::LowerCaseFilter.new(tokenizer)
    }

    @query_parser = Ferret::QueryParser.new(:fields => [:title, :body],
      :tokenized_fields => [:title, :body],
      :analyzer => analyzer)
  end

    
  def search(query)
    parsed_query = @query_parser.parse(query)
    result = []
    @searcher.search_each(parsed_query) do |doc_id, score|
      body_highlights = @searcher.highlight(parsed_query, doc_id, :body,
        :pre_tag => "<span class=\"highlight\">",
        :post_tag => "</span>")
      title_highlights = @searcher.highlight(parsed_query, doc_id, :title,
        :pre_tag => "<span class=\"highlight\">",
        :post_tag => "</span>")
      result << {:id => @searcher.reader.get_document(doc_id)[:id],
        :title => title_highlights,
        :body => body_highlights
      }
    end

    return result
  end
  
end

FRONT_OBJECT=ServerSearcher.instance()
$SAFE = 0   # disable eval() and friends

DRb.start_service(INDEX_URI, FRONT_OBJECT)
puts DRb.uri
DRb.thread.join

