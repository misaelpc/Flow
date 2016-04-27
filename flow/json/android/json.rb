class JSON
  def self.load(response)
      tokener = Org::JSON::JSONTokener.new(response)
      obj = tokener.nextValue

      @convert_java ||= (lambda do |item|
          case item
          when Org::JSON::JSONArray
              item.length.times.map{ |i| @convert_java.call(item.get(i))}
          when Org::JSON::JSONObject
              iter = item.keys
              hash = Hash.new
              while iter.hasNext
                  key = iter.next
                  value =item.get(key)
                  hash[@convert_java.call(key)] = @convert_java.call(value)
              end
              hash
          when Java::Lang::String
              item.to_s
          else
              item
          end
      end)

      @convert_java.call(obj)
  end

  def self.to_json(hash = {})
    # The Android JSON API expects real Java String objects.
    @@fix_string ||= (lambda do |obj|
      case obj
        when String
          obj = obj.toString
        when Hash
          map = Hash.new
          obj.each do |key, value|
            key = key.toString if key.is_a?(String)
            value = @@fix_string.call(value)
            map[key] = value
          end
          obj = map
        when Array
          obj = obj.map do |item|
            item.is_a?(String) ? item.toString : @@fix_string.call(item)
          end
      end
      obj
    end)

    obj = Org::JSON::JSONObject.wrap(@@fix_string.call(hash))
    if obj == nil
      raise "Can't serialize object to JSON"
    end
    obj.toString.to_s
  end
end
