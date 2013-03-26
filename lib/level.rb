# -*- coding: utf-8 -*-

module Osakana
  class Level
    def self.from(exp)
      level = ExpTable.to_enum.each_with_index do |e, i|
        break i if e > exp
      end
      new level, exp
    end

    attr_reader :level, :exp

    def initialize(level, exp = nil)
      @level = level
      @exp = exp || ExpTable[level]
    end

    def add(exp)
      @exp += exp
    end

    def force
      self.class.from @exp
    end

    def to_i
      force.level.to_i
    end

    def to_s
      force.level.to_s
    end

    def method_missing(name, *args)
      force.level.__send__ name, *args
    end

    def respond_to_missing(name)
      force.level.respond_to_missing name
    end

    module ExpTable
      class << self
        def cache
          @cache ||= []
        end

        def [](index)
          cache[index] || cache[index] = threshold_at(index)
        end

        def threshold_at(n)
          (1..n).map(&method(:rate)).reduce(&:+)
        end

        def rate(n)
          n * Math.log(n * 100).to_i
        end

        def to_enum
          Enumerator.new do |y|
            i = 1
            loop do
              y << self[i]
              i += 1
            end
          end
        end
      end
    end
  end
end
