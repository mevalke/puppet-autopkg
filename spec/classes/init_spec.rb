require 'spec_helper'
describe 'autopkg' do
  context 'with default values for all parameters' do
    it { should contain_class('autopkg') }
  end
end
