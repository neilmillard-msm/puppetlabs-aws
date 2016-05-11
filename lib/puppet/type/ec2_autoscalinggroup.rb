require_relative '../../puppet_x/puppetlabs/property/tag.rb'

Puppet::Type.newtype(:ec2_autoscalinggroup) do
  @doc = 'Type representing an EC2 auto scaling group.'

  ensurable

  validate do
    fail "desired_capacity must be greater than or equal to min_size and less than or equal to max_size" unless self[:desired_capacity].nil? || self[:min_size] <= self[:desired_capacity] || self[:desired_capacity] <= self[:max_size]
  end

  newparam(:name, namevar: true) do
    desc 'The name of the auto scaling group.'
    validate do |value|
      fail 'Auto scaling groups must have a name' if value == ''
      fail 'name should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:min_size) do
    desc 'The minimum number of instances in the group.'
    validate do |value|
      fail 'min_size cannot be blank' if value == ''
    end
    munge do |value|
      value.to_i
    end
  end

  newproperty(:max_size) do
    desc 'The maximum number of instances in the group.'
    validate do |value|
      fail 'min_size cannot be blank' if value == ''
    end
    munge do |value|
      value.to_i
    end
  end

  newproperty(:desired_capacity) do
    desc 'The number of EC2 instances that should be running in the group. This number must be greater than or equal to the minimum size of the group (min_size) and less than or equal to the maximum size of the group (max_size).'
    validate do |value|
      fail 'desired_capacity cannot be blank' if value == ''
    end
    munge do |value|
      value.to_i
    end
  end

  newproperty(:default_cooldown) do
    desc 'The amount of time, in seconds, after a scaling activity completes before another scaling activity can start.'

    defaultto '300'

    validate do |value|
      fail 'default_cooldown cannot be blank' if value == ''
    end
    munge do |value|
      value.to_i
    end
  end

  newproperty(:region) do
    desc 'The region in which to launch the instances.'
    validate do |value|
      fail 'region should not contain spaces' if value =~ /\s/
      fail 'region should not be blank' if value == ''
      fail 'region should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:launch_configuration) do
    desc 'The launch configuration to use for the group.'
    validate do |value|
      fail 'launch_configuration cannot be blank' if value == ''
      fail 'launch_configuration should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:instance_count) do
    desc 'The number of instances currently running.'
    validate do |value|
      fail 'instance_count is read only'
    end
  end

  newproperty(:availability_zones, :array_matching => :all) do
    desc 'The availability zones in which to launch the instances.'
    validate do |value|
      fail 'availability_zones should be a String' unless value.is_a?(String)
    end
    def insync?(is)
      is.to_set == should.to_set
    end
  end

  newproperty(:subnets, :array_matching => :all) do
    desc 'The subnets to associate the autoscaling group.'
    validate do |value|
      fail 'subnets should be a String' unless value.is_a?(String)
    end
    def insync?(is)
      is.to_set == should.to_set
    end
  end

  newproperty(:tags, :parent => PuppetX::Property::AwsTag) do
    desc 'The tags for the autoscaling group.'
  end

  autorequire(:ec2_launchconfiguration) do
    self[:launch_configuration]
  end

  autorequire(:ec2_vpc_subnet) do
    subnets = self[:subnets]
    subnets.is_a?(Array) ? subnets : [subnets]
  end
end
