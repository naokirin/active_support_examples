require 'active_support/concern'
require 'active_model'

module SavedValidation
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    # include ActiveModel::Validations
    # include ActiveModel::Callbacks
    # include ActiveModel::Conversion
    # include ActiveModel::Naming

    define_model_callbacks :save, only: :before
    before_save { throw(:abort) if invalid? }

    attr_reader :save_impl

    def persisted?
      valid?
    end

    def save
      run_callbacks :save do
        save_impl.call(self)
      end
    end
  end
end

class CustomModel
  include SavedValidation

  attr_accessor :id, :name

  validates :id, presence: true, numericality: { only_integer: true }
  validates :name, presence: true

  def initialize(&saver)
    @save_impl = saver
  end
end

obj = CustomModel.new do |data|
  # to_param: ActiveModel::Conversion
  # model_name: ActiveModel::Naming
  puts "Save: #{data.to_param} for #{data.model_name.name}"
end
obj.id = 1
obj.name = 'Bob'
obj.save # valid; call save_impl

obj.id = 'a'
obj.name = 'Alice'
obj.save # invalid; do not call save_impl

obj = CustomModel.new { |data| puts "Hello! #{data.name}" }
obj.id = 2
obj.name = 'John'
obj.save # valid; call save_impl with Hello!

