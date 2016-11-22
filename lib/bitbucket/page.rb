module Bitbucket
  class Page
    attr_reader :attrs, :items

    def initialize(raw, type)
      @attrs = parse_attrs(raw)
      @items = parse_values(raw, representation_class(type))
    end

    def next?
      attrs.fetch(:next, false)
    end

    def next
      attrs.fetch(:next)
    end

    private

    def parse_attrs(raw)
      attrs = %w(size page pagelen next previous)
      attrs.map { |attr| { attr.to_sym => raw[attr] } }.reduce(&:merge)
    end

    def parse_values(raw, bitbucket_rep_class)
      return [] unless raw['values'] && raw['values'].is_a?(Array)

      raw['values'].map { |hash| bitbucket_rep_class.new(hash) }
    end

    def representation_class(type)
      Bitbucket::Representation.const_get(type.to_s.camelize)
    end
  end
end
