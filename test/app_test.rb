require File.expand_path("test_helper", File.dirname(__FILE__))
require 'fileutils'

class AppTest < Test::Unit::TestCase
  def setup
    Dir.mkdir TMP_DIR unless File.exists? TMP_DIR
    FileUtils.rm_rf APP_DIR if File.exists? APP_DIR
    generate_app
    raise "gen app failed with return code #$?" unless $? == 0
  end

  def teardown
    # FileUtils.rm_rf APP_DIR if File.exists? APP_DIR
  end

  def test_that_tests_work_on_new_project
    run_app_tests
  end

  if not ON_JRUBY_JARS_1_5_6
    def test_that_yaml_loads
      assert_code "require 'yaml'"
    end
  else
    puts "Skipping YAML tests on jruby-jars-1.5.6"
  end

  def test_file_read_source_file
    assert_code "File.read(__FILE__)"
  end

  private

  def assert_code(code)
    filename = "#{APP_DIR}/assets/scripts/ruboto_test_app_activity.rb"
    s        = File.read(filename)
    s.gsub!(/(require 'ruboto')/, "\\1\n#{code}")
    File.open(filename, 'w') { |f| f << s }
    run_app_tests
  end

  def run_app_tests
    Dir.chdir "#{APP_DIR}/test" do
#      system "adb uninstall #{PACKAGE}"
#      system 'ant run-tests'
      system 'rake test:quick'
      assert_equal 0, $?, "tests failed with return code #$?"
      system "adb uninstall #{PACKAGE}"
    end
  end

end