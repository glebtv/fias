module Fias
  module Name
    module HouseNumber
      class << self
        def extract(orig_name)
          return [orig_name, nil] unless contains_number?(orig_name)

          name, number =
            try_housing(orig_name)          ||
            try_house_word(orig_name)       ||
            try_split_by_colon(orig_name)   ||
            try_ends_with_number(orig_name)

          if number.blank?
            return [remove_trailing_comma(orig_name.try(:strip)), nil]
          end

          [remove_trailing_comma(name.try(:strip)), number.try(:strip)]
        end

        private

        def remove_trailing_comma(str)
          str.nil? ? nil : str.chomp(",")
        end

        def contains_number?(name)
          !(name =~ JUST_A_NUMBER) && !(name =~ LINE_OR_MICRODISTRICT) &&
            (
              name =~ COLON ||
              name =~ ENDS_WITH_NUMBER ||
              name =~ HOUSE_WORD ||
              name =~ NUMBER_WITH_HOUSING
            )
        end

        def try_split_by_colon(name)
          if name =~ COLON
            d = name.split(/\s*,\s*/)

            if contains_number?(d[-1])
              [d[0..-2].join(", "), d[-1]]
            else
              nil
            end
          end
        end

        def try_housing(name)
          match = name.match(NUMBER_WITH_HOUSING)
          [match.pre_match, "#{match} #{match.post_match}"] if match
        end

        def try_house_word(name)
          match = name.match(HOUSE_WORD)
          [match.pre_match, match.post_match] if match
        end

        def try_ends_with_number(name)
          match = name.match(ENDS_WITH_NUMBER)
          [match.pre_match, match[1]] if match
        end

        def or_words(words)
          words
            .sort_by(&:length)
            .reverse
            .map { |w| Regexp.escape(w) }
            .join('|')
        end
      end

      COLON                 = /\,/
      JUST_A_NUMBER         = /^[\s\d]+$/
      STOPWORDS             = /(микрорайон|линия|микр|мкрн|мкр|лин)/ui
      LINE_OR_MICRODISTRICT = /#{STOPWORDS}\.?[\s\w+]?\d+$/ui
      NUMBER                = /\d+\/?#{Fias::LETTERS}?\d*/ui
      ENDS_WITH_NUMBER      = /(#{NUMBER})$/ui
      HOUSE_WORDS           = %w(ом д дом вл кв)
      HOUSE_WORD =
        /(\s|\,|\.|^)(#{or_words(HOUSE_WORDS)})(\s|\,|\.|$)/ui
      HOUSING_WORDS         = %w(корпус корп к)
      NUMBER_WITH_HOUSING   =
        /#{NUMBER}[\s\,\.]+(#{or_words(HOUSING_WORDS)})[\s\,\.]+#{NUMBER}/ui
    end
  end
end
