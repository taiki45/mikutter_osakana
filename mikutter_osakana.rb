# -*- coding: utf-8 -*-
require 'pry'

module Memoize
  def memoize(*names)
    names.each do |name|
      target = instance_method(name)
      wrapped = lambda do |arg|
        @_cache_ ||= {}
        @_cache_[name] ||= {}
        @_cache_[name][arg] || @_cache_[name][arg] = target.bind(self).call(arg)
      end
      define_method name, &wrapped
    end
  end
end

class Account
  def initialize
    load_status
  end

  def load_status
    @level = Level.new(exp)
  end

  def increase(event)
    __send__('on_' + event.to_s)
  end

  def on_post
  end

  class Level
    extend Momeize

    def initialize(exp)
      @exp = exp
      @level
    end

    def add(exp)
    end

    def next_threshold(next_level = self.next)
      (1..next_level).map {|n| n * Math.log(n * 100).to_i }.reduce(&:+)
    end

    memoize :next_threshold

    def to_i
    end

    def to_s
    end

    def method_missing(name, *args)
      @level.__send__(name, *args)
    end

    def respond_to_missing(name)
      @level.respond_to_missing(name)
    end
  end
end

Plugin.create :mikutter_osakana do
  aa = open(File.expand_path('../aa.text', __FILE__)).read.chomp
  account = Account.new

  command(
    :osakana_tweet,
    name: 'おさかなといっしょにつぶやく',
    condition: Plugin::Command[:Editable],
    visible: false,
    role: :postbox
  ) do |opt|
    buff = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer
    buff.text = aa + buff.text
    opt.widget.post_it!
  end

  filter_gui_postbox_post do |box|
    buff = Plugin.create(:gtk).widgetof(box).widget_post.buffer
    if buff.text =~ Regexp.new(Regexp.escape(aa))
      account.increase :post
    end
  end
end
