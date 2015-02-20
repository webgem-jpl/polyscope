require 'rails_helper'
describe Polyscope::Edge do
  describe 'instantiation' do
    it 'raise error' do
      expect { Polyscope::Edge.create! }.to raise_error
    end
  end
end
