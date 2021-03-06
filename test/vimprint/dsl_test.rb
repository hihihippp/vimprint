gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/vimprint/dsl'

module Vimprint

  describe HashFromBlock do

    def values
      proc do
        one 1
        two 2
        nested do
          three 3
        end
      end
    end

    it '.new returns a HashFromBlock object' do
      builder = HashFromBlock.new &values
      assert_equal HashFromBlock, builder.class
      assert_equal({one: 1, two: 2, nested: {three: 3}}, builder.hash)
    end

    it 'can add new items' do
      builder = HashFromBlock.new { one 1 }
      builder.two 2
      assert_equal({one: 1, two: 2}, builder.hash)
    end

    it '.build returns a hash object' do
      hash = HashFromBlock.build &values
      assert_equal({one: 1, two: 2, nested: {three: 3}}, hash)
    end

  end

  describe Config do

    def config
      Config.new do
        trigger 'h'
        explain {
          template 'move left {{number}}'
          number {
            singular "1 character"
            plural '#{count} characters'
          }
        }
      end
    end

    it '#signature accesses the trigger' do
      assert_equal({trigger: "h"}, config.signature)
    end

    it '#template accesses the template' do
      assert_equal('move left {{number}}', config.template)
    end

    it '#projected_templates gets singular+plural templates' do
      templates = {
        :singular => "move left 1 character",
        :plural => 'move left #{count} characters',
      }
      assert_equal(templates, config.projected_templates)
    end

  end

  describe 'Dsl.parse' do

    before do
      Dsl.parse do
        motion {
          trigger 'h'
          explain {
            template 'move left {{number}}'
            number {
              singular "1 character"
              plural '#{count} characters'
            }
          }
        }
      end
    end

    def normal_mode
      Registry.get_mode("normal")
    end

    it 'motion block generates a singular explanation' do
      h_once = normal_mode.get_command({trigger: 'h', number: 'singular'})
      assert_equal Explanation, h_once.class
      assert_equal "move left 1 character", h_once.template
    end

    it 'motion block generates a plural explanation' do
      h_multiple = normal_mode.get_command({trigger: 'h', number: 'plural'})
      assert_equal Explanation, h_multiple.class
      assert_equal 'move left #{count} characters', h_multiple.template
    end

  end

end
