# Shared_Examples
shared_examples_for "contents_match" do |parameter|
  its(:content) { should match /#{parameter}/ }
end

shared_examples_for "contents_not_match" do |parameter|
  its(:content) { should_not match /#{parameter}/ }
end
