require 'rails_helper'

RSpec.describe OrdenFumigacion, type: :model do
  it { should belong_to(:cultivo).optional }
end
