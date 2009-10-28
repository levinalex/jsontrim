require 'json'

# takes a JSON object, removes specified subtrees and trims arrays
# returns a pretty printed string
#
#     before = <<-EOF
#     { "foo": {
#         "one": { "a": 1, "b": {"c": 2} },
#         "two": "value",
#         "three": { "b": [1,2,3] }},
#       "bar": [1,2,3,4,5] }
#     EOF
#
#     blacklist = [
#       "foo:!two",   # delete the value before['foo']['two']
#       "foo:*:!b",   # delete all the keys called "b" nested two levels under "foo"
#       "bar:+"       # only keep the first element of the foo-list
#     ]
#
#     after = JSONTrim.cut(before, :ignore => blacklist)
#
#      {
#        "foo": {
#          "two": ...,
#          "three": {
#            "b": [ ... ]
#          },
#          "one": {
#            "a": 1,
#            "b": { ... }
#          }
#        },
#        "bar": [
#          1,
#          ...
#        ]
#      }
#
class JSONTrim

  # prune the given JSON-string or ruby Hash according to
  # the rules given in opts[:ignore]
  #
  def self.cut(obj, opts = {})
    obj = JSON.parse(obj) if String === obj

    (opts[:ignore] || []).each do |ignore_str|
      ignoring = ignore_str.split(":")

      obj = cutr(obj, ignoring)
    end

    js = JSON.pretty_generate(obj)
    js = js.gsub('"IGN_HSH"', "{ /*...*/ }")
    js = js.gsub('"IGN_ARY"', "[ /*...*/ ]")
    js = js.gsub('"IGN_CDR"', "// ...")
    js = js.gsub('"IGN"', '"..."')
  end
  
  # recursively prune the current ruby object with the given rules
  # replace pruned elements with marker strings
  #
  #   cutr( [1,2,3],         ["+"] )       #=> [ 1, "IGN" ]
  #   cutr( {"a"=>{"b"=>3}}, ["!a"] )      #=> { "a" => "IGN_HSH" }
  #   cutr( {"a"=>{"b"=>3}}, ["a", "!b"])  #=> { "a" => { "b" => "IGN" }}
  #
  def self.cutr(data, rules)
    key, *rest = rules

    if key =~ /^!(.*)/
      name = $1

      data[name] = case data[name]
                     when Hash then "IGN_HSH"
                     when Array then "IGN_ARY"
                     else "IGN"
                   end if data[name]
    elsif key =~ /^\+$/
      if Array === data
        data = [data.first, "IGN_CDR"]
      end
    elsif key =~ /^\*$/
      if Array === data
        data = data.map { |elem| cutr(elem, rest) }
      elsif Hash === data
        data = data.inject({}) do |h,(k,v)| h[k] = cutr(v, rest); h end
      end
    else
      name = key

      if data[name] and not rest.empty?
        data[name] = cutr(data[name], rest)
      end
    end

    data
  end
end
