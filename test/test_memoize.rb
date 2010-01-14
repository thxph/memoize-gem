require 'helper'

class MemoizeTest < Test::Unit::TestCase
  class TestClass
    include Memoize
    attr_accessor :exp
    class << self
      attr_accessor :class_exp
    end
    def self.sum *args
      self.class_exp = true
      args.inject { |a, e| a + e }.to_s
    end
    def self.hash *args
      self.class_exp = true
      args.inject { |a, e| a + e }.to_s
    end
    def prod *args
      self.exp = true
      args.inject { |a, e| a * e }.to_s
    end
    def self.hashaaa args
      self.class_exp = true
      args[:xxxx] = 123
      args[:xx] = 123
      return (args[:a] + args[:b]).to_s
    end
  end

  should "work with class method" do
    # normal memoization
    TestClass.enable_memoization :sum
    TestClass.class_exp = false
    assert_equal "10", TestClass.sum(1, 2, 3, 4)
    assert_equal true, TestClass.class_exp
    TestClass.class_exp = false
    assert_equal "10", TestClass.sum(1, 2, 3, 4)
    assert_equal false, TestClass.class_exp
    assert_equal "15", TestClass.sum(1, 2, 3, 4, 5)
    assert_equal true, TestClass.class_exp
    # reset memoization
    TestClass.class_exp = false
    assert_equal "15", TestClass.sum(1, 2, 3, 4, 5)
    assert_equal false, TestClass.class_exp
    TestClass.reset_memoization :sum
    assert_equal "15", TestClass.sum(1, 2, 3, 4, 5)
    assert_equal true, TestClass.class_exp
    # disable memoization
    TestClass.disable_memoization :sum
    TestClass.class_exp = false
    assert_equal "15", TestClass.sum(1, 2, 3, 4, 5)
    assert_equal true, TestClass.class_exp
    TestClass.class_exp = false
    assert_equal "15", TestClass.sum(1, 2, 3, 4, 5)
    assert_equal true, TestClass.class_exp
  end

  should "work with instance method" do
    @test_obj = TestClass.new
    # normal memoization
    TestClass.enable_memoization :prod
    @test_obj.exp = false
    assert_equal "24", @test_obj.prod(1, 2, 3, 4)
    assert_equal true, @test_obj.exp
    @test_obj.exp = false
    assert_equal "24", @test_obj.prod(1, 2, 3, 4)
    assert_equal false, @test_obj.exp
    assert_equal "120", @test_obj.prod(1, 2, 3, 4, 5)
    assert_equal true, @test_obj.exp
    # reset memoization
    @test_obj.exp = false
    assert_equal "120", @test_obj.prod(1, 2, 3, 4, 5)
    assert_equal false, @test_obj.exp
    TestClass.reset_memoization :prod
    assert_equal "120", @test_obj.prod(1, 2, 3, 4, 5)
    assert_equal true, @test_obj.exp
    # disable memoization
    TestClass.disable_memoization :prod
    @test_obj.exp = false
    assert_equal "120", @test_obj.prod(1, 2, 3, 4, 5)
    assert_equal true, @test_obj.exp
    @test_obj.exp = false
    assert_equal "120", @test_obj.prod(1, 2, 3, 4, 5)
    assert_equal true, @test_obj.exp
  end

  should "work with mutable parameter" do
    # normal memoization
    TestClass.enable_memoization :hashaaa
    TestClass.class_exp = false
    assert_equal "10", TestClass.hashaaa({ :a => 3, :b => 7 })
    assert_equal true, TestClass.class_exp
    TestClass.class_exp = false
    assert_equal "10", TestClass.hashaaa({ :a => 3, :b => 7 })
    assert_equal false, TestClass.class_exp
    assert_equal "15", TestClass.hashaaa({ :a => 8, :b => 7 })
    assert_equal true, TestClass.class_exp
    # reset memoization
    TestClass.class_exp = false
    assert_equal "15", TestClass.hashaaa({ :a => 8, :b => 7 })
    assert_equal false, TestClass.class_exp
    TestClass.reset_memoization :hashaaa
    assert_equal "15", TestClass.hashaaa({ :a => 8, :b => 7 })
    assert_equal true, TestClass.class_exp
    # disable memoization
    TestClass.disable_memoization :hashaaa
    TestClass.class_exp = false
    assert_equal "15", TestClass.hashaaa({ :a => 8, :b => 7 })
    assert_equal true, TestClass.class_exp
    TestClass.class_exp = false
    assert_equal "15", TestClass.hashaaa({ :a => 8, :b => 7 })
    assert_equal true, TestClass.class_exp
  end

end

