# -*- coding: utf-8 -*-
require 'pry'

class Account
  attr_reader :level

  def initialize
    @level = load_status
  end

  def load_status
    exp = open(save_file).read.chomp.to_i
    LazyLevel.from(exp)
  end

  def save
    open(save_file, 'w') {|f| f.write @level.exp }
  end

  def save_file
    dst = File.expand_path('../exp', __FILE__)
    open(dst, 'w') {|f| f.write '0' } unless File.exist? dst
    dst
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

  class LazyLevel
    class << self
      def from(exp)
        level = thresholds.each_with_index do |e, i|
          break i if e > exp
        end
        new(level, exp)
      end

      def thresholds
        i = 1
        Enumerator.new do |y|
          loop do
            y << (1..i).map {|n| rate(n) }.reduce(:+)
            i += 1
          end
        end
      end

      def rate(n)
        n * Math.log(n * 100).to_i
      end
    end

    attr_reader :level, :exp

    def initialize(level, exp = nil)
      @level = level
      @exp = exp || thresholds.take(level).last
    end

    def thresholds
      self.class.thresholds
    end

    def add(exp)
      @exp += exp
    end

    def force
      self.class.from(@exp).level
    end

    def to_i
      force
    end

    def to_s
      force.to_s
    end

    def method_missing(name, *args)
      force.level.__send__(name, *args)
    end

    def respond_to_missing(name)
      force.level.respond_to_missing(name)
    end
  end
end

Plugin.create :mikutter_osakana do
  aa = open(File.expand_path('../aa.text', __FILE__)).read.chomp
  pattern = Regexp.new(Regexp.escape(aa))
  me = Account.new

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
    me.increase :post if buff.text =~ pattern
    [box]
  end

  on_favorite do |service, user, msg|
    me.increase :fav if msg.to_s =~ pattern
    [service, user, msg]
  end

  on_update do |service, msgs|
    msgs.each do |msg|
      me.increase :apper if msg.to_s =~ pattern
    end
    [service, msgs]
  end

  on_period do
    me.save
  end
end
