# frozen_string_literal: true
RSpec.describe PBAndJ::ProgressBar do
  subject { instance }

  let(:instance) { described_class.new(*args) }

  let(:args) {[
    label,
    count,
    :pad    => pad,
    :width  => width,
    :show   => show,
    :stream => stream,
  ]}

  let(:label) { 'foo' }
  let(:count) { 10 }

  let(:stream) { StringIO.new }
  let(:out)    { stream.string }
  let(:show)   { false }
  let(:pad)    { nil }
  let(:width)  { 80 }

  let(:mins)  { 60 }
  let(:hours) { 60 * mins }
  let(:days)  { 24 * hours }

  start = Time.new(2017, 1, 3, 8, 5, 2)

  describe '.new' do
    shared_examples '.new' do
        |args, desc, count, padding, width, show, start_at|
      context "given arguments: #{args.inspect}" do
        subject { described_class.new(*args) }

        describe '.description' do
          it "returns #{desc.inspect}" do
            expect(subject.description).to eq desc
          end
        end

        describe '.count' do
          it "returns #{count.inspect}" do
            expect(subject.count).to eq count
          end
        end

        describe '.index' do
          it 'returns 0' do
            expect(subject.index).to eq 0
          end
        end

        describe '.padding' do
          it "returns #{padding.inspect}" do
            expect(subject.padding).to eq padding
          end
        end

        describe '.width' do
          it "returns #{width.inspect}" do
            expect(subject.width).to eq width
          end
        end

        describe '.start_at' do
          it "returns #{start_at.inspect}" do
            expect(subject.start_at).to eq start_at
          end
        end

        describe '.show' do
          it "returns #{show.inspect}" do
            expect(subject.show?).to eq show
          end
        end
      end
    end

    # desc, count, padding, width, start_at
    it_behaves_like '.new', ['foo',  7], 'foo', 7, 0, 80, true
    it_behaves_like '.new', ['foo',  7, :show => false], 'foo', 7, 0, 80, false

    it_behaves_like '.new', ['foo',  8, :pad => 5], 'foo',  8, 5, 80, true
    it_behaves_like '.new', ['fizz', 9, :pad => 6], 'fizz', 9, 6, 80, true

    it_behaves_like '.new', ['fizz', 6, :pad => 4, :width => 70],
      'fizz', 6, 4, 70, true

    it_behaves_like '.new', [nil, 1, :pad => nil, :width => nil],
      '', 1, 0, 80, true

    it_behaves_like '.new', [nil, 1], '', 1, 0, 80, true
  end

  describe '#start' do
    context 'given a time is specified' do
      context 'given the first call' do
        before { expect(subject.start_at).to eq nil }

        before { subject.start start }

        it 'sets start_at to the time' do
          expect(subject.start_at).to be_within(1).of start
        end
      end
    end

    context 'given a time is not specified' do
      before { subject.start }

      it 'sets start_at to the current time' do
        expect(subject.start_at).to be_within(1).of Time.now
      end
    end

    context 'given display is enabled' do
      let(:show) { true }

      before { subject.start start }

      it 'sends the initial display to stdout' do
        expect(out).to match(/^\rfoo.*08:05:02/)
      end
    end

    context 'given display is not enabled' do
      before { expect(subject.show?).to eq false }

      before { subject.start }

      it 'sends nothing to stdout' do
        expect(out).to eq ''
      end
    end
  end

  # much of the testing of the real logic of tick is handled in #message
  describe '#tick' do
    context 'given the index is not passed in' do
      before { expect(subject.index).to eq 0 }
      before { subject.start start }
      before { subject.tick }

      it 'increments the counter' do
        expect(subject.index).to eq 1
      end
    end

    context 'given start has not been invoked' do
      before { expect(subject.start_at).to eq nil }
      before { subject.tick }

      it 'invokes start (as indicated by start_at getting set)' do
        expect(subject.start_at).to be_within(1).of Time.now
      end
    end

    context 'given an expected finish time is specified' do
      let(:finish) { start + (1 * hours) }

      before { subject.start start }
      before { subject.tick nil, finish }

      it 'uses that time as the expected finish time' do
        expect(subject.message).to match(/09:05:02  1.0h/)
      end
    end

    context 'given display is enabled' do
      let(:show) { true }

      before { subject.tick }

      it 'sends the message to the stream' do
        expect(out).to match(/\|====>/)
      end
    end

    context 'given display is not enabled' do
      let(:show) { false }

      before { subject.tick }

      it 'does not send anything to the stream' do
        expect(out).to eq ''
      end
    end

    context 'given multiple ticks' do
      before { allow(Time).to receive(:now).and_return start + 1 }
      before { subject.tick }
      # the next line ensures all instance variables are set
      before { subject.message }
      before { allow(Time).to receive(:now).and_return start + (1 * hours) }
      before { subject.tick count - 1 }

      it 'updates the progress bar' do
        expect(subject.message).to match(/09:11:41  1.1h  1.0h/)
      end
    end
  end

  describe '#message' do
    shared_context 'message' do |secs, ttl, index, pad, width, label, expected|

      context "given the start was #{start.strftime('%H:%M:%S')}" do
        before { subject.start start }

        context "given the time is #{(start + secs).strftime('%H:%M:%S')}" do
          let(:time_now) { start + secs }

          before { allow(Time).to receive(:now).and_return time_now }

          context "given the total is #{ttl}" do
            let(:count) { ttl }

            context "given the index is #{index}" do
              before { subject.tick index }

              context "given the padding is #{pad}" do
                let(:pad) { pad }

                context "given the width is #{width}" do
                  let(:width) { width }

                  context "given the label is #{label}" do
                    let(:label) { label }

                    it "returns #{expected.inspect}" do
                      expect(subject.message).to eq expected
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    #                         sec,ttl,idx,pad,wid,lbl,expected
    it_behaves_like 'message', 61, 10, 05, 05, 70, 'foo',
      'foo  : 08:05:02 |===============>               | 08:07:04  2.0m  1.0m'
    it_behaves_like 'message', 61, 10, 05, 05, 60, 'foo',
      'foo  : 08:05:02 |==========>          | 08:07:04  2.0m  1.0m'
    it_behaves_like 'message', 61, 10, 05, 05, 50, 'foob',
      'foob : 08:05:02 |=====>     | 08:07:04  2.0m  1.0m'
    it_behaves_like 'message', 31, 10, 05, 00, 50, 'foob',
      'foob: 08:05:02 |======>     | 08:06:04  1.0m 31.0s'
    it_behaves_like 'message', 31, 10,  9, 05, 50, 'foo',
      'foo  : 08:05:02 |=========> | 08:05:36 34.4s 31.0s'
    it_behaves_like 'message', 31,100, 99, 05, 50, 'foo',
      'foo  : 08:05:02 |==========>| 08:05:33 31.3s 31.0s'
    it_behaves_like 'message', 31,100,100, 05, 50, 'foo',
      'foo  : 08:05:02 |===========| 08:05:33 31.0s 31.0s'
    it_behaves_like 'message', 31, 10,  1, 05, 50, 'foo',
      'foo  : 08:05:02 |=>         | 08:10:12  5.2m 31.0s'
    it_behaves_like 'message', 31, 10, nil, 05, 50, 'foo',
      'foo  : 08:05:02 |=>         | 08:10:12  5.2m 31.0s'
    it_behaves_like 'message', 31,100,  1, 05, 50, 'foo',
      'foo  : 08:05:02 |>          | 08:56:42 51.7m 31.0s'

    it_behaves_like 'message', 31, 100_000, 99_999, 05, 50, 'foo',
      'foo  : 08:05:02 |==========>| 08:05:33 31.0s 31.0s'

    it_behaves_like 'message', 31, 10, 11, 05, 50, 'foo',
      'foo  : 08:05:02 |>>>>>>>>>>>| 08:05:30 28.2s 31.0s'

    context 'given nothing has been invoked' do
      it 'returns an empty string' do
        expect(subject.message).to eq ''
      end
    end

    context 'given only start has been invoked' do
      before { subject.start start }

      let(:pad) { 5 }

      let(:expected) { "foo  : 08:05:02 |>#{' ' * 40}| 08:05:02  0.0s  0.0s" }

      it 'returns the initial structure' do
        expect(expected.length).to eq 80
        expect(subject.message.length).to eq 80
        expect(subject.message).to eq expected
      end
    end
  end

  describe '#stop' do
    before { subject.start start }
    before { subject.tick }
    before { subject.message }
    before { subject.tick count - 1, start + 1 }
    before { subject.stop start + (1 * hours) }

    it 'updates the message' do
      expect(subject.message).to match(/09:11:42  1.1h  1.0h/)
    end

    context 'given display is disabled' do
      let(:show) { false }

      it 'prints nothing' do
        expect(out).to eq ''
      end
    end

    context 'given display is enabled' do
      let(:show) { true }

      it 'prints a line return' do
        expect(out[-1]).to eq "\n"
      end

      it 'prints the updated message' do
        expect(out).to match(/09:11:42  1.1h  1.0h/)
      end
    end
  end
end
