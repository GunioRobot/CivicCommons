module CCML
  module Tag

    private

    #--
    # A wrapper class for a Hash used in tag pair conditional processing.
    #++
    class HashWrapper
      def initialize(hash)
        @hash = hash
      end
      def method_missing(sym, *args, &block)
        if @hash.has_key?(sym)
          return @hash[sym]
        elsif @hash.has_key?(sym.to_s)
          return @hash[sym.to_s]
        else
          raise NameError, "undefined local variable or method '#{sym.to_s}' for #{@hash}"
        end
      end
    end

    public

    class TagPair < Base

      attr_writer :tag_body

      def process_tag_body(data)

        if_block_pattern = /\{if\s+.+?}.*?(\{if:elsif\s+.+?}.+?)*?(\{if:else}.+?)??\{\/if}/im
        if_pattern = /\{if\s+(?<cond>.+?)}(?<body>.+?)\{\/?if/im
        elsif_pattern = /\{if:else?if\s+(?<cond>.+?)}(?<body>.+?)\{\/?if/im
        else_pattern = /\{if:else}(?<body>.+?)\{\/if}/im

        # inputs and outputs
        return_data = ''
        data = [ data ] unless data.is_a?(Array)

        # iterate through all data items
        data.each do |datum|

          # wrap the hash for later evaluation
          datum = CCML::Tag::HashWrapper.new(datum) if datum.is_a?(Hash)

          # refresh the tag body
          tag_body = String.new(@tag_body.to_s)

          # iterate through all the conditionals in the tag body
          match = if_block_pattern.match(tag_body)
          while match
            
            found = false

            # process the 'if' conditional
            if_match = if_pattern.match(match.to_s)
            begin
              if datum.instance_eval(if_match[:cond])
                sub = if_match[:body]
                tag_body.sub!(match.to_s, sub)
                found = true
              end
            rescue
              # continue
            end

            # process all 'elsif' conditionals
            if not found
              if_match = elsif_pattern.match(match.to_s)
              while if_match
                begin
                  if datum.instance_eval(if_match[:cond])
                    sub = if_match[:body]
                    tag_body.sub!(match.to_s, sub)
                    found = true
                    break
                  end
                rescue
                  # continue
                end
                pos = if_match.end(2)
                if_match = elsif_pattern.match(match.to_s, pos)
              end
            end

            # process the else
            if not found
              if if_match = else_pattern.match(match.to_s)
                sub = if_match[:body]
                tag_body.sub!(match.to_s, sub)
                found = true
              end
            end

            # wipe the entire match if no conditional is true
            if not found
              sub = ''
              tag_body.sub!(match.to_s, sub)
            end

            # look for another match
            pos = match.begin(0) + sub.length
            match = if_block_pattern.match(tag_body, pos)
          end

          # iterate through all vars in the tag body
          var_pattern = /\{(?<var>\w+)}/
          match = var_pattern.match(tag_body)
          while match

            # get the variable name
            var = match[:var].to_sym

            # get the variable data
            begin
              sub = datum.send(var)
            rescue Exception => e
              sub = nil
            end

            # make the substitution
            sub = sub.to_s
            tag_body = tag_body.sub(match.to_s, sub)

            # look for another match
            pos = match.begin(0) + sub.length
            match = var_pattern.match(tag_body, pos)
          end

          # append to the output buffer
          return_data << tag_body

        end

        return return_data
      end

    end
  end
end
