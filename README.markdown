# jsontrim

takes a JSON object, removes specified subtrees and trims arrays
returns a pretty printed string

## usage

    require 'jsontrim'

    before = <<-EOF
    { "foo": {
        "one": { "a": 1, "b": {"c": 2} },
        "two": "value",
        "three": { "b": [1,2,3] }},
      "bar": [1,2,3,4,5] }
    EOF

    blacklist = [
      "foo:!two",   # delete the value before['foo']['two']
      "foo:*:!b",   # delete all the keys called "b" nested two levels under "foo"
      "bar:+"       # only keep the first element of the foo-list
    ]

    after = JSONTrim.cut(before, :ignore => blacklist)

    {
      "foo": {
        "two": ...,
        "three": {
           "b": [ ... ]
        },
        "one": {
          "a": 1,
          "b": { ... }
        }
      },
      "bar": [
        1,
        ...
      ]
    }

