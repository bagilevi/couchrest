# Extracted from dm-validations 0.9.10
#
# Copyright (c) 2007 Guy van den Berg
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module CouchRest
  module Validation

    ##
    #
    # @author Pedro Visintin
    # @since  0.9
    class UniquenessValidator < GenericValidator

      def initialize(field_name, options={})
        super
        @field_name, @options = field_name, options
        @case_sensitive = true
        @case_sensitive = options[:case_sensitive] if options.has_key?(:case_sensitive)
      end

      def call(target)
        
        value = target.validation_property_value(field_name)
        property = target.validation_property(field_name)

        if @case_sensitive
          results = target.class.send("by_#{field_name}",{:key => "#{value}" })
        else
          results = target.class.send("by_#{field_name}",{:startkey => "#{value}".downcase, :endkey => "#{value}".upcase })
        end

        # no records found
        return true if results.length == 0

        # may be the same record updated
        return true if results.length == 1 && !target.new_document? && results.first['_id'] == target['_id']

        error_message = @options[:message] || default_error(property)
        add_error(target, error_message, field_name)

        false
      end

      protected

      def default_error(property)
        ValidationErrors.default_error_message(:exists, field_name)
      end

    end # class UniquenessValidator

    module ValidatesIsUnique

      ##
      # Validates that the specified attribute is unique for that kind of doc.
      #
      # For most property types "being present" is the same as being "not
      # blank" as determined by the attribute's #blank? method. However, in
      # the case of Boolean, "being present" means not nil; i.e. true or
      # false.
      #
      # @example [Usage]
      #
      #   class Page
      #
      #     property :unique_attribute, String
      #     property :another_unique, String
      #     property :yet_again, String
      #
      #     validates_uniqueness :unique_attribute
      #     validates_uniqueness :another_required, :yet_again
      #
      #     # a call to valid? will return false unless
      #     # all three attributes are unique
      #   end
      def validates_is_unique(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, CouchRest::Validation::UniquenessValidator)
      end

    end # module ValidatesIsUnique
  end # module Validation
end # module CouchRest
