require 'nokogiri'
require 'open-uri'

require_relative 'constants/entity_types'
require_relative 'constants/entity_urls'
require_relative 'constants/entity_identifiers'

entity_type = ARGV[0]

HTTP_HEADERS = {
  "User-Agent" => "artsdata-crawler (compatible; +https://kg.artsdata.ca/doc/artsdata-crawler)",
  "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  "Accept-Language" => "en-US,en;q=0.9"
}.freeze

def collect_urls(entityType)
  if entityType == EntityTypes[:PERFORMANCE]
    main_page_url = EntityURLs[:PERFORMANCE]
    main_entity_identifier = EntityIdentifiers[:TOUR_DATES]
    entity_identifier = EntityIdentifiers[:APPEARANCES]
  else
    main_page_url = EntityURLs[:EXHIBITION]
    main_entity_identifier = EntityIdentifiers[:EXHIBITION_DATES]
    entity_identifier = EntityIdentifiers[:EXHIBITIONS]
  end

  main_doc = Nokogiri::HTML(URI.open(main_page_url, HTTP_HEADERS).read)
  urls = []
  main_doc.css(main_entity_identifier).each do |main_entity|
    url = main_entity['href']
    entity_doc = Nokogiri::HTML(URI.open(url, HTTP_HEADERS).read)
    entity_doc.css(entity_identifier).each do |entity|
      urls << entity['href'].to_s.gsub(' ', '+')
    end
  end
  urls.uniq
end

# Emit the flat, comma-separated URL list for the shared pipeline action.
puts collect_urls(entity_type).join(',')