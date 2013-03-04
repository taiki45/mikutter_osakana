# -*- coding: utf-8 -*-

module Osakana
  class Account
    attr_reader :level

    def initialize
      @level = load_status
    end

    def load_status
      exp = open(save_file).read.chomp.to_i
      Level.from(exp)
    end

    def save
      open(save_file, 'w') {|f| f.write @level.exp }
    end

    def save_file
      dst = File.expand_path('../../exp', __FILE__)
      open(dst, 'w') {|f| f.write '0' } unless File.exist? dst
      dst
    end

    def exp
      level.exp
    end

    def increase(event)
      __send__('on_' + event.to_s)
    end

    def on_post
      @level.add rand(100..300)
    end

    def on_fav
      @level.add rand(10..50)
    end

    def on_faved
      @level.add 10
    end

    def on_apper
      @level.add 1
    end
  end
end
