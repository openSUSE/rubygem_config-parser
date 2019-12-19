require_relative 'spec_helper'

describe Common::Options do
  subject { Common::Options.new('spec/fixtures/example_config.yml', 'spec/fixtures/example_config_local.yml', 'test') }

  it 'reads default value' do
    expect( subject.mixed_key ).to eq("mixed_value")
  end

  it 'reads local value' do
    expect( subject.plain_key ).to eq("plain_value_local")
  end

  it 'reads local nested value' do
    expect( subject.nested['nested_key'] ).to eq("nested_value_local")
  end

  it 'reads nested value for local env' do
    expect( subject.nested_env['nested_key']).to eq("nested_value_test_local")
  end

  it 'keeps default for not overwritten parts of nested set' do
    expect(subject.nested_env['nested_key2']).to eq("nested_value_env2")
  end

end
