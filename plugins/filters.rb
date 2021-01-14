module Jekyll
    module LinkFilters
        def calculate_toc_width(array)
            len = [0]

            array.each { |x| len << x['name'].length }

            len.max().ceil() / 2
        end

        def list_link_rel(array)
            out = []

            array.each do |input|
                out << link_rel(input)
            end

            out
        end

        def link_rel(input)
            name = input['name']
            anchor = input['anchor']
            annotation = input['annotation']

            anchor_slug = anchor.gsub(/[\s\W]+/, "-").downcase

            link = name
            link = "#{name}##{anchor_slug}" if not anchor.empty?
 
            abbreviation = name
            abbreviation = anchor if not anchor.empty?

            annotation = annotate(name, annotation) if annotation
            abbreviation = "<abbr title='#{annotation}'>#{abbreviation}</abbr>" if annotation

            if name != name.downcase
                if @context.registers[:site].data['classes'].has_key? name
                    "<a href='/class/#{link}'>#{abbreviation}</a>"
                elsif @context.registers[:site].pages.any? { |p| p.url == "/#{name}" }
                    "<a href='/#{link}'>#{abbreviation}</a>"
                else
                    "<a href='#' class='invalid'>#{abbreviation}</a>"
                end
            else
                "#{abbreviation}"
            end
        end

        private

        def annotate(type, ann)
            if type == "number"
                dim = /(\d+), (\d+)/.match(ann)

                "A number in the range #{dim[1]} to #{dim[2]}, inclusive."
            elsif type == "table"
                dict = /(\w+), (\w+)/.match(ann)

                if dict
                    "A table with #{dict[1]} keys and #{dict[2]} values."
                else
                    "An array of #{ann} values."
                end
            else
                ann
            end
        end
    end
end

Liquid::Template.register_filter(Jekyll::LinkFilters)