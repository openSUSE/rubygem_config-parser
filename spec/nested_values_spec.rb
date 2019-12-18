require_relative 'spec_helper'

describe Common::Options do
  subject { Common::Options.new('spec/fixtures/example_config.yml', nil, 'test') }

  it 'reads nested value' do
    expect( subject.nested['nested_key']).to eq("nested_value_default")
  end

  it 'reads nested value for env' do
    expect( subject.nested_env['nested_key']).to eq("nested_value_test")
  end

  it 'keeps default for not overwritten parts of nested set' do
    expect(subject.nested_env['nested_key2']).to eq("nested_value_env2")
  end

end
