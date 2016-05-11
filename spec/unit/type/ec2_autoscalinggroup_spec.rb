require 'spec_helper'

def asg_config
  {
    name: 'test-asg',
    max_size: '3',
    desired_capacity: '2',
    min_size: '1',
    default_cooldown: '200',
    launch_configuration: 'test-lc',
    region: 'sa-east-1',
  }
end

type_class = Puppet::Type.type(:ec2_autoscalinggroup)

describe type_class do

  let :params do
    [
      :name,
    ]
  end

  let :properties do
    [
      :ensure,
      :min_size,
      :max_size,
      :desired_capacity,
      :default_cooldown,
      :region,
      :launch_configuration,
      :instance_count,
      :availability_zones,
      :subnets,
    ]
  end

  it 'should have expected properties' do
    properties.each do |property|
      expect(type_class.properties.map(&:name)).to be_include(property)
    end
  end

  it 'should have expected parameters' do
    params.each do |param|
      expect(type_class.parameters).to be_include(param)
    end
  end

  it 'should require a name' do
    expect {
      type_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  [
    'subnets',
    'availability_zones',
    'launch_configuration',
    'name',
    'region',
  ].each do |property|
    it "should require #{property} to be a string" do
      expect(type_class).to require_string_for(property)
    end
  end

  asg_config.keys.each do |key|
    it "should require a value for #{key}" do
      modified_config = asg_config
      modified_config[key] = ''
      expect {
        type_class.new(modified_config)
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with a full set of properties' do
    before :all do
      @instance = type_class.new(asg_config)
    end

    it 'should convert min size values to an integer' do
      expect(@instance[:min_size].kind_of?(Integer)).to be true
    end

    it 'should convert max size values to an integer' do
      expect(@instance[:max_size].kind_of?(Integer)).to be true
    end

    it 'should convert desired_capacity values to an integer' do
      expect(@instance[:desired_capacity].kind_of?(Integer)).to be true
    end

    it 'should convert default_cooldown values to an integer' do
      expect(@instance[:default_cooldown].kind_of?(Integer)).to be true
    end

  end

end
