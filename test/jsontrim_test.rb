require 'test_helper'

class JsontrimTest < Test::Unit::TestCase
  def assert_equal_ws(expected, actual)
    expected = expected.gsub(/\s/, "")
    actual = actual.gsub(/\s/,"")
    assert_equal expected, actual
  end

  should "pass json through unchanged" do
    assert_equal %Q({\n  "foo": "bar"\n}),
                 JSONTrim.cut(%q({"foo": "bar"}))
  end

  should "ignore" do
    assert_equal({"a" => 3, "b" => "IGN" },
                 JSONTrim.cutr({ "a" => 3, "b" => 4 } , ["!b"]))
    assert_equal({"a" => 3, "b" => "IGN_HSH" },
                 JSONTrim.cutr({ "a" => 3, "b" => { "c" => 4 }} , ["!b"]))
    assert_equal({"a" => 3, "b" => "IGN_ARY" },
                 JSONTrim.cutr({ "a" => 3, "b" => [ 4 ] } , ["!b"]))
  end

  should "distinguish between arrays and hashes" do
    assert_equal %Q({\n  "foo": { ... }\n}),
                 JSONTrim.cut(%q({"foo" : { "bar": "fred"}}),  :ignore => ["!foo"])
    assert_equal %Q({\n  "foo": [ ... ]\n}),
                 JSONTrim.cut(%q({"foo" : [ "bar", "fred"]}),  :ignore => ["!foo"])
    assert_equal %Q({\n  "foo": ...\n}),
                 JSONTrim.cut(%q({"foo" : 3}),  :ignore => ["!foo"])
  end

  should "work for nested attributes" do
    assert_equal %Q({\n  "foo": {\n    "bar": { ... }\n  }\n}),
                 JSONTrim.cut(%q({"foo" : { "bar": {"f":3}}}), :ignore => ["foo:!bar"])

    assert_equal %Q({\n  "foo": {\n    "bar": ...\n  }\n}),
                JSONTrim.cut(%q({"foo" : { "bar": 3}}), :ignore => ["foo:!bar"])
  end

  should "not alter json if ignored thing does not exist" do
    assert_equal %Q({\n  "foo": { ... }\n}),
                 JSONTrim.cut(%q({"foo" : { "bar": "fred"}}),
                   :ignore => ["!foo", "!doesnotexist", "foo:!doesnotexist"])
  end

  should "allow ignoring of subelements of arrays" do
    assert_equal_ws %Q({"foo":[{"bar": { ... }},{"bar": ...}]}),
                 JSONTrim.cut(%q({"foo" : [{ "bar": {"baz":3}}, {"bar":3}]}), :ignore => ["foo:*:!bar"])
  end

  should "allow ignoring of arrays" do
    assert_equal %Q({\n  "foo": [\n    "bar",\n    ...\n  ]\n}),
                 JSONTrim.cut(%q({"foo": ["bar", "baz", "fred"]}),
                   :ignore => ["foo:+"])
  end

  should "pass a complex testcase" do
    before = <<-EOF
     { "foo": {
          "one": { "a": 1, "b": {"c": 2} },
          "two": "value",
          "three": { "b": [1,2,3] }},
       "bar": [1,2,3,4,5] }
     EOF

     blacklist = [
       "foo:!two",
       "foo:*:!b",
       "bar:+"
     ]

     expected = <<-EOF
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
EOF

     actual = JSONTrim.cut(before, :ignore => blacklist)
     assert_equal expected.chomp, actual
  end
end