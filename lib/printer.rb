# frozen_string_literal: true

require 'forwardable'
require 'printer/csv'
require 'printer/table'

class Printer
  extend ::Forwardable

  attr_reader :writer

  def_delegator :@writer, :output

  def initialize(printer: :table, debug: true, silent: false)
    @debug = debug
    @silent = silent

    @writer = \
      case printer&.to_sym
      when :table then Table
      else; Csv
      end.new
  end

  def fatal(msg = nil, code: 1)
    msg ||= yield if block_given?
    warn msg
    exit code
  end

  def error(msg = nil)
    msg ||= yield if block_given?
    warn msg
  end

  def info(msg = nil)
    return if @silent

    msg ||= yield if block_given?
    warn msg
  end

  def debug(msg = nil)
    return unless @debug

    msg ||= yield if block_given?
    warn msg
  end
end
