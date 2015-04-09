# Old not needed now
class YA2Processor
  # parse marks html files into one hash per model (mark, model, self title, marked title, years, url)
  # def step_30
  #   brand_yandex_titles = CWD.data_brands['brands']
  #
  #   results = {}
  #
  #   CW.parse_dir("02-marks", silent: true) do |doc, basename, path|
  #     doc.css("div.b-cars__page a.b-car").each do |a|
  #       full_yandex_title = a.at_css(".b-car__title").text
  #       url = a['href']
  #
  #       result = OpenStruct.new
  #       result.direct = true if url !~ /^\/search/
  #       result.url = url
  #
  #       if summary = a.at_css(".b-car__summary")
  #         result.summary = summary.xpath('text()').text.sub(/, $/, '')
  #         result.years = a.at_css('.b-car__year-range').text
  #       end
  #
  #       if generations = a.at_css(".b-car__count")
  #         result.generations = generations.text
  #       end
  #
  #
  #       if url.start_with?('/search')
  #         # /search?mark=acura&model=tsx&no_redirect=true&group_by_model=false
  #         result.mark = url.scan(%r{mark=(\w+)}).first.first
  #         result.model = url.scan(%r{(?:\?|\&)model=(\w+)}).first.first
  #       else
  #         # /acura/ilx/20291740
  #         result.mark, result.model = url.scan(%r{^/(\w+)/(\w+)}).first
  #       end
  #
  #       result.title = full_yandex_title.sub brand_yandex_titles[result.mark] + ' ', '' # Ford Focus => Focus
  #
  #       if result.mark == 'bmw' && result.title.include?('series')
  #         result.title.sub!('series', 'Series')
  #       end
  #
  #       result.full_title = convert_yandex_model_title_to_internal(result.mark, result.title)
  #
  #       result.key = "#{result.mark}--#{result.model}"
  #
  #       results[result.key] = CW.stringify_keys(result)
  #     end
  #   end
  #
  #   CW.write_data "03-models", results
  # end
end
