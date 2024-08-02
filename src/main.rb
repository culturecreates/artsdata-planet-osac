require 'nokogiri'
require 'open-uri'
require 'linkeddata'

require_relative 'constants/entity_types'
require_relative 'constants/entity_urls'
require_relative 'constants/entity_identifiers'

entity_type = ARGV[0]

def get_entities(entityType)

  if entityType == EntityTypes[:PERFORMANCE]
    main_page_url = EntityURLs[:PERFORMANCE]
    main_entity_identifier = EntityIdentifiers[:TOUR_DATES]
    entity_identifier = EntityIdentifiers[:APPEARANCES]
  else
    main_page_url = EntityURLs[:EXHIBITION]
    main_entity_identifier = EntityIdentifiers[:EXHIBITION_DATES]
    entity_identifier = EntityIdentifiers[:EXHIBITIONS]
  end
  main_page_html_text = URI.open(main_page_url).read
  main_doc = Nokogiri::HTML(main_page_html_text)
  main_entities = main_doc.css(main_entity_identifier)
  urls = []
  main_entities.each do |main_entity|
    url = main_entity['href']
    main_entity_page_html_text = URI.open(url).read
    main_entity_doc = Nokogiri::HTML(main_entity_page_html_text)
    entities =  main_entity_doc.css(entity_identifier)
    entities.each do |entity|
      urls << entity['href']
    end
  end
  graph = RDF::Graph.new
  urls.each do |entity_url|
    begin
      entity_url = entity_url.gsub(' ', '+')
      loaded_graph = RDF::Graph.load(entity_url)
      graph << loaded_graph
    rescue StandardError => e
      puts "Error loading RDF from #{entity_url}: #{e.message}"
      break
    end
  end

  File.open("outputs/#{entityType}.jsonld", 'w') do |file|
    file.puts(graph.dump(:jsonld))
  end
end

get_entities(entity_type)

