require_relative 'spec_helper'

describe Common::Options do
  subject { Common::Options.new('spec/fixtures/example_config.yml') }

  it 'reads value' do
    expect( subject.plain_key ).to eq("plain_value")
  end

  it 'reads nested value' do
    expect( subject.nested['nested_key'] ).to eq("nested_value_default")
  end


end
