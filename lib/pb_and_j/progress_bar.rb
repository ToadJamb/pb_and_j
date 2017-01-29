# frozen_string_literal: true
module PBAndJ
  class ProgressBar
    attr_reader(*[
      :start_at,
      :description,
      :count,
      :index,
      :padding,
      :width,
    ])

    def initialize(desc, count, pad: 0, width: 80, show: true, stream: STDOUT)
      @description = desc    || ''
      @count       = count   || 0
      @padding     = pad     || 0
      @width       = width   || 80
      @stream      = stream  || STDOUT
      @show        = !!show
      @index       = 0
      @message     = ''

      raise "Count must be greater than 0" if @count < 1
    end

    def start(now = Time.now)
      @start_at = now
      @index = 0
      reset now
      print
    end

    def tick(index = nil, finish = nil)
      start unless defined?(@start_at) && @start_at
      reset
      @index  = index || @index + 1
      @finish = finish if finish
      print
    end

    def stop(now = Time.now)
      reset now
      print
      stream.puts if show?
    end

    def show?
      @show
    end

    def message
      @message ||= label + marks + suffix
    end

    private

    def stream
      @stream
    end

    def reset(now = Time.now)
      @finished = now
      @finish   = nil
      @message  = nil
      @suffix   = nil
    end

    def print
      stream.print "\r" + message if show?
    end

    def label
      @label ||= "#{description.ljust(padding)}: #{formatted_start} "
    end

    def formatted_start
      @formatted_start ||= start_at.strftime '%H:%M:%S'
    end

    def finish(current = @finished)
      return @finish if @finish

      time = current - start_at
      return @finish = current if time < 0.001
      avg = time / @index.to_f

      @finish = start_at + @count * avg
    end

    def marks
      mark = @index <= @count ? '=' : '>'
      progress = '|' + mark * current_marks

      if @index < @count
        progress += '>' + ' ' * (max_length - current_marks - 1)
      end

      progress += '|'
    end

    def max_length
      return nil unless @width
      return @max_length if defined?(@max_length)
      @max_length ||= width - label.length - suffix.length - 2
    end

    def current_marks
      (max_length * percentage).to_i
    end

    def percentage
      [@index / @count.to_f, 1].min
    end

    def suffix
      @suffix ||=
        " #{formatted_finish}" +
        " #{humanize_seconds(finish - start_at)} #{humanize_duration}"
    end

    def formatted_finish
      finish.strftime '%H:%M:%S'
    end

    def humanize_duration
      humanize_seconds @finished - start_at
    end

    def humanize_seconds(seconds)
      ServingSeconds.humanize(seconds, 1).rjust 5
    end
  end
end
