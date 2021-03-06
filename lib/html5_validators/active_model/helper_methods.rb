# frozen_string_literal: true

module Html5Validators
  module DafaultValidationContext
    if defined?(::ActiveRecord::Base) && (::ActiveRecord::VERSION::MAJOR < 5)
      refine ::ActiveRecord::Base do
        def default_validation_context
          new_record? ? :create : :update
        end
      end
    end
    refine Object do
      def default_validation_context
        nil
      end
    end
  end
end

using Html5Validators::DafaultValidationContext

module ActiveModel
  module Validations
    module HelperMethods
      def attribute_required?(attribute)
        self.class.validators.grep(PresenceValidator).any? do |v|
          if v.attributes.include?(attribute.to_sym) && (v.options.keys & [:if, :unless]).empty?
            !(on = v.options[:on]) || Array(on).include?(default_validation_context)
          end
        end
      end

      def attribute_maxlength(attribute)
        self.class.validators.grep(LengthValidator).select {|v|
          if v.attributes.include?(attribute.to_sym) && (v.options.keys & [:maximum, :is]).any? && (v.options.keys & [:if, :unless, :tokenizer]).empty?
            !(on = v.options[:on]) || Array(on).include?(default_validation_context)
          end
        }.map {|v| v.options.slice(:maximum, :is)}.map(&:values).flatten.max
      end

      def attribute_minlength(attribute)
        self.class.validators.grep(LengthValidator).select {|v|
          if v.attributes.include?(attribute.to_sym) && (v.options.keys & [:minimum, :is]).any? && (v.options.keys & [:if, :unless, :allow_nil, :allow_blank, :tokenizer]).empty?
            !(on = v.options[:on]) || Array(on).include?(default_validation_context)
          end
        }.map {|v| v.options.slice(:minimum, :is)}.map(&:values).flatten.min
      end

      def attribute_max(attribute)
        self.class.validators.grep(NumericalityValidator).select {|v|
          if v.attributes.include?(attribute.to_sym) && (v.options.keys & [:less_than, :less_than_or_equal_to]).any? && (v.options.keys & [:if, :unless, :allow_nil, :allow_blank]).empty?
            !(on = v.options[:on]) || Array(on).include?(default_validation_context)
          end
        }.map {|v| v.options.slice(:less_than, :less_than_or_equal_to)}.map(&:values).flatten.max
      end

      def attribute_min(attribute)
        self.class.validators.grep(NumericalityValidator).select {|v|
          if v.attributes.include?(attribute.to_sym) && (v.options.keys & [:greater_than, :greater_than_or_equal_to]).any? && (v.options.keys & [:if, :unless, :allow_nil, :allow_blank]).empty?
            !(on = v.options[:on]) || Array(on).include?(default_validation_context)
          end
        }.map {|v| v.options.slice(:greater_than, :greater_than_or_equal_to)}.map(&:values).flatten.min
      end
    end
  end
end
